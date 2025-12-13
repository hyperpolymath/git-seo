# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025 hyperpolymath

"""
Command-line interface using Comonicon.jl
"""

using Comonicon
using Dates

"""
Analyze a git repository for SEO optimization opportunities.

# Arguments

- `url`: Repository URL (GitHub, GitLab, or Bitbucket)

# Flags

- `--json, -j`: Output results as JSON
- `--verbose, -v`: Show detailed analysis

# Example

```bash
git-seo analyze https://github.com/JuliaLang/julia
```
"""
@cast function analyze(url::String; json::Bool=false, verbose::Bool=false)
    try
        report = analyze_repo(url)

        if json
            print_json_report(report)
        else
            print_text_report(report, verbose)
        end
    catch e
        if e isa HTTP.ExceptionRequest.StatusError
            printstyled("Error: ", color=:red, bold=true)
            println("Failed to fetch repository data (HTTP $(e.status))")
        else
            printstyled("Error: ", color=:red, bold=true)
            println(e)
        end
        return 1
    end
    return 0
end

"""
Compare SEO scores between two repositories.

# Arguments

- `repo1`: First repository URL
- `repo2`: Second repository URL

# Example

```bash
git-seo compare https://github.com/user/repo1 https://github.com/user/repo2
```
"""
@cast function compare(repo1::String, repo2::String)
    println("Analyzing repositories...")

    report1 = analyze_repo(repo1)
    report2 = analyze_repo(repo2)

    print_comparison(report1, report2)
    return 0
end

"""
Generate optimization suggestions for a repository.

# Arguments

- `url`: Repository URL

# Flags

- `--apply, -a`: Attempt to apply optimizations (interactive)

# Example

```bash
git-seo optimize https://github.com/user/repo
```
"""
@cast function optimize(url::String; apply::Bool=false)
    report = analyze_repo(url)

    println()
    printstyled("Optimization Recommendations\n", color=:cyan, bold=true)
    printstyled("=" ^ 50, "\n", color=:cyan)

    if isempty(report.recommendations)
        printstyled("No recommendations - repository is well optimized!\n", color=:green)
    else
        for (i, rec) in enumerate(report.recommendations)
            printstyled("  $i. ", color=:yellow)
            println(rec)
        end
    end

    if apply
        println()
        printstyled("Note: ", color=:yellow, bold=true)
        println("Automatic optimization not yet implemented.")
        println("Please apply recommendations manually.")
    end

    return 0
end

# Output formatting

function print_text_report(report::SEOReport, verbose::Bool)
    println()
    printstyled("Git SEO Analysis Report\n", color=:cyan, bold=true)
    printstyled("=" ^ 50, "\n", color=:cyan)

    # Repository info
    printstyled("Repository: ", color=:white, bold=true)
    println("$(report.repo.owner)/$(report.repo.name)")
    printstyled("Forge: ", color=:white, bold=true)
    println(uppercasefirst(string(report.repo.forge)))
    println()

    # Overall score
    percentage = round(report.total_score / report.max_possible * 100, digits=1)
    score_color = percentage >= 80 ? :green : percentage >= 50 ? :yellow : :red

    printstyled("Overall Score: ", color=:white, bold=true)
    printstyled("$(report.total_score)/$(report.max_possible) ($percentage%)\n", color=score_color, bold=true)
    println()

    # Category breakdown
    printstyled("Category Scores\n", color=:cyan, bold=true)
    printstyled("-" ^ 50, "\n", color=:cyan)

    for score in report.scores
        cat_pct = round(score.score / score.max_score * 100, digits=1)
        cat_color = cat_pct >= 80 ? :green : cat_pct >= 50 ? :yellow : :red

        cat_name = rpad(uppercasefirst(string(score.category)), 12)
        printstyled("  $cat_name", color=:white)
        printstyled("$(lpad(string(round(score.score, digits=1)), 5))/$(score.max_score)", color=cat_color)

        if verbose
            printstyled("  $(score.details)", color=:light_black)
        end
        println()
    end

    # Recommendations
    if !isempty(report.recommendations)
        println()
        printstyled("Recommendations\n", color=:cyan, bold=true)
        printstyled("-" ^ 50, "\n", color=:cyan)

        for (i, rec) in enumerate(report.recommendations)
            printstyled("  $i. ", color=:yellow)
            println(rec)
        end
    end

    println()
    printstyled("Analyzed at: $(report.analyzed_at)\n", color=:light_black)
end

function print_json_report(report::SEOReport)
    # Simple JSON output
    result = Dict(
        "repository" => Dict(
            "forge" => string(report.repo.forge),
            "owner" => report.repo.owner,
            "name" => report.repo.name,
            "url" => report.repo.url,
        ),
        "scores" => Dict(
            "total" => report.total_score,
            "max" => report.max_possible,
            "percentage" => round(report.total_score / report.max_possible * 100, digits=1),
            "categories" => [
                Dict(
                    "name" => string(s.category),
                    "score" => s.score,
                    "max" => s.max_score,
                    "details" => s.details,
                ) for s in report.scores
            ]
        ),
        "recommendations" => report.recommendations,
        "analyzed_at" => report.analyzed_at,
    )

    println(JSON3.write(result))
end

function print_comparison(r1::SEOReport, r2::SEOReport)
    println()
    printstyled("Repository Comparison\n", color=:cyan, bold=true)
    printstyled("=" ^ 60, "\n", color=:cyan)

    # Header
    name1 = "$(r1.repo.owner)/$(r1.repo.name)"
    name2 = "$(r2.repo.owner)/$(r2.repo.name)"

    println()
    printstyled(rpad("Category", 15), color=:white, bold=true)
    printstyled(lpad(name1[1:min(20, length(name1))], 22), color=:cyan)
    printstyled(lpad(name2[1:min(20, length(name2))], 22), color=:magenta)
    println()
    printstyled("-" ^ 60, "\n", color=:light_black)

    # Scores by category
    for (s1, s2) in zip(r1.scores, r2.scores)
        cat_name = rpad(uppercasefirst(string(s1.category)), 15)

        score1 = "$(round(s1.score, digits=1))/$(s1.max_score)"
        score2 = "$(round(s2.score, digits=1))/$(s2.max_score)"

        color1 = s1.score >= s2.score ? :green : :red
        color2 = s2.score >= s1.score ? :green : :red

        printstyled(cat_name, color=:white)
        printstyled(lpad(score1, 22), color=color1)
        printstyled(lpad(score2, 22), color=color2)
        println()
    end

    # Totals
    printstyled("-" ^ 60, "\n", color=:light_black)

    pct1 = round(r1.total_score / r1.max_possible * 100, digits=1)
    pct2 = round(r2.total_score / r2.max_possible * 100, digits=1)

    total1 = "$(round(r1.total_score, digits=1)) ($pct1%)"
    total2 = "$(round(r2.total_score, digits=1)) ($pct2%)"

    color1 = pct1 >= pct2 ? :green : :red
    color2 = pct2 >= pct1 ? :green : :red

    printstyled(rpad("TOTAL", 15), color=:white, bold=true)
    printstyled(lpad(total1, 22), color=color1, bold=true)
    printstyled(lpad(total2, 22), color=color2, bold=true)
    println()
    println()

    # Winner
    if pct1 > pct2
        printstyled("Winner: ", color=:white)
        printstyled("$name1\n", color=:green, bold=true)
    elseif pct2 > pct1
        printstyled("Winner: ", color=:white)
        printstyled("$name2\n", color=:green, bold=true)
    else
        printstyled("Result: ", color=:white)
        printstyled("Tie!\n", color=:yellow, bold=true)
    end
end

"""
Git SEO - Make your repositories discoverable.

Analyze, compare, and optimize git repositories for better discoverability
across GitHub, GitLab, Bitbucket, and other forges.
"""
@main
