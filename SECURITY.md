# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in git-seo, please report it responsibly.

### How to Report

1. **Do NOT** create a public GitHub/GitLab issue for security vulnerabilities
2. Email: rhodium-standard@proton.me
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Any suggested fixes (optional)

### Response Timeline

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 7 days
- **Resolution Target**: Within 30 days for critical issues

### What to Expect

1. Acknowledgment of your report
2. Regular updates on progress
3. Credit in release notes (unless you prefer anonymity)
4. Coordinated disclosure timeline

## Security Measures

### API Token Handling

git-seo may use API tokens for GitHub/GitLab/Bitbucket access:

- Tokens are read from environment variables only (`GITHUB_TOKEN`, `GITLAB_TOKEN`, `BITBUCKET_TOKEN`)
- Tokens are never logged or stored
- HTTPS only for all API communications

### Network Security

- All API requests use HTTPS
- No HTTP fallback
- User-Agent identification for transparency

### Dependencies

- Minimal dependency footprint
- Julia packages from official General registry
- Regular dependency audits

## Scope

This security policy applies to:

- The git-seo CLI tool
- Official releases and packages
- Documentation and examples

## Out of Scope

- Third-party forks or modifications
- User-provided API tokens (user responsibility)
- Issues in underlying Julia packages (report to respective maintainers)
