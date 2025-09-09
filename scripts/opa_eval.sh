#!/usr/bin/env bash
set -euo pipefail

# Requires tfplan.json already created
if [ ! -f tfplan.json ]; then
  echo "tfplan.json not found. Did you run terraform plan + show -json?" >&2
  exit 2
fi

# Evaluate OPA result object
OUT=$(opa eval --input=tfplan.json --data=policy 'data.terraform.cloudtrail.result' -f json)
PASSED=$(echo "$OUT" | jq -r '.result[0].expressions[0].value.passed')
MSGS=$(echo "$OUT" | jq -r '.result[0].expressions[0].value.messages[]?' || true)

echo "OPA result passed=$PASSED"
if [ -n "$MSGS" ]; then
  echo "OPA messages:"
  echo "$MSGS"
fi

if [ "$PASSED" != "true" ]; then
  echo "OPA policy checks failed." >&2
  exit 1
fi
