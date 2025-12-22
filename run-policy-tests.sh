#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POLICY_ROOT="${ROOT}/policies"
PASSED=0
FAILED=0

echo "Applying ValidatingAdmissionPolicies and testing examples..."

# Ensure test namespace with required Pod Security labels exists
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: policy-test
  labels:
    pss.security.kolteq.com/enforce: restricted
    pss.security.kolteq.com/audit: restricted
    pss.security.kolteq.com/warn: restricted
EOF

while IFS= read -r policy; do
  policy_dir="$(dirname "$policy")"
  policy_id="${policy_dir#${POLICY_ROOT}/}"
  binding="${policy_dir}/binding.yaml"
  example="${policy_dir}/test.yaml"

  if [[ -f "$example" ]]; then
    use_example="$example"
  else
    echo "⚠️  No test found for ${policy}; skipping"
    FAILED=$((FAILED + 1))
    break
  fi

  echo "---- ${policy_id} ----"
  echo "Policy:  ${policy}"
  echo "Example: ${use_example}"

  command_line="$(awk -F'Command: ' '/^# Command: /{print $2; exit}' "$use_example")"
  if [[ -z "${command_line}" ]]; then
    # First, ensure the manifest would be accepted without the policy (basic validity)
    set +e
    precheck_output="$(kubectl apply --dry-run=server -f "$use_example" 2>&1)"
    precheck_status=$?
    set -e
    if [[ $precheck_status -ne 0 ]]; then
      echo "❌  Example is not valid without policy:"
      echo "$precheck_output"
      FAILED=$((FAILED + 1))
      break
    fi
  fi

  kubectl apply -f "$policy"
  if [[ -f "$binding" ]]; then
    kubectl apply -f "$binding"
  else
    echo "⚠️  No binding found for ${policy_dir}; skipping test"
    FAILED=$((FAILED + 1))
    break
  fi

  sleep 3
  set +e
  if [[ -n "${command_line}" ]]; then
    echo "Applying test manifest..."
    apply_output="$(kubectl apply -f "$use_example" 2>&1)"
    apply_status=$?
    if [[ $apply_status -ne 0 ]]; then
      echo "❌  Failed to apply test manifest:"
      echo "$apply_output"
      FAILED=$((FAILED + 1))
      set -e
      break
    fi

    echo "Command: ${command_line}"
    output="$(eval "${command_line}" 2>&1)"
    status=$?
  else
    output="$(kubectl apply --dry-run=server -f "$use_example" 2>&1)"
    status=$?
  fi
  set -e

  if [[ $status -eq 0 ]]; then
    echo "❌  Example was admitted; expected denial"
    echo "    example: ${use_example}"
    FAILED=$((FAILED + 1))
    break
  else
    echo "✅  Denied as expected"
    PASSED=$((PASSED + 1))
  fi

  if [[ -n "${command_line}" ]]; then
    kubectl delete -f "$use_example"
  fi
  kubectl delete -f "$binding"
  kubectl delete -f "$policy"
  sleep 2
done < <(find "$POLICY_ROOT" -name "policy.yaml" | sort)

echo "-------------------------------"
echo "Passed: ${PASSED}  Failed: ${FAILED}"

if [[ $FAILED -ne 0 ]]; then
  exit 1
fi
