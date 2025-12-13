# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025 hyperpolymath

using Test
using GitSEO

@testset "GitSEO Tests" begin

    @testset "URL Parsing" begin
        # GitHub HTTPS
        repo = GitSEO.parse_repo_url("https://github.com/JuliaLang/julia")
        @test repo.forge == :github
        @test repo.owner == "JuliaLang"
        @test repo.name == "julia"

        # GitHub with .git suffix
        repo = GitSEO.parse_repo_url("https://github.com/user/repo.git")
        @test repo.forge == :github
        @test repo.name == "repo"

        # GitLab
        repo = GitSEO.parse_repo_url("https://gitlab.com/hyperpolymath/git-seo")
        @test repo.forge == :gitlab
        @test repo.owner == "hyperpolymath"
        @test repo.name == "git-seo"

        # Bitbucket
        repo = GitSEO.parse_repo_url("https://bitbucket.org/owner/repo")
        @test repo.forge == :bitbucket

        # Unknown forge
        repo = GitSEO.parse_repo_url("https://example.com/foo/bar")
        @test repo.forge == :unknown
    end

    @testset "README Analysis" begin
        # README with badges
        content = """
        # My Project

        ![Build](https://img.shields.io/badge/build-passing-green)
        ![Version](https://shields.io/badge/version-1.0-blue)

        ## Installation

        ```bash
        pip install myproject
        ```

        ## Usage

        ```python
        import myproject
        myproject.run()
        ```

        ## Contributing

        See CONTRIBUTING.md
        """

        analysis = GitSEO.analyze_readme_content(content)
        @test analysis.exists == true
        @test analysis.has_badges == true
        @test analysis.badge_count >= 2
        @test analysis.has_install_section == true
        @test analysis.has_usage_section == true
        @test analysis.has_contributing_section == true
        @test analysis.code_block_count >= 2
    end

    @testset "Scoring" begin
        # Create test metadata
        metadata = GitSEO.RepoMetadata(
            name = "test-project",
            description = "A test project for demonstration purposes with good description length",
            topics = ["test", "julia", "cli", "seo", "analysis"],
            license = "MIT",
            stars = 100,
            forks = 25,
            watchers = 50,
        )

        readme = GitSEO.ReadmeAnalysis(
            exists = true,
            length = 2000,
            has_badges = true,
            badge_count = 3,
            has_install_section = true,
            has_usage_section = true,
            has_contributing_section = true,
            heading_count = 5,
            code_block_count = 4,
        )

        scores, total, max_score = GitSEO.calculate_scores(metadata, readme)

        @test length(scores) >= 4
        @test total > 0
        @test total <= max_score
        @test max_score == 100.0
    end

    @testset "Recommendations" begin
        # Metadata with issues
        metadata = GitSEO.RepoMetadata(
            name = "test",
            description = "",  # Empty description
            topics = String[],  # No topics
            license = "",  # No license
        )

        readme = GitSEO.ReadmeAnalysis(exists = false)

        scores, _, _ = GitSEO.calculate_scores(metadata, readme)
        recommendations = GitSEO.generate_recommendations(metadata, readme, scores)

        @test length(recommendations) > 0
        @test any(r -> occursin("description", lowercase(r)), recommendations)
        @test any(r -> occursin("topics", lowercase(r)) || occursin("tags", lowercase(r)), recommendations)
        @test any(r -> occursin("license", lowercase(r)), recommendations)
        @test any(r -> occursin("readme", lowercase(r)), recommendations)
    end

end
