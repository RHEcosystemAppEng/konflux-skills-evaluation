# Changelog

## Unreleased

*Nothing yet.*

## 0.1.0

### Added

- Initial version, extracted from agentic-plugins' `.tekton/tasks/update-registered-shas.yaml`.
- Bumps every evaluated catalog item's registered SHA to `current-sha` in a
  single batched commit + push, with a `[skip-fanout]` marker.
- No behavior change from the agentic-plugins original: this version adds
  `register-script-path`/`git-remote-url`/`git-push-branch`/
  `git-ssl-no-verify`/`git-bot-name`/`git-bot-email`/
  `git-token-secret-name`/`git-token-secret-key` params (all defaulted to
  the previously-hardcoded values) so the Task is reusable by other
  GitLab-hosted repositories following the same bookkeeping convention,
  plus the `app.kubernetes.io/version` label / `tekton.dev/tags`
  annotation.
