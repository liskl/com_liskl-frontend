# AGENTS.md

Guidance for coding agents (and humans) working in this repository.

## What this is

liskl.com, Loren Lisk's personal site. Plain HTML assembled from templates by a bash script, baked into an nginx image and served from a self-hosted Kubernetes homelab cluster. There is no JS build, no package manager and no test suite. The site moved off AWS S3 and CloudFront in 2026; nothing deploys to AWS any more.

## Where to edit

| Path | What it is | Edit it? |
| --- | --- | --- |
| `src/*.tmpl` | Page templates | Yes |
| `src/generate_site.sh` | Concatenates `header.tmpl` + page template + `footer.tmpl` into `site/` | Only to add a page |
| `site/index.html`, `site/server.html`, `site/powerwall.html`, `site/email.html`, `site/gallery/liskl-networks-datacenter.html` | Generated from `src/`, committed | No. Edit the template and rebuild |
| `site/resume/index.html`, `site/error.html`, `site/recommendations.json`, `site/favicon.ico`, `site/assets/` | Hand-maintained, not generated | Yes, directly |
| `site/.well-known/keybase.txt` | Signed Keybase proof | Never. Any change breaks the verification |
| `Dockerfile` | `nginx:alpine` with `site/` copied into the web root (default nginx config) | Rarely |
| `.github/workflows/main.yml` | Release pipeline, see [Releasing](#releasing) | Rarely |

## Build and preview

```bash
cd src && ./generate_site.sh   # must run from src/, it uses relative paths
docker compose up --build      # then open http://localhost:8080
```

- CI never runs `generate_site.sh`. The image ships whatever `site/` holds in git, so rebuild after every template change and commit the template and the regenerated HTML together.
- `header.tmpl` is only the `<head>` (stylesheets, the AdSense script) and the opening `<body>`. `footer.tmpl` holds the JS includes and closing tags. The visible page header (name plus social icons) is not shared: each page template starts with its own copy.

## Conventions

- **Root-relative URLs** for anything in this repo (`/assets/css/main.css`, `/server.html`), so the site works on any hostname (local Docker, the homelab gateway). Never hardcode `https://www.liskl.com/...` for in-repo resources. External links (LinkedIn, GitHub, and so on) stay absolute.
- **Social links** live in the header block at the top of `index.tmpl`, `server.tmpl`, `powerwall.tmpl`, `email.tmpl` and `gallery-liskl-networks-datacenter.tmpl`, so a change means editing all five. Only `index.tmpl` has the X icon. Profiles: `https://www.linkedin.com/in/liskl`, `https://github.com/liskl`, `https://x.com/loren_lisk`. Icons are 32x32 PNGs in `site/assets/img/` (`linkedin-logo.png`, `github-logo.png`, `x-logo.png`).
- **References** (`#references` in `index.tmpl`) are inline HTML: one `recommend-N` modal per person, highest N first. `site/recommendations.json` holds the same recommendations as data, but no page loads it. Update both when adding one so they don't drift.

## Recent News (`#recent_news` in `src/index.tmpl`)

Newest first. Each entry is an `<li>` holding a `<strong>` heading and a nested `<ul class='sub'>` of `<li class='sub'>` items. Escape `&` as `&amp;`.

- **2024 and later**: a year block (`<strong>2026</strong>`) with `Open Source / Personal Projects:` and `Technologies &amp; Tools:` sub-lists, followed by dated entries for notable events such as conferences and launches, newest first (`<strong>Oct 2026</strong>`, three-letter month). A year can have several dated entries.
- **Before 2024**: exactly one block per year, year only, no months. Year-level items first, then `Technologies &amp; Tools:` and `Key Focus Areas:` sub-lists.
- When merging duplicate year blocks, keep every item and drop only the extra heading.

```html
<li>
  <strong>2022</strong>
  <ul class='sub'>
    <li class='sub'>Started role as Staff DevOps Engineer</li>
    <li class='sub'>Technologies &amp; Tools:
      <ul class='sub'>
        <li class='sub'><strong>Terraform</strong> - What it was used for</li>
      </ul>
    </li>
    <li class='sub'>Key Focus Areas:
      <ul class='sub'>
        <li class='sub'>Technology or project area</li>
      </ul>
    </li>
  </ul>
</li>
```

Sources for new activity: `gh search prs --author=liskl`, https://x.com/loren_lisk, LinkedIn, and conference attendance (KubeCon, CNCF events).

### Anonymizing work content

- No employer names. Describe the role instead ("Staff DevOps Engineer").
- No JIRA ticket IDs or other internal tracking numbers.
- No pull request counts or other quantitative metrics.
- Do include technologies, technical detail and architecture patterns.
- Conference names, certifications and public blog posts are fine.

## Releasing

A merge to `master` is the release. There is no manual deploy.

1. Branch (`feat/...`, `fix/...`, `docs/...`) and open a pull request against `master`. It needs one approving review; an admin can merge their own.
2. On every push to `master`, `.github/workflows/main.yml` runs `mathieudutour/github-tag-action`, which reads the conventional commits since the last tag and pushes the next `vX.Y.Z`: `feat:` bumps the minor, a `BREAKING CHANGE` bumps the major, anything else bumps the patch.
3. The same workflow builds the `Dockerfile` and pushes `ghcr.io/liskl/com_liskl_frontend:vX.Y.Z` and `:latest`. The image name uses underscores; the repo name uses a hyphen.
4. Flux image automation in the private `liskl/homelab` repo (`deploy/kustomize/com_liskl_frontend/`, whose `CLAUDE.md` is the cluster runbook) sees the new tag through a semver policy on `^vX.Y.Z$`, commits the bump there and rolls the Deployment serving `liskl.com` and `www.liskl.com`. Merge to live takes up to about 2 hours.

Use conventional-commit prefixes on commit subjects and PR titles. Squash-merging a multi-commit PR makes the PR title the commit subject, and that subject decides the version bump.

To roll out sooner, from a machine with access to the homelab cluster:

```bash
flux -n default reconcile image update image-updater
flux -n flux-system reconcile kustomization com-liskl-frontend
```
