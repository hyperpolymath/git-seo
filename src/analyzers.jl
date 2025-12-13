# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025 hyperpolymath

"""
Repository analysis functions for different forges.
"""

"""
    fetch_repo_metadata(repo::RepoIdentifier) -> RepoMetadata

Fetch repository metadata from the forge API.
"""
function fetch_repo_metadata(repo::RepoIdentifier)::RepoMetadata
    api_url = build_api_url(repo)

    headers = ["User-Agent" => "GitSEO/0.1.0"]

    # Add GitHub token if available
    github_token = get(ENV, "GITHUB_TOKEN", "")
    if repo.forge == :github && !isempty(github_token)
        push!(headers, "Authorization" => "Bearer $(github_token)")
    end

    response = HTTP.get(api_url; headers=headers, status_exception=false)

    if response.status != 200
        @warn "Failed to fetch metadata" status=response.status url=api_url
        return RepoMetadata()
    end

    data = JSON3.read(String(response.body))

    return parse_metadata(repo.forge, data)
end

"""
    parse_metadata(forge::Symbol, data) -> RepoMetadata

Parse forge-specific API response into common RepoMetadata.
"""
function parse_metadata(forge::Symbol, data)::RepoMetadata
    if forge == :github
        return parse_github_metadata(data)
    elseif forge == :gitlab
        return parse_gitlab_metadata(data)
    elseif forge == :bitbucket
        return parse_bitbucket_metadata(data)
    else
        return RepoMetadata()
    end
end

function parse_github_metadata(data)::RepoMetadata
    topics = haskey(data, :topics) ? collect(String, data.topics) : String[]

    RepoMetadata(
        name = get(data, :name, ""),
        description = something(get(data, :description, nothing), ""),
        topics = topics,
        license = haskey(data, :license) && data.license !== nothing ?
                  get(data.license, :spdx_id, "") : "",
        stars = get(data, :stargazers_count, 0),
        forks = get(data, :forks_count, 0),
        watchers = get(data, :subscribers_count, 0),
        open_issues = get(data, :open_issues_count, 0),
        has_readme = true,  # Will verify separately
        default_branch = get(data, :default_branch, "main"),
        created_at = get(data, :created_at, ""),
        updated_at = get(data, :updated_at, ""),
        language = something(get(data, :language, nothing), ""),
    )
end

function parse_gitlab_metadata(data)::RepoMetadata
    topics = haskey(data, :topics) ? collect(String, data.topics) : String[]

    RepoMetadata(
        name = get(data, :name, ""),
        description = something(get(data, :description, nothing), ""),
        topics = topics,
        stars = get(data, :star_count, 0),
        forks = get(data, :forks_count, 0),
        open_issues = get(data, :open_issues_count, 0),
        default_branch = get(data, :default_branch, "main"),
        created_at = get(data, :created_at, ""),
        updated_at = get(data, :last_activity_at, ""),
    )
end

function parse_bitbucket_metadata(data)::RepoMetadata
    RepoMetadata(
        name = get(data, :name, ""),
        description = something(get(data, :description, nothing), ""),
        language = get(data, :language, ""),
        created_at = get(data, :created_on, ""),
        updated_at = get(data, :updated_on, ""),
    )
end

"""
    analyze_readme(repo::RepoIdentifier, branch::String) -> ReadmeAnalysis

Fetch and analyze README.md content.
"""
function analyze_readme(repo::RepoIdentifier, branch::String="main")::ReadmeAnalysis
    readme_url = build_readme_url(repo, branch)

    response = HTTP.get(readme_url; status_exception=false)

    if response.status != 200
        return ReadmeAnalysis(exists=false)
    end

    content = String(response.body)
    return analyze_readme_content(content)
end

"""
    analyze_readme_content(content::String) -> ReadmeAnalysis

Analyze README content for SEO factors.
"""
function analyze_readme_content(content::String)::ReadmeAnalysis
    lines = split(content, '\n')

    # Badge detection (shields.io, img.shields.io, badge URLs)
    badge_pattern = r"!\[.*?\]\(.*?(?:shields\.io|badge|img\.shields).*?\)"i
    badge_matches = collect(eachmatch(badge_pattern, content))

    # Section detection
    install_pattern = r"^#{1,3}\s*(?:install|installation|getting started|setup)"mi
    usage_pattern = r"^#{1,3}\s*(?:usage|how to use|quick start|examples?)"mi
    contributing_pattern = r"^#{1,3}\s*(?:contribut|development)"mi

    # Code blocks
    code_block_pattern = r"```"
    code_blocks = count(code_block_pattern, content) ÷ 2

    # Headings
    heading_pattern = r"^#{1,6}\s+"m
    headings = count(heading_pattern, content)

    # Images/screenshots
    image_pattern = r"!\[.*?\]\(.*?\)"
    images = length(collect(eachmatch(image_pattern, content))) - length(badge_matches)

    ReadmeAnalysis(
        exists = true,
        length = length(content),
        has_badges = !isempty(badge_matches),
        badge_count = length(badge_matches),
        has_install_section = occursin(install_pattern, content),
        has_usage_section = occursin(usage_pattern, content),
        has_screenshots = images > 0,
        has_contributing_section = occursin(contributing_pattern, content),
        heading_count = headings,
        code_block_count = code_blocks,
    )
end

"""
    analyze_repo(url::String) -> SEOReport

Complete repository analysis pipeline.
"""
function analyze_repo(url::String)::SEOReport
    repo = parse_repo_url(url)

    if repo.forge == :unknown
        error("Could not detect forge from URL: $url")
    end

    @info "Analyzing repository" forge=repo.forge owner=repo.owner name=repo.name

    metadata = fetch_repo_metadata(repo)
    readme = analyze_readme(repo, metadata.default_branch)

    scores, total, max_score = calculate_scores(metadata, readme)
    recommendations = generate_recommendations(metadata, readme, scores)

    SEOReport(
        repo = repo,
        metadata = metadata,
        readme = readme,
        scores = scores,
        total_score = total,
        max_possible = max_score,
        recommendations = recommendations,
        analyzed_at = string(Dates.now()),
    )
end
