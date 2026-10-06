# check-pr-label task

Checks whether the **merged** merge request for a given commit SHA on a
GitLab project carries a given label. Returns `"true"` only in that case;
`"false"` otherwise, including when no merged MR is found at all
(fail-closed).

Intended to gate an expensive/opt-in chain later in a pipeline (e.g. an LLM
evaluation step) behind an explicit label on the merged MR, so that
expensive work only runs when a human reviewer opted in.

GitLab-specific by design (calls the GitLab REST API directly), but
reusable by **any** GitLab-hosted project -- every GitLab-specific detail is
a parameter.

## Parameters

| name | description | default value | required |
|---|---|---|---|
| current-sha | Commit SHA to look up merge requests for. | | true |
| label-name | Label that must be present on the merged MR for this result to be `"true"`. | `"evaluate"` | false |
| gitlab-server-url | Base URL of the GitLab server hosting the project. | `"https://gitlab.cee.redhat.com"` | false |
| gitlab-project-path | URL-encoded `namespace%2Fproject` path of the GitLab project. | `"ai5-marketplace%2Fagentic-plugins"` | false |
| git-token-secret-name | Name of the Secret containing a GitLab access token with API read access to the project. | `"agentic-plugins-gitlab-sa"` | false |
| git-token-secret-key | Key within `git-token-secret-name` holding the GitLab access token. | `"password"` | false |

## Results

| name | description |
|---|---|
| should-evaluate | `"true"` only if a MERGED MR for `current-sha` carries the `label-name` label; `"false"` otherwise. |

## Secrets

| Secret (param) | Key (param) | Required | Purpose |
|---|---|---|---|
| `git-token-secret-name` (default `agentic-plugins-gitlab-sa`) | `git-token-secret-key` (default `password`) | yes | GitLab personal/project access token with `read_api` scope, used to query merge requests for a commit. |

No ConfigMaps are used by this Task.

## Usage

```yaml
- name: check-pr-label
  taskRef:
    resolver: bundles
    params:
    - name: name
      value: check-pr-label
    - name: bundle
      value: "quay.io/ai5-marketplace/konflux-tasks/check-pr-label:0.1.0@sha256:<digest>"
    - name: kind
      value: task
  params:
  - name: current-sha
    value: $(params.revision)
  - name: label-name
    value: "evaluate"
  - name: gitlab-server-url
    value: "https://gitlab.cee.redhat.com"
  - name: gitlab-project-path
    value: "my-group%2Fmy-project"
  - name: git-token-secret-name
    value: "my-gitlab-sa"
```

Consume the result downstream as `$(tasks.check-pr-label.results.should-evaluate)`,
e.g. as a `when:` expression gating a later Task/Matrix.
