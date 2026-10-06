# Changelog

## Unreleased

*Nothing yet.*

## 0.1.0

### Added

- Initial version, extracted from agentic-plugins' `.tekton/tasks/aeh-skill-eval.yaml`.
- Runs a single catalog item's full Tier A (security/SKILL.md scan, always)
  and Tier B (LLM evaluation, opt-in) evaluation chain as one Task, so a
  Tekton `Matrix` can fan out over it natively.
- No behavior change from the agentic-plugins original: this version only
  threads existing `$(params.*)` usages through step-level `env:` entries
  (required by this repo's Tekton Security Task Lint) and adds the
  `app.kubernetes.io/version` label / `tekton.dev/tags` annotation.
