#!/bin/bash
# Creates a dummy GitLab token Secret so update-registered-shas' (required,
# non-optional) secretKeyRef can resolve. The test exercises the
# should-evaluate="false" no-op path, so the token's actual value is never
# used -- only its presence matters for the pod to start.
set -e

TEST_NS="$2"

kubectl create secret generic test-dummy-gitlab-sa \
  --from-literal=password=dummy-token \
  -n "$TEST_NS" --dry-run=client -o yaml | kubectl apply -f -

echo "Pre-requirements setup complete for namespace: $TEST_NS"
