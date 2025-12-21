# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal website for Loren Lisk (www.liskl.com) - a static site served via Nginx, deployed to AWS S3 with CloudFront CDN.

## Build Commands

```bash
# Generate HTML pages from templates
cd src && ./generate_site.sh

# Run locally with Docker
docker-compose up
# Site available at http://localhost:8080

# Build Docker image only
docker build -t frontend .
```

## Architecture

### Template System

Pages are assembled by concatenating template fragments in `src/`:

```
header.tmpl + <page>.tmpl + footer.tmpl → site/<page>.html
```

The `generate_site.sh` script handles all page generation:
- `index.tmpl` → `site/index.html` (main homepage)
- `server.tmpl` → `site/server.html`
- `powerwall.tmpl` → `site/powerwall.html`
- `email.tmpl` → `site/email.html`
- `gallery-liskl-networks-datacenter.tmpl` → `site/gallery/liskl-networks-datacenter.html`

### Directory Structure

- `src/` - Template source files (edit these)
- `site/` - Generated output (served by Nginx, deployed to S3)
- `site/assets/css/` - Stylesheets (Bootstrap 4, custom CSS)
- `site/assets/js/` - JavaScript (jQuery, Bootstrap, custom)
- `site/assets/img/` - Images
- `site/assets/pdf/` - PDFs (resumes, certificates)
- `site/resume/` - Resume-related static files

### Deployment

GitHub Actions workflow (`.github/workflows/main.yml`) on push to master:
1. Syncs `site/` to S3 bucket `www.liskl.com`
2. Invalidates CloudFront distribution

Uses OIDC for AWS authentication (role: `github-website-upload`).

## CSS Files

- `main.css` - Primary site styles
- `recommend.css` - Recommendations section styling
- `print.css` - Print media styles
- `bootstrap.min.css` - Bootstrap 4.5.3

## Development Workflow

1. Edit templates in `src/`
2. Run `./generate_site.sh` from `src/` directory
3. Test locally with `docker-compose up`
4. Commit and push to master for automatic deployment
