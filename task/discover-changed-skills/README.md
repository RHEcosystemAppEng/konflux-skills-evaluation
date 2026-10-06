# discover-changed-skills task

Discovers which items in a catalog changed since their registered SHA. Runs
a caller-supplied detection script (default `scripts/detect_changed_skills.py`)
against a full-history clone of the target repository, diffing each item's
registered SHA against the current SHA.

Needs a FULL (non-shallow) history clone to diff against an arbitrarily old
registered SHA, so this Task performs its own authenticated `git clone`
rather than reusing a pipeline's shallow trusted Source Artifact. This is
also why it has no Trusted Artifacts (`-oci-ta`) variant -- see
[.ta-ignore.yaml](../../.ta-ignore.yaml) in the repo root.

Reusable across any GitLab-hosted repository that follows the same
"registered SHA" bookkeeping convention as agentic-plugins (a detection
script importable via
`python3 <detect-script-path> --current-sha ... --repo-root ... --format json`,
emitting a JSON array of changed item identifiers on stdout). The detection
script itself is **not** bundled in this Task -- it must exist in the
repository being cloned, at `detect-script-path`.

## Parameters

| name | description | default value | required |
|---|---|---|---|
| current-sha | Commit SHA under evaluation. | | true |
| git-clone-url | HTTPS clone URL of the repository to check out and diff. | `"https://gitlab.cee.redhat.com/ai5-marketplace/agentic-plugins.git"` | false |
| detect-script-path | Path, relative to the repository root, of the detection script to run. | `"scripts/detect_changed_skills.py"` | false |
| git-ssl-no-verify | When `"true"`, disables TLS certificate verification for the git clone (needed for internal GitLab instances with a private CA). | `"true"` | false |
| git-token-secret-name | Name of the Secret containing a GitLab access token with clone access to the repository. | `"agentic-plugins-gitlab-sa"` | false |
| git-token-secret-key | Key within `git-token-secret-name` holding the GitLab access token. | `"password"` | false |

## Results

| name | description |
|---|---|
| changed-skills | `array`. Identifiers (in `detect-script-path`'s own convention, e.g. `rh-sre/cve-impact`) that changed since their last registered SHA. |

## Workspaces

| name | description |
|---|---|
| source | Scratch workspace the repository is cloned into (at `./repo`). Shared with `update-registered-shas` when that Task needs to push from the same checkout. |

## Secrets

| Secret (param) | Key (param) | Required | Purpose |
|---|---|---|---|
| `git-token-secret-name` (default `agentic-plugins-gitlab-sa`) | `git-token-secret-key` (default `password`) | yes | GitLab access token with clone access, injected into the clone URL as `oauth2:<token>@`. |

No ConfigMaps are used by this Task.

## Usage

```yaml
- name: discover-changed-skills
  runAfter:
  - clone-repository
  taskRef:
    resolver: bundles
    params:
    - name: name
      value: discover-changed-skills
    - name: bundle
      value: "quay.io/ai5-marketplace/konflux-tasks/discover-changed-skills:0.1.0@sha256:<digest>"
    - name: kind
      value: task
  params:
  - name: current-sha
    value: $(params.revision)
  - name: git-clone-url
    value: "https://gitlab.cee.redhat.com/my-group/my-project.git"
  - name: git-token-secret-name
    value: "my-gitlab-sa"
  workspaces:
  - name: source
    workspace: orchestrator-workspace
```

Consume the result downstream as a Matrix source, e.g.
`$(tasks.discover-changed-skills.results.changed-skills[*])`.
