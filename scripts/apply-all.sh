#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/apply-all.sh [options]

Options:
  --env FILE         Path to env file (default: ./secrets.env)
  --from NAME        Start from this script filename (for example 07-dhcp.rsc)
  --until NAME       Stop after this script filename (inclusive)
  --resume           Resume from script after state/last-successful-step.txt
  --pause-each       Pause for confirmation after every successful step
  --dry-run          Print actions without applying changes
  -h, --help         Show this help
EOF
}

ENV_FILE="secrets.env"
START_FROM=""
STOP_AT=""
RESUME=0
PAUSE_EACH=0
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)
      ENV_FILE="${2:-}"
      shift 2
      ;;
    --from)
      START_FROM="${2:-}"
      shift 2
      ;;
    --until)
      STOP_AT="${2:-}"
      shift 2
      ;;
    --resume)
      RESUME=1
      shift
      ;;
    --pause-each)
      PAUSE_EACH=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if (( RESUME )) && [[ -n "$START_FROM" ]]; then
  echo "--resume and --from cannot be used together" >&2
  exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing env file: $ENV_FILE" >&2
  echo "Copy secrets.env.example to secrets.env and fill values first." >&2
  exit 1
fi

set -a
source "$ENV_FILE"
set +a

ROUTER_SCRIPT_DIR="${ROUTER_SCRIPT_DIR:-router}"
APPLY_LOG_DIR="${APPLY_LOG_DIR:-logs}"
APPLY_STATE_DIR="${APPLY_STATE_DIR:-state}"
RENDERED_ROUTER_DIR="${RENDERED_ROUTER_DIR:-.rendered/router}"
ROUTER_SSH_PORT="${ROUTER_SSH_PORT:-22}"
APPLY_CONNECT_TIMEOUT="${APPLY_CONNECT_TIMEOUT:-8}"

mkdir -p "$APPLY_LOG_DIR" "$APPLY_STATE_DIR" "$RENDERED_ROUTER_DIR"

LAST_SUCCESS_FILE="${APPLY_STATE_DIR}/last-successful-step.txt"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
RUN_LOG="${APPLY_LOG_DIR}/apply-${TIMESTAMP}.log"
STEP_STATUS_LOG="${APPLY_STATE_DIR}/steps-${TIMESTAMP}.log"

required_vars=(
  ROUTER_HOST
  ROUTER_USER
  ROUTER_SSH_KEY
)

for key in "${required_vars[@]}"; do
  if [[ -z "${!key:-}" ]]; then
    echo "Missing required variable: $key" >&2
    exit 1
  fi
done

ROUTER_SSH_KEY="${ROUTER_SSH_KEY/#\~/$HOME}"
if (( DRY_RUN == 0 )) && [[ ! -f "$ROUTER_SSH_KEY" ]]; then
  echo "SSH key not found: $ROUTER_SSH_KEY" >&2
  exit 1
fi

if [[ ! -d "$ROUTER_SCRIPT_DIR" ]]; then
  echo "Router script directory not found: $ROUTER_SCRIPT_DIR" >&2
  exit 1
fi

render_templates() {
  printf '%s %s\n' "$(date -Is)" "Rendering router templates via Go" | tee -a "$RUN_LOG"
  go run scripts/render-router-templates.go --src-dir "$ROUTER_SCRIPT_DIR" --dst-dir "$RENDERED_ROUTER_DIR"
}

render_templates

mapfile -t scripts < <(printf '%s\n' "$RENDERED_ROUTER_DIR"/*.rsc | sort)
if [[ "${#scripts[@]}" -eq 0 || "${scripts[0]}" == "$RENDERED_ROUTER_DIR/*.rsc" ]]; then
  echo "No rendered router scripts found in $RENDERED_ROUTER_DIR" >&2
  exit 1
fi

log() {
  local msg="$1"
  printf '%s %s\n' "$(date -Is)" "$msg" | tee -a "$RUN_LOG"
}

mark_status() {
  local step="$1"
  local status="$2"
  printf '%s\t%s\t%s\n' "$(date -Is)" "$step" "$status" >> "$STEP_STATUS_LOG"
}

run_remote() {
  local cmd="$1"
  if (( DRY_RUN )); then
    log "[dry-run] ssh $ROUTER_USER@$ROUTER_HOST $cmd"
    return 0
  fi
  ssh -i "$ROUTER_SSH_KEY" \
    -p "$ROUTER_SSH_PORT" \
    -o BatchMode=yes \
    -o ConnectTimeout="$APPLY_CONNECT_TIMEOUT" \
    "$ROUTER_USER@$ROUTER_HOST" "$cmd"
}

copy_script() {
  local local_file="$1"
  local remote_name="$2"
  if (( DRY_RUN )); then
    log "[dry-run] scp $local_file -> $ROUTER_USER@$ROUTER_HOST:$remote_name"
    return 0
  fi
  scp -i "$ROUTER_SSH_KEY" \
    -P "$ROUTER_SSH_PORT" \
    -o BatchMode=yes \
    -o ConnectTimeout="$APPLY_CONNECT_TIMEOUT" \
    "$local_file" "$ROUTER_USER@$ROUTER_HOST:$remote_name"
}

resolve_start_from_resume() {
  if (( RESUME == 0 )); then
    return
  fi
  if [[ ! -f "$LAST_SUCCESS_FILE" ]]; then
    echo "--resume requested but state file missing: $LAST_SUCCESS_FILE" >&2
    exit 1
  fi
  local last_success
  last_success="$(<"$LAST_SUCCESS_FILE")"
  local found=0
  for full_path in "${scripts[@]}"; do
    local base
    base="$(basename "$full_path")"
    if [[ "$found" -eq 1 ]]; then
      START_FROM="$base"
      return
    fi
    if [[ "$base" == "$last_success" ]]; then
      found=1
    fi
  done
  echo "Could not resolve next step after last success: $last_success" >&2
  exit 1
}

resolve_start_from_resume

log "Run log: $RUN_LOG"
log "Step status log: $STEP_STATUS_LOG"
log "Preflight: checking SSH reachability"
run_remote ':put "apply-all-connected"'

started=0

for file in "${scripts[@]}"; do
  name="$(basename "$file")"

  if [[ -n "$START_FROM" && "$started" -eq 0 ]]; then
    if [[ "$name" != "$START_FROM" ]]; then
      continue
    fi
  fi
  started=1

  log "Applying $name"
  mark_status "$name" "started"

  remote_name="$name"
  if ! copy_script "$file" "$remote_name"; then
    mark_status "$name" "failed-copy"
    log "Failed while copying $name"
    exit 1
  fi

  if ! run_remote "/import file-name=$remote_name"; then
    mark_status "$name" "failed-import"
    log "Failed while importing $name"
    exit 1
  fi

  run_remote "/file remove $remote_name" || true

  printf '%s\n' "$name" > "$LAST_SUCCESS_FILE"
  mark_status "$name" "success"
  log "Completed $name"

  if (( PAUSE_EACH )); then
    read -r -p "Validated $name. Press Enter to continue (Ctrl+C to stop)." _
  fi

  if [[ -n "$STOP_AT" && "$name" == "$STOP_AT" ]]; then
    log "Reached --until target ($STOP_AT), stopping."
    exit 0
  fi
done

if [[ "$started" -eq 0 ]]; then
  echo "Start point not found: $START_FROM" >&2
  exit 1
fi

log "All scripts applied successfully."

