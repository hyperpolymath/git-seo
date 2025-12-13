# Claude AI Instructions for git-seo

## Project Overview

git-seo is a Julia CLI tool that analyzes Git repositories for discoverability ("SEO") across GitHub, GitLab, Bitbucket, and other forges.

## Key Guidelines

### Language: Julia 1.9+

This is a **Julia** project. All source code uses Julia syntax and patterns.

### SPDX Headers Required

Every `.jl` file must start with:
```julia
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025 hyperpolymath
```

### Code Style

- Use descriptive variable names (e.g., `repository_metadata` not `rm`)
- Add type annotations to function signatures
- Use docstrings for public functions
- Follow Julia Style Guide

### Architecture

```
src/
├── GitSEO.jl      # Main module, exports
├── types.jl       # RepoIdentifier, RepoMetadata, SEOReport, etc.
├── parsers.jl     # parse_repo_url(), build_api_url()
├── analyzers.jl   # fetch_repo_metadata(), analyze_readme()
├── scoring.jl     # calculate_scores(), generate_recommendations()
└── cli.jl         # @cast commands: analyze, compare, optimize
```

### Security Requirements

- HTTPS only for all API calls
- Tokens from environment variables only (`GITHUB_TOKEN`, etc.)
- No hardcoded credentials
- Validate/sanitize user input (URLs)

### RSR Compliance

This project follows Rhodium Standard Repositories:
- Required documentation files present
- .well-known/ directory configured
- SPDX headers on all source files
- justfile for task automation

### When Adding Features

1. Add types to `types.jl` if new data structures needed
2. Add parsing logic to `parsers.jl` for new forge support
3. Add analysis in `analyzers.jl`
4. Add scoring in `scoring.jl`
5. Expose via CLI in `cli.jl`
6. Update README.adoc with new functionality
7. Run `just validate` before committing

### Testing

Tests go in `test/runtests.jl`. Use Julia's `Test` module.

### Dependencies

- Comonicon.jl - CLI framework (decorators-based)
- HTTP.jl - HTTP client
- JSON3.jl - Fast JSON parsing
- URIs.jl - URL manipulation

## Common Tasks

### Add support for a new forge (e.g., Codeberg)

1. Add regex to `FORGE_PATTERNS` in `parsers.jl`
2. Add case to `build_api_url()` and `build_readme_url()`
3. Add `parse_codeberg_metadata()` function
4. Update `parse_metadata()` dispatch
5. Add to supported forges in README.adoc

### Add a new scoring category

1. Add weight to `SCORING_WEIGHTS` dict
2. Create `score_<category>(...)::ScoreComponent` function
3. Add call in `calculate_scores()`
4. Add recommendations in `generate_recommendations()`

### Add a new CLI command

Use Comonicon.jl `@cast` macro:
```julia
@cast function newcommand(arg::String; flag::Bool=false)
    # implementation
end
```
