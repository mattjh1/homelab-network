package main

import (
	"errors"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"text/template"
)

type envMap map[string]string

func main() {
	srcDir := flag.String("src-dir", "router", "Source router template directory")
	dstDir := flag.String("dst-dir", ".rendered/router", "Destination directory for rendered .rsc files")
	flag.Parse()

	if err := renderAll(*srcDir, *dstDir); err != nil {
		fmt.Fprintf(os.Stderr, "render error: %v\n", err)
		os.Exit(1)
	}
}

func renderAll(srcDir, dstDir string) error {
	info, err := os.Stat(srcDir)
	if err != nil {
		return fmt.Errorf("stat src-dir: %w", err)
	}
	if !info.IsDir() {
		return errors.New("src-dir must be a directory")
	}
	if err := os.MkdirAll(dstDir, 0o755); err != nil {
		return fmt.Errorf("create dst-dir: %w", err)
	}

	entries, err := os.ReadDir(srcDir)
	if err != nil {
		return fmt.Errorf("read src-dir: %w", err)
	}

	var names []string
	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		if strings.HasSuffix(e.Name(), ".rsc") {
			names = append(names, e.Name())
		}
	}
	sort.Strings(names)
	if len(names) == 0 {
		return errors.New("no .rsc template files found")
	}

	data := collectEnv()
	for _, name := range names {
		srcPath := filepath.Join(srcDir, name)
		dstPath := filepath.Join(dstDir, name)
		if err := renderFile(srcPath, dstPath, data); err != nil {
			return fmt.Errorf("render %s: %w", name, err)
		}
	}
	return nil
}

func renderFile(srcPath, dstPath string, data envMap) error {
	raw, err := os.ReadFile(srcPath)
	if err != nil {
		return fmt.Errorf("read template: %w", err)
	}

	tpl, err := template.New(filepath.Base(srcPath)).Option("missingkey=error").Parse(string(raw))
	if err != nil {
		return fmt.Errorf("parse template: %w", err)
	}

	out, err := os.Create(dstPath)
	if err != nil {
		return fmt.Errorf("create destination: %w", err)
	}
	defer out.Close()

	if err := tpl.Execute(out, data); err != nil {
		return fmt.Errorf("execute template: %w", err)
	}
	return nil
}

func collectEnv() envMap {
	m := make(envMap)
	for _, item := range os.Environ() {
		parts := strings.SplitN(item, "=", 2)
		if len(parts) != 2 {
			continue
		}
		m[parts[0]] = parts[1]
	}
	return m
}

