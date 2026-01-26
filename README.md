# ARCHIVE

Updates will be made in https://github.com/kolteq/kubernetes-security-policies !

---
# Kubernetes Pod Security Standards via Validating Admission Policies

This directory contains standalone `ValidatingAdmissionPolicy` objects and their corresponding bindings following the [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/). You can choose to use `warn`/`audit`/`enforce` modes on the `baseline` or `restricted` policy sets, or pick and choose individual policies to enforce or monitor in specific namespaces.

## Install the policies

1. Ensure your cluster runs Kubernetes 1.30 or newer (ValidatingAdmissionPolicy is beta/GA starting in that release line).
2. Apply the manifests to the cluster:

```bash
kubectl apply -k policies/
```

## Use the policies

### Pod Security Standard replacement

Label namespaces with the `pss.security.kolteq.com/<MODE>=<LEVEL>` to enable the full `baseline` or `restricted` policy set. These bindings honor the same `warn`/`audit`/`enforce` semantics as the built-in Pod Security Admission controller.

```bash
kubectl label ns my-namespace \
  pss.security.kolteq.com/warn=restricted \
  pss.security.kolteq.com/audit=restricted \
  pss.security.kolteq.com/enforce=restricted
```

#### Opt-out policies

If you want the baseline/restricted set but need to carve out a specific policy, set the policy label to `false` for the mode you want to disable.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: enforce-restricted-with-opt-out-namespace
  labels:
    pss.security.kolteq.com/enforce: restricted
    hostpid.pss.security.kolteq.com/enforce: 'false'
```

### Opt-in single policies

You can also enable just one or multiple policies without enabling the full baseline/restricted sets by setting a policy-specific label to `true`.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: hostpid-only-namespace
  labels:
    hostpid.pss.security.kolteq.com/enforce: 'true'
```

## Commercial support

For commercial support, reach out to [KolTEQ](https://kolteq.com/)!

## Example namespaces

Examples live in `examples/`:

- `examples/enforce-restricted.yaml` applies `pss.security.kolteq.com/enforce=restricted`.
- `examples/enforce-restricted-with-opt-out.yaml` shows opting out of the hostPID policy.

## Policy label reference

Use these labels to opt in (`true`) or opt out (`false`) for a specific policy. Apply them at the namespace level alongside (or instead of) the global `pss.security.kolteq.com/{warn,audit,enforce}` labels.

| Policy | Opt-in/opt-out label |
| --- | --- |
| `apparmor-annotation-values` | `apparmor-annotation-values.pss.security.kolteq.com/{warn,audit,enforce}` |
| `apparmor-profile` | `apparmor-profile-pod.pss.security.kolteq.com/{warn,audit,enforce}` |
| `apparmor-profile/containers` | `apparmor-profile-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `apparmor-profile/ephemeralcontainers` | `apparmor-profile-ephemeralcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `apparmor-profile/initcontainers` | `apparmor-profile-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `capabilities-add/containers` | `allowed-capabilities-add-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `capabilities-add/ephemeralcontainers` | `allowed-capabilities-add-ephemeralcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `capabilities-add/initcontainers` | `allowed-capabilities-add-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `capabilities-add-netbindservice/containers` | `capabilities-add-netbindservice-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `capabilities-add-netbindservice/ephemeralcontainers` | `capabilities-add-netbindservice-ephemeralcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `capabilities-add-netbindservice/initcontainers` | `capabilities-add-netbindservice-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `capabilities-drop-all/containers` | `capabilities-drop-all-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `capabilities-drop-all/ephemeralcontainers` | `capabilities-drop-all-ephemeralcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `capabilities-drop-all/initcontainers` | `capabilities-drop-all-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `hostipc` | `hostipc.pss.security.kolteq.com/{warn,audit,enforce}` |
| `hostnetwork` | `hostnetwork.pss.security.kolteq.com/{warn,audit,enforce}` |
| `hostpath-volumes` | `hostpath-volumes.pss.security.kolteq.com/{warn,audit,enforce}` |
| `hostpid` | `hostpid.pss.security.kolteq.com/{warn,audit,enforce}` |
| `hostports/containers` | `allowed-hostports-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `hostports/ephemeralcontainers` | `allowed-hostports-ephemeralcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `hostports/initcontainers` | `allowed-hostports-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `livenessprobe-httpget-host/container` | `livenessprobe-httpget-host.pss.security.kolteq.com/{warn,audit,enforce}` |
| `livenessprobe-httpget-host/initcontainers` | `livenessprobe-httpget-host-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `livenessprobe-tcpsocket-host/containers` | `livenessprobe-tcpsocket-host-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `livenessprobe-tcpsocket-host/initcontainers` | `livenessprobe-tcpsocket-host-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `poststart-httpget-host/containers` | `poststart-httpget-host-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `poststart-httpget-host/initcontainers` | `poststart-httpget-host-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `poststart-tcpsocket-host/containers` | `poststart-tcpsocket-host-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `poststart-tcpsocket-host/initcontainers` | `poststart-tcpsocket-host-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `prestop-httpget-host/containers` | `prestop-httpget-host-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `prestop-httpget-host/initcontainers` | `prestop-httpget-host-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `prestop-tcpsocket-host/containers` | `prestop-tcpsocket-host-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `prestop-tcpsocket-host/initcontainers` | `prestop-tcpsocket-host-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `privilege-escalation/containers` | `allow-privilege-escalation-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `privilege-escalation/ephemeralcontainers` | `allow-privilege-escalation-ephemeralcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `privilege-escalation/initcontainers` | `allow-privilege-escalation-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `privileged/containers` | `privileged-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `privileged/ephemeralcontainers` | `privileged-ephemeralcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `privileged/initcontainers` | `privileged-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `procmount/containers` | `procmount-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `procmount/ephemeralcontainers` | `procmount-ephemeralcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `procmount/initcontainers` | `procmount-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `readinessprobe-httpget-host/containers` | `readinessprobe-httpget-host-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `readinessprobe-httpget-host/initcontainers` | `readinessprobe-httpget-host-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `readinessprobe-tcpsocket-host/containers` | `readinessprobe-tcpsocket-host-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `readinessprobe-tcpsocket-host/initcontainers` | `readinessprobe-tcpsocket-host-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `run-as-nonroot` | `run-as-nonroot-pod.pss.security.kolteq.com/{warn,audit,enforce}` |
| `run-as-nonroot/containers` | `run-as-nonroot-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `run-as-nonroot/ephemeralcontainers` | `run-as-nonroot-ephemeralcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `run-as-nonroot/initcontainers` | `run-as-nonroot-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `run-as-user` | `run-as-user-pod.pss.security.kolteq.com/{warn,audit,enforce}` |
| `run-as-user/containers` | `run-as-user-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `run-as-user/ephemeralcontainers` | `run-as-user-ephemeralcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `run-as-user/initcontainers` | `run-as-user-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `seccomp-profile` | `seccomp-profile-pod.pss.security.kolteq.com/{warn,audit,enforce}` |
| `seccomp-profile/containers` | `seccomp-profile-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `seccomp-profile/ephemeralcontainers` | `seccomp-profile-ephemeralcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `seccomp-profile/initcontainers` | `seccomp-profile-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `seccomp-profile-restricted` | `seccomp-profile-pod-restricted.pss.security.kolteq.com/{warn,audit,enforce}` |
| `seccomp-profile-restricted/containers` | `seccomp-profile-containers-restricted.pss.security.kolteq.com/{warn,audit,enforce}` |
| `seccomp-profile-restricted/ephemeralcontainers` | `seccomp-profile-ephemeralcontainers-restricted.pss.security.kolteq.com/{warn,audit,enforce}` |
| `seccomp-profile-restricted/initcontainers` | `seccomp-profile-initcontainers-restricted.pss.security.kolteq.com/{warn,audit,enforce}` |
| `selinux-role` | `selinux-role.pss.security.kolteq.com/{warn,audit,enforce}` |
| `selinux-role/containers` | `selinux-role-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `selinux-role/ephemeralcontainers` | `selinux-role-ephemeralcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `selinux-role/initcontainers` | `selinux-role-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `selinux-type` | `selinux-type.pss.security.kolteq.com/{warn,audit,enforce}` |
| `selinux-type/containers` | `selinux-type-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `selinux-type/ephemeralcontainers` | `selinux-type-ephemeralcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `selinux-type/initcontainers` | `selinux-type-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `selinux-user` | `selinux-user.pss.security.kolteq.com/{warn,audit,enforce}` |
| `selinux-user/containers` | `selinux-user-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `selinux-user/ephemeralcontainers` | `selinux-user-ephemeralcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `selinux-user/initcontainers` | `selinux-user-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `startupprobe-httpget-host/containers` | `startupprobe-httpget-host-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `startupprobe-httpget-host/initcontainers` | `startupprobe-httpget-host-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `startupprobe-tcpsocket-host/containers` | `startupprobe-tcpsocket-host-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `startupprobe-tcpsocket-host/initcontainers` | `startupprobe-tcpsocket-host-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `sysctls` | `allowed-sysctls.pss.security.kolteq.com/{warn,audit,enforce}` |
| `volume-types` | `allowed-volume-types.pss.security.kolteq.com/{warn,audit,enforce}` |
| `windows-hostprocess` | `windows-hostprocess.pss.security.kolteq.com/{warn,audit,enforce}` |
| `windows-hostprocess/containers` | `windows-hostprocess-containers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `windows-hostprocess/ephemeralcontainers` | `windows-hostprocess-ephemeralcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
| `windows-hostprocess/initcontainers` | `windows-hostprocess-initcontainers.pss.security.kolteq.com/{warn,audit,enforce}` |
