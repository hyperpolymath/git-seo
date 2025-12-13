# git-seo

Make your Git repositories discoverable.

## What is Git SEO?

Just like web SEO helps pages rank in search engines, Git SEO helps repositories get discovered on GitHub, GitLab, Bitbucket, and across git forges.

## Key Factors

### Repository Metadata
- **Name**: Descriptive, kebab-case, keyword-rich (`awesome-static-site-generator` > `my-ssg`)
- **Description**: 350 chars max, include primary keywords
- **Topics**: Add 5-10 relevant tags (GitHub: Settings → Topics)
- **License**: MIT/Apache/GPL signals legitimacy

### README.md
- Badges (build status, version, downloads)
- Clear one-liner description
- Install instructions
- Usage examples with code blocks
- Screenshots/GIFs for visual projects
- Contributing section

### Social Signals
- Stars, Forks, Watchers
- Issues (active discussion = alive project)
- Pull Requests (community engagement)
- Contributors list

### Code Quality
- Consistent commit history
- Semantic versioning with tags
- Changelog/Releases
- CI/CD badges
- Code coverage

## Tools

### Analyze
```bash
git-seo analyze <repo-url>
```

### Optimize
```bash
git-seo optimize --topics --readme --badges
```

### Compare
```bash
git-seo compare <repo1> <repo2>
```

## Installation

```bash
# Coming soon
pip install git-seo
```

## Status

🚧 **Work in Progress** - This is a concept/specification. Implementation coming.

## License

MIT
