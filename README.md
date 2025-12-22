# Validating Admission Policies from Kubernetes Pod Security Standards

This directory contains standalone `ValidatingAdmissionPolicy` objects and their corresponding bindings following the [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/). You can choose to use `warn`/`audit`/`enforce` modes on the `baseline` or `restricted` policy sets, or pick and choose individual policies to enforce or monitor in specific namespaces.

## Installing the policies

1. Ensure your cluster runs Kubernetes 1.30 or newer (ValidatingAdmissionPolicy is beta/GA starting in that release line).
2. Apply the manifests to the cluster (policies first, bindings second):

   ```bash
   kubectl apply -f ./policies/
   kubectl apply -f ./bindings/
   ```

## Choosing enforcement levels

Bindings are provided for three enforcement levels:

| Label | Effect |
| --- | --- |
| `pss.security.kolteq.com/warn=restricted` | Fails the policy in `Warn` mode so the request succeeds but surfaces a server-side warning. |
| `pss.security.kolteq.com/audit=baseline` | Triggers the `Audit` action (shows up in the API audit log). |
| `pss.security.kolteq.com/enforce=restricted` | Denies non-compliant requests (`validationActions: Deny`). |

Add the appropriate label to a namespace to subscribe it to the full restricted policy bundle at that enforcement level:

```bash
kubectl label namespace team-payments pss.security.kolteq.com/enforce=restricted --overwrite
```

Deleting the label stops the binding from matching new objects in that namespace.

## Opting individual policies in or out

Every manifest uses namespace labels to let you override the global behavior:

- Set `pss.security.kolteq.com/{warn|audit|enforce}=restricted` (or `baseline`) on a namespace to subscribe it to the full suite at that enforcement level.
- Set `<policy-name>.pss.security.kolteq.com/{warn|audit|enforce}=false` to opt a namespace out of a specific policy even if the namespace has a global `warn`, `audit`, or `enforce` label.
- Set `<policy-name>.pss.security.kolteq.com/{warn|audit|enforce}=true` to opt a namespace into just that policy with the desired enforcement mode.

Examples:

```bash
# Disable the privileged container check in a namespace that still receives the rest of the restricted set.
kubectl label namespace platform privileged-containers.pss.security.kolteq.com/enforce=false --overwrite

# Opt a CI namespace into the seccomp policy with Warn-level feedback.
kubectl label namespace ci seccomp-profile-pod.pss.security.kolteq.com/warn=true --overwrite

# Opt the same namespace into the run-as-nonroot policy but only write to the audit log.
kubectl label namespace ci run-as-nonroot-containers.pss.security.kolteq.com/audit=true --overwrite

# Enforce the disallow-privilege-escalation policy in the same namespace.
kubectl label namespace ci allow-privilege-escalation-containers.pss.security.kolteq.com/enforce=true --overwrite
```

Remove the label (or set it to an empty value) to fall back to the namespace-wide defaults again.

## Example namespaces

Sample manifests under `examples/namespaces/` demonstrate how to combine the labels:

- `restricted-payments-namespace.yaml` shows a namespace subscribed to the full restricted set with a couple of explicit opt-outs.
- `ci-seccomp-optin-namespace.yaml` shows a namespace that opts into three individual policies by setting `<policy>.pss.security.kolteq.com/{warn|audit|enforce}=true`.
- `staging-audit-namespace.yaml` demonstrates running the full suite in `Audit` mode while selectively disabling `run-as-user-pod` and opting into seccomp with `warn`.
- `prod-mixed-optin-namespace.yaml` keeps the namespace on full `enforce=restricted` while forcing a few additional policies (hostNetwork, privileged containers) and downgrading `allowed-sysctls` to warnings via the per-policy labels.

## Policy label reference

Use the following table to look up the opt-in/opt-out label for each manifest in this directory (global labels are `pss.security.kolteq.com/{warn|audit|enforce}`).

| Policy manifest | Opt-out label key | Opt-in label keys |
| --- | --- | --- |
| `allow-privilege-escalation-containers.yaml` | `allow-privilege-escalation-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `allow-privilege-escalation-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `allow-privilege-escalation-ephemeralcontainers.yaml` | `allow-privilege-escalation-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `allow-privilege-escalation-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `allow-privilege-escalation-initcontainers.yaml` | `allow-privilege-escalation-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `allow-privilege-escalation-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `allowed-capabilities-add-containers.yaml` | `allowed-capabilities-add-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `allowed-capabilities-add-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `allowed-capabilities-add-ephemeralcontainers.yaml` | `allowed-capabilities-add-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `allowed-capabilities-add-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `allowed-capabilities-add-initcontainers.yaml` | `allowed-capabilities-add-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `allowed-capabilities-add-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `allowed-hostports-containers.yaml` | `allowed-hostports-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `allowed-hostports-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `allowed-hostports-ephemeralcontainers.yaml` | `allowed-hostports-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `allowed-hostports-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `allowed-hostports-initcontainers.yaml` | `allowed-hostports-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `allowed-hostports-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `allowed-sysctls.yaml` | `allowed-sysctls.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `allowed-sysctls.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `allowed-volume-types.yaml` | `allowed-volume-types.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `allowed-volume-types.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `apparmor-annotation-values.yaml` | `apparmor-annotation-values.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `apparmor-annotation-values.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `apparmor-profile-containers.yaml` | `apparmor-profile-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `apparmor-profile-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `apparmor-profile-ephemeralcontainers.yaml` | `apparmor-profile-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `apparmor-profile-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `apparmor-profile-initcontainers.yaml` | `apparmor-profile-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `apparmor-profile-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `apparmor-profile-pod.yaml` | `apparmor-profile-pod.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `apparmor-profile-pod.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `capabilities-add-netbindservice-containers.yaml` | `capabilities-add-netbindservice-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `capabilities-add-netbindservice-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `capabilities-add-netbindservice-ephemeralcontainers.yaml` | `capabilities-add-netbindservice-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `capabilities-add-netbindservice-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `capabilities-add-netbindservice-initcontainers.yaml` | `capabilities-add-netbindservice-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `capabilities-add-netbindservice-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `capabilities-drop-all-containers.yaml` | `capabilities-drop-all-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `capabilities-drop-all-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `capabilities-drop-all-ephemeralcontainers.yaml` | `capabilities-drop-all-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `capabilities-drop-all-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `capabilities-drop-all-initcontainers.yaml` | `capabilities-drop-all-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `capabilities-drop-all-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `hostipc.yaml` | `hostipc.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `hostipc.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `hostnetwork.yaml` | `hostnetwork.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `hostnetwork.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `hostpath-volumes.yaml` | `hostpath-volumes.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `hostpath-volumes.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `hostpid.yaml` | `hostpid.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `hostpid.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `livenessprobe-httpget-host-initcontainers.yaml` | `livenessprobe-httpget-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `livenessprobe-httpget-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `livenessprobe-httpget-host.yaml` | `livenessprobe-httpget-host.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `livenessprobe-httpget-host.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `livenessprobe-tcpsocket-host-containers.yaml` | `livenessprobe-tcpsocket-host-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `livenessprobe-tcpsocket-host-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `livenessprobe-tcpsocket-host-initcontainers.yaml` | `livenessprobe-tcpsocket-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `livenessprobe-tcpsocket-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `poststart-httpget-host-containers.yaml` | `poststart-httpget-host-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `poststart-httpget-host-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `poststart-httpget-host-initcontainers.yaml` | `poststart-httpget-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `poststart-httpget-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `poststart-tcpsocket-host-containers.yaml` | `poststart-tcpsocket-host-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `poststart-tcpsocket-host-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `poststart-tcpsocket-host-initcontainers.yaml` | `poststart-tcpsocket-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `poststart-tcpsocket-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `prestop-httpget-host-containers.yaml` | `prestop-httpget-host-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `prestop-httpget-host-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `prestop-httpget-host-initcontainers.yaml` | `prestop-httpget-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `prestop-httpget-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `prestop-tcpsocket-host-containers.yaml` | `prestop-tcpsocket-host-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `prestop-tcpsocket-host-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `prestop-tcpsocket-host-initcontainers.yaml` | `prestop-tcpsocket-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `prestop-tcpsocket-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `privileged-containers.yaml` | `privileged-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `privileged-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `privileged-ephemeralcontainers.yaml` | `privileged-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `privileged-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `privileged-initcontainers.yaml` | `privileged-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `privileged-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `procmount-containers.yaml` | `procmount-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `procmount-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `procmount-ephemeralcontainers.yaml` | `procmount-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `procmount-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `procmount-initcontainers.yaml` | `procmount-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `procmount-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `readinessprobe-httpget-host-containers.yaml` | `readinessprobe-httpget-host-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `readinessprobe-httpget-host-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `readinessprobe-httpget-host-initcontainers.yaml` | `readinessprobe-httpget-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `readinessprobe-httpget-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `readinessprobe-tcpsocket-host-containers.yaml` | `readinessprobe-tcpsocket-host-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `readinessprobe-tcpsocket-host-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `readinessprobe-tcpsocket-host-initcontainers.yaml` | `readinessprobe-tcpsocket-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `readinessprobe-tcpsocket-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `run-as-nonroot-containers.yaml` | `run-as-nonroot-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `run-as-nonroot-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `run-as-nonroot-ephemeralcontainers.yaml` | `run-as-nonroot-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `run-as-nonroot-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `run-as-nonroot-initcontainers.yaml` | `run-as-nonroot-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `run-as-nonroot-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `run-as-nonroot-pod.yaml` | `run-as-nonroot-pod.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `run-as-nonroot-pod.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `run-as-user-containers.yaml` | `run-as-user-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `run-as-user-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `run-as-user-ephemeralcontainers.yaml` | `run-as-user-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `run-as-user-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `run-as-user-initcontainers.yaml` | `run-as-user-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `run-as-user-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `run-as-user-pod.yaml` | `run-as-user-pod.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `run-as-user-pod.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `seccomp-profile-containers-restricted.yaml` | `seccomp-profile-containers-restricted.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `seccomp-profile-containers-restricted.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `seccomp-profile-containers.yaml` | `seccomp-profile-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `seccomp-profile-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `seccomp-profile-ephemeralcontainers-restricted.yaml` | `seccomp-profile-ephemeralcontainers-restricted.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `seccomp-profile-ephemeralcontainers-restricted.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `seccomp-profile-ephemeralcontainers.yaml` | `seccomp-profile-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `seccomp-profile-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `seccomp-profile-initcontainers-restricted.yaml` | `seccomp-profile-initcontainers-restricted.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `seccomp-profile-initcontainers-restricted.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `seccomp-profile-initcontainers.yaml` | `seccomp-profile-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `seccomp-profile-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `seccomp-profile-pod-restricted.yaml` | `seccomp-profile-pod-restricted.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `seccomp-profile-pod-restricted.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `seccomp-profile-pod.yaml` | `seccomp-profile-pod.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `seccomp-profile-pod.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `selinux-role-containers.yaml` | `selinux-role-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `selinux-role-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `selinux-role-ephemeralcontainers.yaml` | `selinux-role-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `selinux-role-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `selinux-role-initcontainers.yaml` | `selinux-role-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `selinux-role-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `selinux-role.yaml` | `selinux-role.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `selinux-role.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `selinux-type-containers.yaml` | `selinux-type-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `selinux-type-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `selinux-type-ephemeralcontainers.yaml` | `selinux-type-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `selinux-type-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `selinux-type-initcontainers.yaml` | `selinux-type-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `selinux-type-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `selinux-type.yaml` | `selinux-type.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `selinux-type.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `selinux-user-containers.yaml` | `selinux-user-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `selinux-user-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `selinux-user-ephemeralcontainers.yaml` | `selinux-user-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `selinux-user-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `selinux-user-initcontainers.yaml` | `selinux-user-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `selinux-user-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `selinux-user.yaml` | `selinux-user.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `selinux-user.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `startupprobe-httpget-host-containers.yaml` | `startupprobe-httpget-host-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `startupprobe-httpget-host-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `startupprobe-httpget-host-initcontainers.yaml` | `startupprobe-httpget-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `startupprobe-httpget-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `startupprobe-tcpsocket-host-containers.yaml` | `startupprobe-tcpsocket-host-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `startupprobe-tcpsocket-host-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `startupprobe-tcpsocket-host-initcontainers.yaml` | `startupprobe-tcpsocket-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `startupprobe-tcpsocket-host-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `windows-hostprocess-containers.yaml` | `windows-hostprocess-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `windows-hostprocess-containers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `windows-hostprocess-ephemeralcontainers.yaml` | `windows-hostprocess-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `windows-hostprocess-ephemeralcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `windows-hostprocess-initcontainers.yaml` | `windows-hostprocess-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `windows-hostprocess-initcontainers.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
| `windows-hostprocess.yaml` | `windows-hostprocess.pss.security.kolteq.com/{warn\|audit\|enforce}=false` | `windows-hostprocess.pss.security.kolteq.com/{warn\|audit\|enforce}=true` |
