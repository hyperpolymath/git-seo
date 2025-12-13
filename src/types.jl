# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025 hyperpolymath

"""
Core types for GitSEO analysis.
"""

"""
Represents a parsed repository URL with forge detection.
"""
struct RepoIdentifier
    forge::Symbol          # :github, :gitlab, :bitbucket, :unknown
    owner::String
    name::String
    url::String
end

"""
Repository metadata extracted from forge APIs.
"""
Base.@kwdef struct RepoMetadata
    name::String = ""
    description::String = ""
    topics::Vector{String} = String[]
    license::String = ""
    stars::Int = 0
    forks::Int = 0
    watchers::Int = 0
    open_issues::Int = 0
    has_readme::Bool = false
    has_contributing::Bool = false
    has_license::Bool = false
    has_changelog::Bool = false
    default_branch::String = "main"
    created_at::String = ""
    updated_at::String = ""
    language::String = ""
    languages::Dict{String,Int} = Dict{String,Int}()
end

"""
README analysis results.
"""
Base.@kwdef struct ReadmeAnalysis
    exists::Bool = false
    length::Int = 0
    has_badges::Bool = false
    badge_count::Int = 0
    has_install_section::Bool = false
    has_usage_section::Bool = false
    has_screenshots::Bool = false
    has_contributing_section::Bool = false
    heading_count::Int = 0
    code_block_count::Int = 0
end

"""
Individual score component with explanation.
"""
struct ScoreComponent
    category::Symbol
    score::Float64
    max_score::Float64
    details::String
end

"""
Complete SEO analysis result.
"""
Base.@kwdef struct SEOReport
    repo::RepoIdentifier
    metadata::RepoMetadata
    readme::ReadmeAnalysis
    scores::Vector{ScoreComponent} = ScoreComponent[]
    total_score::Float64 = 0.0
    max_possible::Float64 = 100.0
    recommendations::Vector{String} = String[]
    analyzed_at::String = ""
end
