# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal portfolio website (liskl.com) for Loren Lisk. It's a static HTML site built using a simple template system, packaged as an nginx container image and served from a self-hosted Kubernetes homelab cluster. It moved off AWS S3 and CloudFront in 2026; nothing deploys to AWS any more.

## Architecture

### Template-Based Build System

The site uses a simple bash-based template concatenation system:

- **Source templates**: `src/*.tmpl` files contain HTML fragments
- **Build script**: `src/generate_site.sh` concatenates templates (header + content + footer)
- **Output**: Generated HTML files in `site/` directory

Template structure:
- `header.tmpl` - Common HTML head, CSS imports, navigation
- `footer.tmpl` - Closing tags, JavaScript imports
- Content templates (`index.tmpl`, `server.tmpl`, `powerwall.tmpl`, etc.) - Page-specific content

### Site Structure

```
site/                      # Deployable static content
├── index.html            # Homepage (generated from templates)
├── resume/               # Resume page
├── gallery/              # Gallery pages
├── assets/               # Static assets (CSS, JS, images)
├── recommendations.json  # LinkedIn recommendations data
└── *.html               # Other pages (email, server, powerwall, error)
```

Granular breakdown:

- `src/` - Template source files (edit these)
- `site/` - Generated output (baked into the nginx image that the homelab cluster serves)
- `site/assets/css/` - Stylesheets (Bootstrap 4, custom CSS)
- `site/assets/js/` - JavaScript (jQuery, Bootstrap, custom)
- `site/assets/img/` - Images
- `site/assets/pdf/` - PDFs (resumes, certificates)
- `site/resume/` - Resume-related static files

#### CSS Files

- `main.css` - Primary site styles
- `recommend.css` - Recommendations section styling
- `print.css` - Print media styles
- `bootstrap.min.css` - Bootstrap 4.5.3

### Release and Deployment Pipeline

GitHub Actions workflow (`.github/workflows/main.yml`), on every push to `master` (in practice, every merged pull request):
1. Computes the next version from the commits since the last tag with `mathieudutour/github-tag-action` (conventional commits) and pushes the `vX.Y.Z` tag:
   - `feat:` bumps the minor (`v0.2.2` -> `v0.3.0`)
   - `fix:`, `chore:`, `docs:` and anything else bump the patch (`default_bump: patch`)
   - a `BREAKING CHANGE` bumps the major
2. Builds the `Dockerfile` and pushes `ghcr.io/liskl/com_liskl_frontend:vX.Y.Z` and `:latest`. The image name uses underscores; this repo's name uses a hyphen.

The cluster side lives in the private `liskl/homelab` repo under `deploy/kustomize/com_liskl_frontend/`, whose `CLAUDE.md` is the runbook. Flux image automation picks up the new `vX.Y.Z` tag (a semver policy on `^vX.Y.Z$`), commits the bump to that repo and rolls the Deployment that serves `liskl.com` and `www.liskl.com`. From merge to live takes up to about 2 hours.

## Development Commands

### Build the site
```bash
cd src
./generate_site.sh
```

This regenerates all HTML files in `site/` from the template sources.

### Local testing with Docker
```bash
# Build and run locally
docker-compose up --build

# Access at http://localhost:8080

# Or build the image only (without running it)
docker build -t frontend .
```

The Dockerfile uses nginx:alpine to serve static content from `site/`. The same Dockerfile is what CI builds and pushes to `ghcr.io/liskl/com_liskl_frontend` for the homelab deployment.

### Rolling out sooner
There is no manual deploy: a merge to `master` is the release. To roll it out before the automation intervals come round, from a machine with access to the homelab cluster:
```bash
flux -n default reconcile image update image-updater
flux -n flux-system reconcile kustomization com-liskl-frontend
```

## Key Files

- `src/generate_site.sh` - Build script that concatenates templates
- `site/recommendations.json` - Structured data for LinkedIn recommendations display
- `.github/workflows/main.yml` - CI/CD pipeline configuration
- `docker-compose.yaml` - Local development environment

## Making Changes

1. **Editing page content**: Modify the appropriate `.tmpl` file in `src/`
2. **Editing header/footer**: Modify `src/header.tmpl` or `src/footer.tmpl` (affects all pages)
3. **Rebuild**: Run `src/generate_site.sh` to regenerate HTML
4. **Test locally** (optional): `docker-compose up` and verify at `http://localhost:8080`
5. **Deploy**: Open a pull request against `master`. It needs one approving review (an admin can merge their own PR without it), and merging releases and deploys it

## Content Structure

### Recent News Section (`src/index.tmpl`)

The "Recent News" section follows a specific chronological structure:

**Format for 2024 and later:**
- Use specific dates (e.g., `<strong>Nov 2024</strong>`) for notable events
- Include full month and year for conferences and significant milestones
- Can have multiple date entries per year

**Format for years before 2024:**
- Use only the year (e.g., `<strong>2022</strong>`)
- No month or day information
- Single consolidated list per year
- All entries for that year grouped under one `<li>` with nested `<ul class='sub'>`

**Example structure:**
```html
<li>
  <strong>2022</strong>
  <ul class='sub'>
    <li class='sub'>Started role as Staff DevOps Engineer</li>
    <li class='sub'>Published blog post about XYZ</li>
    <li class='sub'>Key Focus Areas:
      <ul class='sub'>
        <li class='sub'>Technology or project area</li>
      </ul>
    </li>
  </ul>
</li>
```

### Social Media Links

Social media icons are displayed in the header (right-aligned). Current platforms:
- LinkedIn: `https://www.linkedin.com/in/liskl`
- GitHub: `https://github.com/liskl`
- X (Twitter): `https://x.com/loren_lisk`

Icons are served from `site/assets/img/` (linkedin-logo.png, github-logo.png, x-logo.png)

## Common Workflows

### Adding Recent Activities

1. Research recent activities from public sources:
   - GitHub contributions: `gh search prs --author=liskl`
   - X.com: `https://x.com/loren_lisk`
   - LinkedIn: Professional updates
   - Conference attendance (KubeCon, CNCF events)

2. Update `src/index.tmpl` in the "Recent News" section
   - For current year: Add specific dated entries
   - For past years: Update consolidated year entry
   - Include "Key Focus Areas" for technical work

3. Rebuild site: `cd src && ./generate_site.sh`

4. Commit changes with descriptive message

### Anonymization Requirements

When adding work-related content:
- **DO NOT** include specific company names (use generic descriptions like "Staff DevOps Engineer")
- **DO NOT** include JIRA ticket IDs or internal tracking numbers
- **DO NOT** include pull request counts or quantitative metrics
- **DO** include technical details, technologies used, and architectural patterns
- **DO** keep conference names, certifications, and public blog posts

### Feature Branch Workflow

For significant updates:
1. Create feature branch: `git checkout -b feat/descriptive-name`
2. Make changes and rebuild site after each template edit
3. Commit frequently with clear messages
4. When complete, open a pull request against `master`; merging triggers the release and the homelab rollout

Example branch naming:
- `feat/update-recent-activities` - Adding new content
- `feat/add-kubecon-2025` - Adding conference attendance
- `fix/broken-links` - Fixing issues

## Important Notes

- Always rebuild the site after template changes using `generate_site.sh`
- The `site/` directory contains generated files - don't edit them directly
- Asset URLs and internal page links use root-relative paths (e.g. `/assets/css/main.css`, `/server.html`) so the site renders correctly regardless of hostname (local Docker, the homelab gateway, any hostname). Do NOT hardcode `https://www.liskl.com/...` for in-repo resources. External links (LinkedIn, GitHub, etc.) stay absolute. Exception: `site/.well-known/keybase.txt` — the absolute URL there is a Keybase verification token and must not be changed.
- Recommendations are loaded from `site/recommendations.json` (not dynamically fetched)
- When consolidating yearly entries, preserve ALL content - only remove duplicate year headers
