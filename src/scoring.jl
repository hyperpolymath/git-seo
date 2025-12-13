# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025 hyperpolymath

"""
SEO scoring algorithms and recommendation generation.
"""

using Dates

const SCORING_WEIGHTS = Dict(
    :metadata => 25.0,
    :readme => 30.0,
    :social => 20.0,
    :activity => 15.0,
    :quality => 10.0,
)

"""
    calculate_scores(metadata::RepoMetadata, readme::ReadmeAnalysis) -> (Vector{ScoreComponent}, Float64, Float64)

Calculate SEO scores across all categories.
"""
function calculate_scores(metadata::RepoMetadata, readme::ReadmeAnalysis)
    scores = ScoreComponent[]

    # Metadata scoring
    push!(scores, score_metadata(metadata))

    # README scoring
    push!(scores, score_readme(readme))

    # Social signals scoring
    push!(scores, score_social(metadata))

    # Activity scoring
    push!(scores, score_activity(metadata))

    # Quality indicators
    push!(scores, score_quality(metadata, readme))

    total = sum(s.score for s in scores)
    max_possible = sum(s.max_score for s in scores)

    return scores, total, max_possible
end

function score_metadata(m::RepoMetadata)::ScoreComponent
    max_score = SCORING_WEIGHTS[:metadata]
    score = 0.0
    details = String[]

    # Name quality (5 pts)
    if !isempty(m.name)
        score += 2.0
        if occursin("-", m.name) || occursin("_", m.name)
            score += 1.5  # Uses separators (kebab/snake case)
        end
        if length(m.name) >= 5 && length(m.name) <= 30
            score += 1.5  # Good length
        end
    else
        push!(details, "Missing repository name")
    end

    # Description (8 pts)
    desc_len = length(m.description)
    if desc_len > 0
        score += 3.0
        if desc_len >= 50
            score += 2.0
        end
        if desc_len >= 100 && desc_len <= 350
            score += 3.0  # Optimal length
        end
    else
        push!(details, "No description set")
    end

    # Topics (7 pts)
    topic_count = length(m.topics)
    if topic_count > 0
        score += min(topic_count, 5) * 1.0  # Up to 5 pts for topics
        if topic_count >= 5
            score += 2.0  # Bonus for 5+ topics
        end
    else
        push!(details, "No topics/tags configured")
    end

    # License (5 pts)
    if !isempty(m.license)
        score += 5.0
    else
        push!(details, "No license detected")
    end

    detail_str = isempty(details) ? "All metadata present" : join(details, "; ")

    ScoreComponent(:metadata, min(score, max_score), max_score, detail_str)
end

function score_readme(r::ReadmeAnalysis)::ScoreComponent
    max_score = SCORING_WEIGHTS[:readme]
    score = 0.0
    details = String[]

    if !r.exists
        return ScoreComponent(:readme, 0.0, max_score, "README.md not found")
    end

    # Base points for having README
    score += 5.0

    # Length (5 pts)
    if r.length >= 500
        score += 2.5
    end
    if r.length >= 1500
        score += 2.5
    end

    # Badges (5 pts)
    if r.has_badges
        score += min(r.badge_count, 5) * 1.0
    else
        push!(details, "No badges found")
    end

    # Sections (10 pts)
    if r.has_install_section
        score += 3.0
    else
        push!(details, "Missing installation section")
    end

    if r.has_usage_section
        score += 4.0
    else
        push!(details, "Missing usage/examples section")
    end

    if r.has_contributing_section
        score += 3.0
    end

    # Code examples (5 pts)
    if r.code_block_count > 0
        score += min(r.code_block_count, 5) * 1.0
    else
        push!(details, "No code examples")
    end

    detail_str = isempty(details) ? "README well-structured" : join(details, "; ")

    ScoreComponent(:readme, min(score, max_score), max_score, detail_str)
end

function score_social(m::RepoMetadata)::ScoreComponent
    max_score = SCORING_WEIGHTS[:social]
    score = 0.0
    details = String[]

    # Stars (10 pts, logarithmic)
    if m.stars > 0
        star_score = min(log10(m.stars + 1) * 3.0, 10.0)
        score += star_score
    else
        push!(details, "No stars yet")
    end

    # Forks (5 pts)
    if m.forks > 0
        fork_score = min(log10(m.forks + 1) * 2.0, 5.0)
        score += fork_score
    end

    # Watchers (5 pts)
    if m.watchers > 0
        watch_score = min(log10(m.watchers + 1) * 2.0, 5.0)
        score += watch_score
    end

    detail_str = "Stars: $(m.stars), Forks: $(m.forks), Watchers: $(m.watchers)"

    ScoreComponent(:social, min(score, max_score), max_score, detail_str)
end

function score_activity(m::RepoMetadata)::ScoreComponent
    max_score = SCORING_WEIGHTS[:activity]
    score = 0.0
    details = String[]

    # Recent updates (10 pts)
    if !isempty(m.updated_at)
        try
            # Parse ISO 8601 date
            updated = DateTime(m.updated_at[1:min(19, length(m.updated_at))], "yyyy-mm-ddTHH:MM:SS")
            days_since = Dates.value(Dates.now() - updated) / (1000 * 60 * 60 * 24)

            if days_since < 7
                score += 10.0
                push!(details, "Updated within last week")
            elseif days_since < 30
                score += 7.0
                push!(details, "Updated within last month")
            elseif days_since < 90
                score += 4.0
                push!(details, "Updated within last 3 months")
            elseif days_since < 365
                score += 2.0
                push!(details, "Updated within last year")
            else
                push!(details, "No updates in over a year")
            end
        catch e
            push!(details, "Could not parse update date")
        end
    end

    # Open issues as activity signal (5 pts)
    if m.open_issues > 0 && m.open_issues < 100
        score += 5.0  # Some activity but not overwhelmed
    elseif m.open_issues >= 100
        score += 2.0  # Active but potentially overwhelmed
        push!(details, "High issue count ($(m.open_issues))")
    end

    detail_str = isempty(details) ? "Activity metrics unavailable" : join(details, "; ")

    ScoreComponent(:activity, min(score, max_score), max_score, detail_str)
end

function score_quality(m::RepoMetadata, r::ReadmeAnalysis)::ScoreComponent
    max_score = SCORING_WEIGHTS[:quality]
    score = 0.0
    details = String[]

    # Language detection (3 pts)
    if !isempty(m.language)
        score += 3.0
    else
        push!(details, "Primary language not detected")
    end

    # License presence (3 pts) - already scored in metadata but quality signal too
    if !isempty(m.license)
        score += 3.0
    end

    # README structure (4 pts)
    if r.heading_count >= 3
        score += 2.0
    end
    if r.code_block_count >= 2
        score += 2.0
    end

    detail_str = isempty(details) ? "Quality indicators present" : join(details, "; ")

    ScoreComponent(:quality, min(score, max_score), max_score, detail_str)
end

"""
    generate_recommendations(metadata::RepoMetadata, readme::ReadmeAnalysis, scores::Vector{ScoreComponent}) -> Vector{String}

Generate actionable recommendations based on analysis.
"""
function generate_recommendations(metadata::RepoMetadata, readme::ReadmeAnalysis, scores::Vector{ScoreComponent})::Vector{String}
    recs = String[]

    # Metadata recommendations
    if isempty(metadata.description)
        push!(recs, "Add a repository description (50-350 characters recommended)")
    elseif length(metadata.description) < 50
        push!(recs, "Expand description to at least 50 characters for better discoverability")
    end

    if length(metadata.topics) < 5
        push!(recs, "Add more topics/tags (aim for 5-10 relevant keywords)")
    end

    if isempty(metadata.license)
        push!(recs, "Add a LICENSE file (MIT, Apache-2.0, or GPL recommended)")
    end

    # README recommendations
    if !readme.exists
        push!(recs, "Create a README.md file - this is critical for discoverability")
    else
        if !readme.has_badges
            push!(recs, "Add status badges (build status, version, license)")
        end

        if !readme.has_install_section
            push!(recs, "Add an Installation section to README")
        end

        if !readme.has_usage_section
            push!(recs, "Add a Usage section with code examples")
        end

        if readme.code_block_count == 0
            push!(recs, "Include code examples in fenced code blocks")
        end

        if readme.length < 500
            push!(recs, "Expand README content (aim for 1000+ characters)")
        end
    end

    return recs
end
