# Validating Admission Policies from Kubernetes Pod Security Standards

This directory contains standalone `ValidatingAdmissionPolicy` objects and their corresponding bindings following the [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/). You can choose to use `warn`/`audit`/`enforce` modes on the `baseline` or `restricted` policy sets, or pick and choose individual policies to enforce or monitor in specific namespaces.

## Installing the policies

1. Ensure your cluster runs Kubernetes 1.30 or newer (ValidatingAdmissionPolicy is beta/GA starting in that release line).
2. Apply the manifests to the cluster:

   ```bash
   kubectl apply -f ./policies/
   ```

## Choosing enforcement levels

Bindings are provided for three enforcement levels:

| Label | Effect |
| --- | --- |
| `validating-admission-policies.kolteq.com/warn=restricted` | Fails the policy in `Warn` mode so the request succeeds but surfaces a server-side warning. |
| `validating-admission-policies.kolteq.com/audit=baseline` | Triggers the `Audit` action (shows up in the API audit log). |
| `validating-admission-policies.kolteq.com/enforce=restricted` | Denies non-compliant requests (`validationActions: Deny`). |

Add the appropriate label to a namespace to subscribe it to the full restricted policy bundle at that enforcement level:

```bash
kubectl label namespace team-payments validating-admission-policies.kolteq.com/enforce=restricted --overwrite
```

Deleting the label stops the binding from matching new objects in that namespace.

## Opting individual policies in or out

Every manifest uses namespace labels to let you override the global behavior:

- Set `validating-admission-policies.kolteq.com/<policy-name>=false` to opt a namespace out of a specific policy even if the namespace has a global `warn`, `audit`, or `enforce` label.
- Set `<policy-name>.validating-admission-policies.kolteq.com/<warn|audit|enforce>=<any-value>` (we use `true`) to opt a namespace into just that policy with the desired enforcement mode.

Examples:

```bash
# Disable the privileged container check in a namespace that still receives the rest of the restricted set.
kubectl label namespace platform validating-admission-policies.kolteq.com/privileged-containers=false --overwrite

# Opt a CI namespace into the seccomp policy with Warn-level feedback.
kubectl label namespace ci seccomp-profile-pod.validating-admission-policies.kolteq.com/warn=true --overwrite

# Opt the same namespace into the run-as-nonroot policy but only write to the audit log.
kubectl label namespace ci run-as-nonroot-containers.validating-admission-policies.kolteq.com/audit=true --overwrite

# Enforce the disallow-privilege-escalation policy in the same namespace.
kubectl label namespace ci allow-privilege-escalation-containers.validating-admission-policies.kolteq.com/enforce=true --overwrite
```

Remove the label (or set it to an empty value) to fall back to the namespace-wide defaults again.

## Example namespaces

Sample manifests under `examples/namespaces/` demonstrate how to combine the labels:

- `restricted-payments-namespace.yaml` shows a namespace subscribed to the full restricted set with a couple of explicit opt-outs.
- `ci-seccomp-optin-namespace.yaml` shows a namespace that opts into three individual policies by setting `<policy>.validating-admission-policies.kolteq.com/<warn|audit|enforce>=true`.
- `staging-audit-namespace.yaml` demonstrates running the full suite in `Audit` mode while selectively disabling `run-as-user-pod` and opting into seccomp with `warn`.
- `prod-mixed-optin-namespace.yaml` keeps the namespace on full `enforce=restricted` while forcing a few additional policies (hostNetwork, privileged containers) and downgrading `allowed-sysctls` to warnings via the per-policy labels.

## Policy label reference

Use the following table to look up the opt-in/opt-out label for each manifest in this directory.

| Policy manifest | Opt-out label key | Opt-in label keys |
| --- | --- | --- |
| `allow-privilege-escalation-containers.yaml` | `validating-admission-policies.kolteq.com/allow-privilege-escalation-containers` | `allow-privilege-escalation-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `allow-privilege-escalation-ephemeralcontainers.yaml` | `validating-admission-policies.kolteq.com/allow-privilege-escalation-ephemeralcontainers` | `allow-privilege-escalation-ephemeralcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `allow-privilege-escalation-initcontainers.yaml` | `validating-admission-policies.kolteq.com/allow-privilege-escalation-initcontainers` | `allow-privilege-escalation-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `allowed-capabilities-add-containers.yaml` | `validating-admission-policies.kolteq.com/allowed-capabilities-add-containers` | `allowed-capabilities-add-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `allowed-capabilities-add-ephemeralcontainers.yaml` | `validating-admission-policies.kolteq.com/allowed-capabilities-add-ephemeralcontainers` | `allowed-capabilities-add-ephemeralcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `allowed-capabilities-add-initcontainers.yaml` | `validating-admission-policies.kolteq.com/allowed-capabilities-add-initcontainers` | `allowed-capabilities-add-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `allowed-hostports-containers.yaml` | `validating-admission-policies.kolteq.com/allowed-hostports-containers` | `allowed-hostports-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `allowed-hostports-ephemeralcontainers.yaml` | `validating-admission-policies.kolteq.com/allowed-hostports-ephemeralcontainers` | `allowed-hostports-ephemeralcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `allowed-hostports-initcontainers.yaml` | `validating-admission-policies.kolteq.com/allowed-hostports-initcontainers` | `allowed-hostports-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `allowed-sysctls.yaml` | `validating-admission-policies.kolteq.com/allowed-sysctls` | `allowed-sysctls.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `allowed-volume-types.yaml` | `validating-admission-policies.kolteq.com/allowed-volume-types` | `allowed-volume-types.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `apparmor-annotation-values.yaml` | `validating-admission-policies.kolteq.com/apparmor-annotation-values` | `apparmor-annotation-values.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `apparmor-profile-containers.yaml` | `validating-admission-policies.kolteq.com/apparmor-profile-containers` | `apparmor-profile-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `apparmor-profile-ephemeralcontainers.yaml` | `validating-admission-policies.kolteq.com/apparmor-profile-ephemeralcontainers` | `apparmor-profile-ephemeralcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `apparmor-profile-initcontainers.yaml` | `validating-admission-policies.kolteq.com/apparmor-profile-initcontainers` | `apparmor-profile-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `apparmor-profile-pod.yaml` | `validating-admission-policies.kolteq.com/apparmor-profile-pod` | `apparmor-profile-pod.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `capabilities-add-netbindservice-containers.yaml` | `validating-admission-policies.kolteq.com/capabilities-add-netbindservice-containers` | `capabilities-add-netbindservice-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `capabilities-add-netbindservice-ephemeralcontainers.yaml` | `validating-admission-policies.kolteq.com/capabilities-add-netbindservice-ephemeralcontainers` | `capabilities-add-netbindservice-ephemeralcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `capabilities-add-netbindservice-initcontainers.yaml` | `validating-admission-policies.kolteq.com/capabilities-add-netbindservice-initcontainers` | `capabilities-add-netbindservice-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `capabilities-drop-all-containers.yaml` | `validating-admission-policies.kolteq.com/capabilities-drop-all-containers` | `capabilities-drop-all-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `capabilities-drop-all-ephemeralcontainers.yaml` | `validating-admission-policies.kolteq.com/capabilities-drop-all-ephemeralcontainers` | `capabilities-drop-all-ephemeralcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `capabilities-drop-all-initcontainers.yaml` | `validating-admission-policies.kolteq.com/capabilities-drop-all-initcontainers` | `capabilities-drop-all-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `hostipc.yaml` | `validating-admission-policies.kolteq.com/hostipc` | `hostipc.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `hostnetwork.yaml` | `validating-admission-policies.kolteq.com/hostnetwork` | `hostnetwork.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `hostpath-volumes.yaml` | `validating-admission-policies.kolteq.com/hostpath-volumes` | `hostpath-volumes.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `hostpid.yaml` | `validating-admission-policies.kolteq.com/hostpid` | `hostpid.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `livenessprobe-httpget-host-initcontainers.yaml` | `validating-admission-policies.kolteq.com/livenessprobe-httpget-host-initcontainers` | `livenessprobe-httpget-host-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `livenessprobe-httpget-host.yaml` | `validating-admission-policies.kolteq.com/livenessprobe-httpget-host` | `livenessprobe-httpget-host.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `livenessprobe-tcpsocket-host-containers.yaml` | `validating-admission-policies.kolteq.com/livenessprobe-tcpsocket-host-containers` | `livenessprobe-tcpsocket-host-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `livenessprobe-tcpsocket-host-initcontainers.yaml` | `validating-admission-policies.kolteq.com/livenessprobe-tcpsocket-host-initcontainers` | `livenessprobe-tcpsocket-host-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `poststart-httpget-host-containers.yaml` | `validating-admission-policies.kolteq.com/poststart-httpget-host-containers` | `poststart-httpget-host-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `poststart-httpget-host-initcontainers.yaml` | `validating-admission-policies.kolteq.com/poststart-httpget-host-initcontainers` | `poststart-httpget-host-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `poststart-tcpsocket-host-containers.yaml` | `validating-admission-policies.kolteq.com/poststart-tcpsocket-host-containers` | `poststart-tcpsocket-host-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `poststart-tcpsocket-host-initcontainers.yaml` | `validating-admission-policies.kolteq.com/poststart-tcpsocket-host-initcontainers` | `poststart-tcpsocket-host-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `prestop-httpget-host-containers.yaml` | `validating-admission-policies.kolteq.com/prestop-httpget-host-containers` | `prestop-httpget-host-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `prestop-httpget-host-initcontainers.yaml` | `validating-admission-policies.kolteq.com/prestop-httpget-host-initcontainers` | `prestop-httpget-host-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `prestop-tcpsocket-host-containers.yaml` | `validating-admission-policies.kolteq.com/prestop-tcpsocket-host-containers` | `prestop-tcpsocket-host-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `prestop-tcpsocket-host-initcontainers.yaml` | `validating-admission-policies.kolteq.com/prestop-tcpsocket-host-initcontainers` | `prestop-tcpsocket-host-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `privileged-containers.yaml` | `validating-admission-policies.kolteq.com/privileged-containers` | `privileged-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `privileged-ephemeralcontainers.yaml` | `validating-admission-policies.kolteq.com/privileged-ephemeralcontainers` | `privileged-ephemeralcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `privileged-initcontainers.yaml` | `validating-admission-policies.kolteq.com/privileged-initcontainers` | `privileged-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `procmount-containers.yaml` | `validating-admission-policies.kolteq.com/procmount-containers` | `procmount-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `procmount-ephemeralcontainers.yaml` | `validating-admission-policies.kolteq.com/procmount-ephemeralcontainers` | `procmount-ephemeralcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `procmount-initcontainers.yaml` | `validating-admission-policies.kolteq.com/procmount-initcontainers` | `procmount-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `readinessprobe-httpget-host-containers.yaml` | `validating-admission-policies.kolteq.com/readinessprobe-httpget-host-containers` | `readinessprobe-httpget-host-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `readinessprobe-httpget-host-initcontainers.yaml` | `validating-admission-policies.kolteq.com/readinessprobe-httpget-host-initcontainers` | `readinessprobe-httpget-host-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `readinessprobe-tcpsocket-host-containers.yaml` | `validating-admission-policies.kolteq.com/readinessprobe-tcpsocket-host-containers` | `readinessprobe-tcpsocket-host-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `readinessprobe-tcpsocket-host-initcontainers.yaml` | `validating-admission-policies.kolteq.com/readinessprobe-tcpsocket-host-initcontainers` | `readinessprobe-tcpsocket-host-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `run-as-nonroot-containers.yaml` | `validating-admission-policies.kolteq.com/run-as-nonroot-containers` | `run-as-nonroot-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `run-as-nonroot-ephemeralcontainers.yaml` | `validating-admission-policies.kolteq.com/run-as-nonroot-ephemeralcontainers` | `run-as-nonroot-ephemeralcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `run-as-nonroot-initcontainers.yaml` | `validating-admission-policies.kolteq.com/run-as-nonroot-initcontainers` | `run-as-nonroot-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `run-as-nonroot-pod.yaml` | `validating-admission-policies.kolteq.com/run-as-nonroot-pod` | `run-as-nonroot-pod.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `run-as-user-containers.yaml` | `validating-admission-policies.kolteq.com/run-as-user-containers` | `run-as-user-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `run-as-user-ephemeralcontainers.yaml` | `validating-admission-policies.kolteq.com/run-as-user-ephemeralcontainers` | `run-as-user-ephemeralcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `run-as-user-initcontainers.yaml` | `validating-admission-policies.kolteq.com/run-as-user-initcontainers` | `run-as-user-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `run-as-user-pod.yaml` | `validating-admission-policies.kolteq.com/run-as-user-pod` | `run-as-user-pod.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `seccomp-profile-containers-restricted.yaml` | `validating-admission-policies.kolteq.com/seccomp-profile-containers-restricted` | `seccomp-profile-containers-restricted.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `seccomp-profile-containers.yaml` | `validating-admission-policies.kolteq.com/seccomp-profile-containers` | `seccomp-profile-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `seccomp-profile-ephemeralcontainers-restricted.yaml` | `validating-admission-policies.kolteq.com/seccomp-profile-ephemeralcontainers-restricted` | `seccomp-profile-ephemeralcontainers-restricted.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `seccomp-profile-ephemeralcontainers.yaml` | `validating-admission-policies.kolteq.com/seccomp-profile-ephemeralcontainers` | `seccomp-profile-ephemeralcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `seccomp-profile-initcontainers-restricted.yaml` | `validating-admission-policies.kolteq.com/seccomp-profile-initcontainers-restricted` | `seccomp-profile-initcontainers-restricted.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `seccomp-profile-initcontainers.yaml` | `validating-admission-policies.kolteq.com/seccomp-profile-initcontainers` | `seccomp-profile-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `seccomp-profile-pod-restricted.yaml` | `validating-admission-policies.kolteq.com/seccomp-profile-pod-restricted` | `seccomp-profile-pod-restricted.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `seccomp-profile-pod.yaml` | `validating-admission-policies.kolteq.com/seccomp-profile-pod` | `seccomp-profile-pod.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `selinux-role-containers.yaml` | `validating-admission-policies.kolteq.com/selinux-role-containers` | `selinux-role-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `selinux-role-ephemeralcontainers.yaml` | `validating-admission-policies.kolteq.com/selinux-role-ephemeralcontainers` | `selinux-role-ephemeralcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `selinux-role-initcontainers.yaml` | `validating-admission-policies.kolteq.com/selinux-role-initcontainers` | `selinux-role-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `selinux-role.yaml` | `validating-admission-policies.kolteq.com/selinux-role` | `selinux-role.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `selinux-type-containers.yaml` | `validating-admission-policies.kolteq.com/selinux-type-containers` | `selinux-type-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `selinux-type-ephemeralcontainers.yaml` | `validating-admission-policies.kolteq.com/selinux-type-ephemeralcontainers` | `selinux-type-ephemeralcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `selinux-type-initcontainers.yaml` | `validating-admission-policies.kolteq.com/selinux-type-initcontainers` | `selinux-type-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `selinux-type.yaml` | `validating-admission-policies.kolteq.com/selinux-type` | `selinux-type.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `selinux-user-containers.yaml` | `validating-admission-policies.kolteq.com/selinux-user-containers` | `selinux-user-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `selinux-user-ephemeralcontainers.yaml` | `validating-admission-policies.kolteq.com/selinux-user-ephemeralcontainers` | `selinux-user-ephemeralcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `selinux-user-initcontainers.yaml` | `validating-admission-policies.kolteq.com/selinux-user-initcontainers` | `selinux-user-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `selinux-user.yaml` | `validating-admission-policies.kolteq.com/selinux-user` | `selinux-user.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `startupprobe-httpget-host-containers.yaml` | `validating-admission-policies.kolteq.com/startupprobe-httpget-host-containers` | `startupprobe-httpget-host-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `startupprobe-httpget-host-initcontainers.yaml` | `validating-admission-policies.kolteq.com/startupprobe-httpget-host-initcontainers` | `startupprobe-httpget-host-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `startupprobe-tcpsocket-host-containers.yaml` | `validating-admission-policies.kolteq.com/startupprobe-tcpsocket-host-containers` | `startupprobe-tcpsocket-host-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `startupprobe-tcpsocket-host-initcontainers.yaml` | `validating-admission-policies.kolteq.com/startupprobe-tcpsocket-host-initcontainers` | `startupprobe-tcpsocket-host-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `windows-hostprocess-containers.yaml` | `validating-admission-policies.kolteq.com/windows-hostprocess-containers` | `windows-hostprocess-containers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `windows-hostprocess-ephemeralcontainers.yaml` | `validating-admission-policies.kolteq.com/windows-hostprocess-ephemeralcontainers` | `windows-hostprocess-ephemeralcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `windows-hostprocess-initcontainers.yaml` | `validating-admission-policies.kolteq.com/windows-hostprocess-initcontainers` | `windows-hostprocess-initcontainers.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |
| `windows-hostprocess.yaml` | `validating-admission-policies.kolteq.com/windows-hostprocess` | `windows-hostprocess.validating-admission-policies.kolteq.com/{warn\|audit\|enforce}` |

