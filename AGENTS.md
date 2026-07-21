# x-cmd-build/xz — agent notes

> **Public-facing agent note** for `x-cmd-build/xz`.
>
> Full design / audit / decision docs live in the private
> **`x-cmd-build/mneme`** design HQ (mirrors `ljh-sh/mneme` patterns).
>
> **mneme is the design HQ** for all `x-cmd-build/*` repos. Public
> repos stay clean (code + release artifacts); mneme holds the messy
> iteration.

## TL;DR for AI agents

- **What**: portable xz-utils @ 5.8.3 (post-CVE-2024-3094), 5-platform
  CI build.
- **Source**: vendored under `upstream/xz/` (gitignore everything
  except intentional vendored source).
- **Build**: GitHub Actions only (`build-and-test.yml` + `release.yml`).
  **No local builds** (per `feedback-ci-only-no-local-dev`).
- **Do NOT modify**: anything under `upstream/xz/`.
- **All build flags**: see `build-review.md` §2.

## Issue & PR conventions

- **Public issues**: end-user bug reports / install problems.
- **Design / audit / roadmap**: GitHub issues on
  [`x-cmd-build/mneme`](https://github.com/x-cmd-build/mneme) (private,
  but issues can be opened by collaborators).

## License

- **Our wrapper code** (scripts, workflows, docs): BSD-3-Clause
- **Vendored xz-utils**: mixed — see `NOTICE.md` and `upstream/xz/COPYING*`