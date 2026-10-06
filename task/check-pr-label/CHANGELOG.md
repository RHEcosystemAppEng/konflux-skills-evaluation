# Changelog

## Unreleased

*Nothing yet.*

## 0.1.0

### Added

- Initial version, extracted from agentic-plugins' `.tekton/tasks/check-pr-label.yaml`.
- Checks whether the merged MR for a commit SHA on a GitLab project carries
  a given label.
- No behavior change from the agentic-plugins original: this version adds
  `label-name`/`gitlab-server-url`/`gitlab-project-path`/
  `git-token-secret-name`/`git-token-secret-key` params (all defaulted to
  the previously-hardcoded values) so the Task is reusable by other
  GitLab-hosted projects, plus the `app.kubernetes.io/version` label /
  `tekton.dev/tags` annotation.
