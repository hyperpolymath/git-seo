# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025 hyperpolymath

# git-seo justfile - RSR compliant task runner
# See: https://just.systems/

# Default recipe
default: help

# Show available commands
help:
    @just --list

# ============================================================
# Development
# ============================================================

# Install dependencies
setup:
    julia --project=. -e 'using Pkg; Pkg.instantiate()'

# Build the CLI
build:
    julia --project=. -e 'using Pkg; Pkg.precompile()'

# Run tests
test:
    julia --project=. -e 'using Pkg; Pkg.test()'

# Run the CLI (example)
run *ARGS:
    julia --project=. bin/git-seo {{ARGS}}

# Start Julia REPL with project
repl:
    julia --project=.

# ============================================================
# Code Quality
# ============================================================

# Format code (if JuliaFormatter available)
format:
    julia --project=. -e 'using JuliaFormatter; format("src")'

# Lint code
lint:
    julia --project=. -e 'using Pkg; Pkg.test()' # Basic linting via tests

# ============================================================
# RSR Compliance
# ============================================================

# Validate RSR compliance
validate: check-spdx check-docs check-structure
    @echo "✓ RSR validation passed"

# Check SPDX headers on source files
check-spdx:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Checking SPDX headers..."
    missing=0
    for file in src/*.jl bin/git-seo; do
        if ! head -3 "$file" | grep -q "SPDX-License-Identifier"; then
            echo "Missing SPDX header: $file"
            missing=$((missing + 1))
        fi
    done
    if [ $missing -gt 0 ]; then
        echo "✗ $missing files missing SPDX headers"
        exit 1
    fi
    echo "✓ All source files have SPDX headers"

# Check required documentation files
check-docs:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Checking required documentation..."
    required_files=(
        "README.adoc"
        "LICENSE.txt"
        "SECURITY.md"
        "CODE_OF_CONDUCT.adoc"
        "CONTRIBUTING.adoc"
        "FUNDING.yml"
        "GOVERNANCE.adoc"
        "MAINTAINERS.md"
        ".gitignore"
        ".gitattributes"
    )
    missing=0
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            echo "Missing required file: $file"
            missing=$((missing + 1))
        fi
    done
    if [ $missing -gt 0 ]; then
        echo "✗ $missing required files missing"
        exit 1
    fi
    echo "✓ All required documentation present"

# Check .well-known directory
check-structure:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Checking .well-known directory..."
    wellknown_files=(
        ".well-known/security.txt"
        ".well-known/humans.txt"
        ".well-known/ai.txt"
        ".well-known/provenance.json"
    )
    missing=0
    for file in "${wellknown_files[@]}"; do
        if [ ! -f "$file" ]; then
            echo "Missing: $file"
            missing=$((missing + 1))
        fi
    done
    if [ $missing -gt 0 ]; then
        echo "✗ $missing .well-known files missing"
        exit 1
    fi
    echo "✓ .well-known directory complete"

# Check links with lychee (if available)
check-links:
    lychee --offline README.adoc CONTRIBUTING.adoc || echo "Install lychee for link checking"

# ============================================================
# Release
# ============================================================

# Show current version
version:
    @grep '^version' Project.toml | cut -d'"' -f2

# Tag a release
tag VERSION:
    git tag -s v{{VERSION}} -m "Release v{{VERSION}}"
    @echo "Created tag v{{VERSION}}"

# ============================================================
# Cleanup
# ============================================================

# Clean build artifacts
clean:
    rm -rf Manifest.toml
    rm -rf coverage/
    rm -f *.jl.cov *.jl.mem
    @echo "✓ Cleaned"
