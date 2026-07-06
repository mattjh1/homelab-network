package main

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"text/template"
)

const (
	srcDir = "router"
	dstDir = ".rendered/router"
)

type envMap map[string]string

func main() {
	if err := renderAll(srcDir, dstDir); err != nil {
		fmt.Fprintf(os.Stderr, "render error: %v\n", err)
		os.Exit(1)
	}
}

func renderAll(srcDir, dstDir string) error {
	if err := os.MkdirAll(dstDir, 0o755); err != nil {
		return fmt.Errorf("create dst-dir: %w", err)
	}

	paths, err := filepath.Glob(filepath.Join(srcDir, "*.rsc"))
	if err != nil {
		return fmt.Errorf("glob src-dir: %w", err)
	}
	if len(paths) == 0 {
		return errors.New("no .rsc template files found")
	}

	data := collectEnv()
	for _, srcPath := range paths {
		dstPath := filepath.Join(dstDir, filepath.Base(srcPath))
		if err := renderFile(srcPath, dstPath, data); err != nil {
			return fmt.Errorf("render %s: %w", srcPath, err)
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

