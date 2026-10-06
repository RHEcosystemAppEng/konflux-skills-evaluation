# Changelog

## Unreleased

*Nothing yet.*

## 0.1.0

### Added

- Initial version, extracted from agentic-plugins' `.tekton/tasks/discover-changed-skills.yaml`.
- Diffs every catalog item's registered SHA against the current SHA (via a
  full-history clone) and returns the ones that changed.
- No behavior change from the agentic-plugins original: this version adds
  `git-clone-url`/`detect-script-path`/`git-ssl-no-verify`/
  `git-token-secret-name`/`git-token-secret-key` params (all defaulted to
  the previously-hardcoded values) so the Task is reusable by other
  GitLab-hosted repositories following the same bookkeeping convention,
  plus the `app.kubernetes.io/version` label / `tekton.dev/tags`
  annotation.
