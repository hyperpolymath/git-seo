# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025 hyperpolymath

"""
URL parsing and forge detection utilities.
"""

const FORGE_PATTERNS = Dict(
    :github => r"github\.com[/:]([^/]+)/([^/.]+)",
    :gitlab => r"gitlab\.com[/:]([^/]+)/([^/.]+)",
    :bitbucket => r"bitbucket\.org[/:]([^/]+)/([^/.]+)",
)

"""
    parse_repo_url(url::String) -> RepoIdentifier

Parse a repository URL and detect the forge type.
Supports GitHub, GitLab, Bitbucket URLs in HTTPS or SSH format.
"""
function parse_repo_url(url::String)::RepoIdentifier
    normalized_url = strip(url)

    # Remove .git suffix if present
    if endswith(normalized_url, ".git")
        normalized_url = normalized_url[1:end-4]
    end

    for (forge, pattern) in FORGE_PATTERNS
        m = match(pattern, normalized_url)
        if m !== nothing
            owner = String(m.captures[1])
            name = String(m.captures[2])
            return RepoIdentifier(forge, owner, name, url)
        end
    end

    return RepoIdentifier(:unknown, "", "", url)
end

"""
    build_api_url(repo::RepoIdentifier) -> String

Build the appropriate API URL for the detected forge.
"""
function build_api_url(repo::RepoIdentifier)::String
    if repo.forge == :github
        return "https://api.github.com/repos/$(repo.owner)/$(repo.name)"
    elseif repo.forge == :gitlab
        encoded_path = URIs.escapeuri("$(repo.owner)/$(repo.name)")
        return "https://gitlab.com/api/v4/projects/$(encoded_path)"
    elseif repo.forge == :bitbucket
        return "https://api.bitbucket.org/2.0/repositories/$(repo.owner)/$(repo.name)"
    else
        error("Unsupported forge: $(repo.forge)")
    end
end

"""
    build_readme_url(repo::RepoIdentifier) -> String

Build URL to fetch raw README content.
"""
function build_readme_url(repo::RepoIdentifier, branch::String="main")::String
    if repo.forge == :github
        return "https://raw.githubusercontent.com/$(repo.owner)/$(repo.name)/$(branch)/README.md"
    elseif repo.forge == :gitlab
        encoded_path = URIs.escapeuri("$(repo.owner)/$(repo.name)")
        return "https://gitlab.com/api/v4/projects/$(encoded_path)/repository/files/README.md/raw?ref=$(branch)"
    elseif repo.forge == :bitbucket
        return "https://bitbucket.org/$(repo.owner)/$(repo.name)/raw/$(branch)/README.md"
    else
        error("Unsupported forge: $(repo.forge)")
    end
end
