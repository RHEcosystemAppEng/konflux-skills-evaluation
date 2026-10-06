# aggregate-fanout-result task

Aggregates a fanned-out `Matrix`'s per-item results (e.g. from a Task like
[aeh-skill-eval](../aeh-skill-eval/README.md), one leg per catalog item)
into one standardized Konflux `TEST_OUTPUT`, via a caller-supplied
aggregation script (default `scripts/aggregate_fanout_result.py`). Set
`fail-on-non-success` to `"true"` to use this as a hard gate (fails the
pipeline when the aggregated result isn't `SUCCESS`); leave it `"false"`
(the default) to stay purely informational.

Already fully generic: consumes its caller's own trusted Source Artifact
(not a hardcoded repository), so it needs no Trusted Artifacts variant --
it already *is* a Trusted-Artifact-based Task.

## Parameters

| name | description | default value | required |
|---|---|---|---|
| SOURCE_ARTIFACT | Trusted Source Artifact (e.g. `clone-repository`'s `SOURCE_ARTIFACT` result) containing `aggregate-script-path` at the revision being built. | | true |
| aggregate-script-path | Path, relative to the Source Artifact's root, of the aggregation script to run. | `"scripts/aggregate_fanout_result.py"` | false |
| should-evaluate | Only affects the note text in the trivial "nothing to evaluate" case; passed straight through to `aggregate-script-path`. | `"true"` | false |
| changed-skills | `array`. Item identifiers, same order as `eval-outcomes`. | `[]` | false |
| eval-outcomes | `array`. Per-item `TEST_OUTPUT` JSON strings, same order/length as `changed-skills`. | `[]` | false |
| fail-on-non-success | When `"true"`, this Task exits non-zero if the aggregated result isn't `SUCCESS`. | `"false"` | false |

## Results

| name | description |
|---|---|
| TEST_OUTPUT | Standardized Konflux test output, aggregated across every item's result. |

## Secrets

None -- this Task uses no Secrets.

No ConfigMaps are used by this Task.

## Aggregation script CLI contract

Any script passed via `aggregate-script-path` must accept:

```text
<script> --changed-skills <id>... --eval-outcomes <json>... \
  --should-evaluate <bool> [--fail-on-non-success] --output <path>
```

## Usage

As a hard gate (fails the pipeline on a non-SUCCESS aggregate):

```yaml
- name: gate-tier-a-results
  runAfter: [evaluate-skill]
  taskRef:
    resolver: bundles
    params:
    - name: name
      value: aggregate-fanout-result
    - name: bundle
      value: "quay.io/ecosystem-appeng/konflux-skill-evaluation/aggregate-fanout-result:0.1.0@sha256:bc68d175c2a61dc5c90f5cd578bae824932376adace7349c782fab1dad883649"
    - name: kind
      value: task
  params:
  - name: SOURCE_ARTIFACT
    value: $(tasks.clone-repository.results.SOURCE_ARTIFACT)
  - name: changed-skills
    value: $(tasks.discover-changed-skills.results.changed-skills[*])
  - name: eval-outcomes
    value: $(tasks.evaluate-skill.results.TEST_OUTPUT_TIER_A[*])
  - name: fail-on-non-success
    value: "true"
```

As an informational-only aggregate (never fails the pipeline), simply omit
`fail-on-non-success` (or set it to `"false"`).
