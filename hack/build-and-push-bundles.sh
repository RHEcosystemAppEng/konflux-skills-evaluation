#!/usr/bin/env bash
# Builds and pushes a Tekton bundle image for one or more Tasks in this
# repo, then resolves and prints the pushed image's digest so it can be
# pinned in a consuming pipeline's taskRef (the same
# `name@sha256:<digest>` form used throughout agentic-plugins' own
# pipelines for the official konflux-ci/tekton-catalog bundles).
#
# This script is NOT run automatically by any CI workflow in this repo --
# it's a manual tool for whoever has registry push credentials. See the
# top-level README.md's "Getting bundle images" section.
#
# Requirements: tkn (>=0.31, `tkn bundle push` is experimental), skopeo, yq,
# and registry credentials already configured (e.g. `podman login` /
# `docker login`, or pass --remote-username/--remote-password via
# TKN_BUNDLE_PUSH_EXTRA_ARGS below).
#
# Usage:
#   REGISTRY_BASE=quay.io/ai5-marketplace/konflux-tasks \
#     hack/build-and-push-bundles.sh [task-name ...]
#
#   # No task names => build+push every task/*/*.yaml in the repo.
#   hack/build-and-push-bundles.sh
#
#   # Build+push just one task:
#   hack/build-and-push-bundles.sh aeh-skill-eval

set -o errexit
set -o nounset
set -o pipefail

REGISTRY_BASE="${REGISTRY_BASE:-quay.io/ai5-marketplace/konflux-tasks}"
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

for cmd in tkn skopeo yq; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: required command '$cmd' not found in PATH" >&2
    exit 1
  fi
done

if [ "$#" -gt 0 ]; then
  TASK_NAMES=("$@")
else
  TASK_NAMES=()
  for task_yaml in task/*/*.yaml; do
    # Only flat-layout top-level task files (task/<name>/<name>.yaml), per
    # this repo's recommended structure -- skip nested/legacy/recipe files.
    name=$(basename "$task_yaml" .yaml)
    dir=$(basename "$(dirname "$task_yaml")")
    if [ "$name" = "$dir" ]; then
      TASK_NAMES+=("$name")
    fi
  done
fi

if [ "${#TASK_NAMES[@]}" -eq 0 ]; then
  echo "ERROR: no tasks found under task/*/*.yaml" >&2
  exit 1
fi

echo "Registry base: ${REGISTRY_BASE}"
echo "Tasks to build: ${TASK_NAMES[*]}"
echo

for task_name in "${TASK_NAMES[@]}"; do
  task_file="task/${task_name}/${task_name}.yaml"
  if [ ! -f "$task_file" ]; then
    echo "ERROR: ${task_file} does not exist" >&2
    exit 1
  fi

  version=$(yq '.metadata.labels["app.kubernetes.io/version"]' "$task_file")
  if [ -z "$version" ] || [ "$version" = "null" ]; then
    echo "ERROR: ${task_file} has no app.kubernetes.io/version label" >&2
    exit 1
  fi

  image_ref="${REGISTRY_BASE}/${task_name}:${version}"
  echo "=== Building and pushing ${task_name} (version ${version}) -> ${image_ref} ==="

  # shellcheck disable=SC2086  # intentional word-splitting of extra tkn args
  tkn bundle push "$image_ref" -f "$task_file" ${TKN_BUNDLE_PUSH_EXTRA_ARGS:-}

  digest=$(skopeo inspect "docker://${image_ref}" | yq -p=json '.Digest')
  echo "Pushed: ${image_ref}@${digest}"
  echo "Pin this in your pipeline's taskRef as:"
  echo "  ${image_ref}@${digest}"
  echo
done
