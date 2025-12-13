# GitHub Copilot Instructions for git-seo

## Project Context

git-seo is a Julia CLI tool for analyzing and optimizing Git repository discoverability.

## Coding Guidelines

### Language
- **Julia 1.9+** is the primary language
- Follow Julia Style Guide: https://docs.julialang.org/en/v1/manual/style-guide/
- Use descriptive variable names
- Add type annotations where beneficial for clarity

### SPDX Headers
Every new Julia file must start with:
```julia
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025 hyperpolymath
```

### Documentation
- Add docstrings to all public functions
- Use Julia's standard docstring format with triple quotes

### Error Handling
- Use `try-catch` for HTTP requests
- Log warnings with `@warn`
- Return meaningful error messages

### Testing
- Write tests in `test/` directory
- Use Julia's built-in `Test` module

## Architecture

```
src/
├── GitSEO.jl      # Main module
├── types.jl       # Data structures
├── parsers.jl     # URL parsing
├── analyzers.jl   # Forge API analysis
├── scoring.jl     # SEO scoring algorithms
└── cli.jl         # CLI commands
```

## Key Patterns

### Adding a new forge
1. Add pattern to `FORGE_PATTERNS` in `parsers.jl`
2. Add API URL builder in `build_api_url()`
3. Add metadata parser function
4. Update README supported forges list

### Adding a scoring category
1. Add weight to `SCORING_WEIGHTS` in `scoring.jl`
2. Create `score_<category>()` function
3. Add to `calculate_scores()` pipeline
4. Update recommendations in `generate_recommendations()`

## Dependencies
- Comonicon.jl - CLI framework
- HTTP.jl - HTTP requests
- JSON3.jl - JSON parsing
- URIs.jl - URL handling

## RSR Compliance
This project follows Rhodium Standard Repositories. Run `just validate` before committing.
