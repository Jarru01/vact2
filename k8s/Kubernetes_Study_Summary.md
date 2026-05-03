# 🧭 Kubernetes Basics — Complete Study Summary

---

## 1. What is Kubernetes?

Kubernetes (k8s) is a **portable, extensible, open-source platform** for managing containerized workloads and services. It supports declarative configuration and automation.

- Originally designed by **Google**, written in **Go**
- Open-sourced on **June 7, 2014**
- Now maintained by the **Cloud Native Computing Foundation (CNCF)**
- Name means **"helmsman" or "pilot"** in Greek
- Current version: **1.29**

### Key Features
- **Service discovery & load balancing** — exposes containers via DNS or IP; distributes traffic automatically
- **Storage orchestration** — auto-mounts local or cloud storage
- **Automated rollouts & rollbacks** — changes actual state to desired state at a controlled rate
- **Automatic bin packing** — fits containers onto nodes to maximize resource use
- **Self-healing** — restarts failing containers, replaces them, kills unhealthy ones
- **Secret & config management** — stores passwords, OAuth tokens, SSH keys without exposing them in images
- **Batch execution** — manages batch and CI workloads
- **Horizontal scaling** — manual or automatic (based on CPU)
- **IPv4/IPv6 dual-stack** support
- **Designed for extensibility** — add features without changing upstream code

### What Kubernetes is NOT
- Not a traditional all-inclusive PaaS
- Does not deploy source code or build applications
- Does not provide app-level services (databases, message buses, etc.)
- Does not dictate logging, monitoring, or alerting solutions
- Does not provide a configuration language/system

---

## 2. Kubernetes Architecture

A Kubernetes deployment is called a **cluster**, consisting of:
- **Worker nodes** — run containerized applications (at least one required)
- **Control plane** — manages worker nodes and Pods; runs across multiple machines in production for high availability

### Control Plane (CP) Components

| Component | Role |
|---|---|
| **kube-apiserver** | Front-end of the CP; exposes the Kubernetes API; scales horizontally |
| **etcd** | Consistent, highly-available key-value store; Kubernetes' backing store for all cluster data |
| **kube-scheduler** | Assigns newly created Pods (with no node) to a node; considers resource requirements, constraints, affinity, data locality, deadlines |
| **kube-controller-manager** | Runs controller processes (Node controller, Job controller, EndpointSlice controller) |
| **cloud-controller-manager** | Embeds cloud-specific logic; links cluster to cloud provider APIs; absent in on-premise/local setups |

### Node Components (run on every node)

| Component | Role |
|---|---|
| **kubelet** | Agent on each node; ensures containers in a Pod are running and healthy |
| **kube-proxy** | Network proxy; maintains network rules; enables communication to/from Pods |
| **Container runtime** | Manages container execution (containerd, CRI-O, or any CRI implementation) |

### Addons
- **DNS** — all clusters should have cluster DNS
- **Web UI** — dashboard for managing/troubleshooting
- **Network plugins** — allocate IPs to Pods and enable communication

---

## 3. The Kubernetes API

- The **core of the control plane**
- Exposes an **HTTP REST API** for communication between users, cluster parts, and external components
- Lets you query and manipulate API objects (Pods, Namespaces, etc.)
- Most operations done via **kubectl** or client libraries
- State is stored in **etcd**

### API Versioning

| Level | Example | Notes |
|---|---|---|
| **Alpha** | v1alpha1 | Disabled by default; may contain bugs |
| **Beta** | v2beta3 | Disabled by default (post-1.22); max 9 months / 3 minor releases |
| **Stable** | v1 | Available for all future releases within a major version |

### API Groups
- **Core (legacy) group** — REST path `/api/v1`, e.g. `apiVersion: v1`
- **Named groups** — REST path `/apis/$GROUP_NAME/$VERSION`, e.g. `apiVersion: batch/v1`

---

## 4. Kubernetes Tools

### kubectl
- CLI tool for communicating with the cluster's control plane
- Config file: `$HOME/.kube/config` (or `KUBECONFIG` env var / `--kubeconfig` flag)
- Verify install: `kubectl version`

**Syntax:** `kubectl [command] [TYPE] [NAME] [flags]`
- **command** — operation: `create`, `get`, `describe`, `delete`
- **TYPE** — resource type (case-insensitive, singular/plural/abbreviated)
- **NAME** — resource name (case-sensitive; omit to get all)
- **flags** — optional flags

**Common commands:**
```bash
kubectl apply -f example.yaml      # create/update from file
kubectl get pods                   # list pods
kubectl get nodes                  # list nodes
```

---

## 5. Local Kubernetes Cluster — minikube

- Local Kubernetes for learning/development
- Requires: Docker or a VM manager
- Start with: `minikube start`

**Requirements:** 2+ CPUs, 2GB RAM, 20GB disk, internet, Docker/VM manager

**Useful commands:**
```bash
kubectl cluster-info
kubectl get nodes -o wide
kubectl describe node minikube
kubectl dashboard              # enable Web UI
```

---

## 6. Objects in Kubernetes

- **Persistent entities** representing the desired state of your cluster
- Act as a "record of intent" — Kubernetes continuously works to maintain them

### Every object has:
- **Name** — unique for its resource type within a namespace
- **UID** — unique across the entire cluster

### Object manifest (YAML/JSON) required fields:
- `apiVersion` — which API version to use
- `kind` — type of object (Pod, Deployment, etc.)
- `metadata` — name, UID, optional namespace
- `spec` — desired state

### Spec vs Status
- **spec** — desired state (you define this)
- **status** — current state (Kubernetes updates this; CP continuously reconciles to match spec)

---

## 7. Namespaces

- Isolate groups of resources within a single cluster
- Names unique **within** a namespace, not across
- Cannot be nested; each resource belongs to exactly one namespace

### 4 initial namespaces:

| Namespace | Purpose |
|---|---|
| `default` | For objects with no other namespace |
| `kube-system` | Objects created by Kubernetes system |
| `kube-node-lease` | Lease objects for node heartbeats (failure detection) |
| `kube-public` | Readable by all clients; reserved for cluster usage |

**Commands:**
```bash
kubectl create namespace example
kubectl get namespaces
kubectl get pods -n kube-system
kubectl config set-context --current --namespace=example
```

---

## 8. Labels, Annotations & Finalizers

### Labels
- **Key/value pairs** attached to objects
- Used to organize and select subsets of objects
- Each key must be unique per object
- **Label selector** — core grouping primitive in Kubernetes

```bash
kubectl label namespace example key=value
kubectl get namespace -l key=value
```

### Annotations
- Attach **arbitrary non-identifying metadata** to objects
- Can be large, structured/unstructured, include characters labels can't

### Finalizers
- Namespaced keys telling Kubernetes to wait until specific conditions are met before deleting a resource
- Used for garbage collection control

---

## 9. Kubernetes Workloads

A workload is an application running on Kubernetes, running inside a set of **Pods**.

### Built-in Workload Types

| Type | Use case |
|---|---|
| **Deployment + ReplicaSet** | Stateless apps; Pods are interchangeable |
| **StatefulSet** | Stateful apps; sticky identity, persistent storage, ordered deployment |
| **DaemonSet** | Run a Pod on every (or some) node (e.g., log collectors, monitoring agents) |
| **Job** | Run a task once to completion |
| **CronJob** | Run a Job repeatedly on a schedule (cron format) |

---

## 10. Pods

- **Smallest deployable unit** in Kubernetes
- A group of one or more containers sharing storage, network, and a spec
- Most common: **one-container-per-Pod**
- Can also include **init containers** (run at startup) and **ephemeral containers** (for debugging)

### Pod Networking
- Each Pod gets a **unique cluster-wide IP**
- Containers within a Pod share IP, MAC address, communicate via `localhost`
- Containers in different Pods use IP networking
- "**IP-per-pod**" model — no NAT needed between Pods

### Pod Lifecycle
- Scheduled **once** to a Node for its lifetime
- kubelet can restart containers (but Pods don't self-heal)

### Pod Phases

| Phase | Meaning |
|---|---|
| **Pending** | Accepted by cluster; containers not yet ready |
| **Running** | Bound to node; at least one container running |
| **Succeeded** | All containers terminated successfully |
| **Failed** | All containers terminated; at least one failed |
| **Unknown** | State cannot be obtained (communication error) |

### Container States
- **Waiting** — start-up operations still running (e.g., pulling image)
- **Running** — executing without issues
- **Terminated** — ran to completion or failed

### Pod Conditions
- `PodScheduled` — scheduled to a node
- `PodReadyToStartContainers` — sandbox created, networking configured
- `ContainersReady` — all containers ready
- `Initialized` — all init containers completed
- `Ready` — Pod can serve requests; added to load balancing pools

### Container Probes

**Check mechanisms (pick exactly one per probe):**
- `exec` — run command inside container (success = exit code 0)
- `grpc` — gRPC call (success = SERVING)
- `httpGet` — HTTP GET (success = status 200–399)
- `tcpSocket` — TCP check (success = port open)

**Probe outcomes:** Success / Failure / Unknown

**Probe types:**

| Probe | What it does | On failure |
|---|---|---|
| **livenessProbe** | Is the container running? | kubelet kills container → restart policy |
| **readinessProbe** | Is container ready to serve requests? | Removed from Service endpoints |
| **startupProbe** | Has app started? All other probes disabled until it succeeds | kubelet kills container → restart policy |

> If no probes are provided, default state is **Success**.

### Pod Termination
1. **SIGTERM** sent
2. **Wait 30 seconds** (grace period)
3. **Kill** (SIGKILL)

Pods in Succeeded/Failed phase are eventually cleaned by the garbage collector.

---

## 11. Workload Management

### Deployment
- Provides **declarative updates** for Pods and ReplicaSets
- Deployment Controller changes actual → desired state

### ReplicaSet
- Maintains a **stable number of replica Pods**
- Defined by: selector, number of replicas, Pod template

**Key commands:**
```bash
kubectl create deployment example --image=nginx --replicas=2
kubectl set image deployment.v1.apps/example nginx=nginx:1.16.1
kubectl rollout history deployment example
kubectl rollout undo deployment example --to-revision=1
kubectl scale deployment example --replicas=3
```

### StatefulSet
- Provides **ordering and uniqueness** guarantees for Pods
- Each Pod has a **persistent identity** (maintained across rescheduling)
- Use for: stable network identifiers, persistent storage, ordered deployment/updates

### DaemonSet
- Ensures **every node** runs a copy of a Pod
- Pods auto-added when nodes join; auto-removed when nodes leave
- Typical uses: storage daemons, log collectors, monitoring agents

### Jobs & CronJobs
- **Job** — runs a task once to completion
- **CronJob** — runs Jobs on a repeating schedule (cron format)

```bash
kubectl create job example --image=busybox -- date
kubectl create cronjob example --image=busybox --schedule="*/1 * * * *" -- date
```

---

## 12. Services, Load Balancing & Networking

### Kubernetes Network Model Requirements
- Pods communicate with all other Pods on any node **without NAT**
- Agents on a node can communicate with all Pods on that node
- "**IP-per-pod**" model

### Services
- Expose a network application running as Pods
- Defines a logical set of endpoints + access policy
- Pods targeted by a **selector**

### Service Types

| Type | Description |
|---|---|
| **ClusterIP** (default) | Only reachable within the cluster; expose via Ingress/Gateway for external access |
| **NodePort** | Exposes on each Node's IP at a static port |
| **LoadBalancer** | Uses external load balancer (cloud provider integration) |
| **ExternalName** | Maps to an external DNS name via CNAME; no proxying |

### Ingress
- Exposes **HTTP/HTTPS routes** from outside to services inside the cluster
- Can do: external URLs, load balancing, SSL/TLS termination, name-based virtual hosting

### Gateway API
- Extensible, role-oriented, protocol-aware configuration for network services
- Provides dynamic infrastructure provisioning and advanced traffic routing

### DNS for Services and Pods
- Services: `my-svc.my-namespace.svc.cluster-domain.example`
- Pods: `pod-ipv4-address.my-namespace.pod.cluster-domain.example`
- DNS queries without namespace are limited to the Pod's own namespace

---

## 13. Storage

### Volumes
- Solve the problem of ephemeral container storage and sharing files between containers
- A volume is a directory accessible to containers in a Pod
- **Ephemeral volumes** — lifetime of the Pod
- **Persistent volumes** — exist beyond the Pod's lifetime

**Volume types:** `configMap`, `secret`, `emptyDir`, `NFS`, `persistentVolumeClaim`

### PersistentVolume (PV)
- A piece of storage in the cluster provisioned by an admin or dynamically
- Has a lifecycle **independent** of any Pod

### PersistentVolumeClaim (PVC)
- A **request for storage** by a user
- Like a Pod consuming node resources, PVCs consume PV resources
- Can request specific size and access modes

### PV/PVC Lifecycle
1. **Provisioning** — Static (admin creates PVs) or Dynamic (via StorageClasses)
2. **Binding** — Control loop binds PVC to a matching PV (one-to-one, exclusive)
3. **Using** — Pod mounts the claim as a volume
4. **Reclaiming** — When PVC is deleted:
   - **Retain** — PV still exists; data remains; admin must manually clean
   - **Recycle** *(deprecated)* — basic scrub, made available again
   - **Delete** — PV and associated storage asset are deleted

### Access Modes

| Mode | Description |
|---|---|
| **ReadWriteOnce (RWO)** | Read-write by a single node (multiple pods on same node allowed) |
| **ReadOnlyMany (ROX)** | Read-only by many nodes |
| **ReadWriteMany (RWX)** | Read-write by many nodes |
| **ReadWriteOncePod (RWOP)** | Read-write by a single Pod only |

### Ephemeral Volumes
- `emptyDir` — empty at Pod startup; local or RAM storage
- `configMap`, `secret`, `downwardAPI` — inject Kubernetes data into Pod
- CSI ephemeral volumes — provided by special CSI drivers
- Generic ephemeral volumes — provided by all storage drivers that support PVs

---

## 14. Configuration

### ConfigMaps
- API object for storing **non-confidential** data in key-value pairs
- Pods consume ConfigMaps as: environment variables, command-line args, or config files in a volume
- Has `data` (UTF-8 strings) and `binaryData` (base64) fields
- Name must be a valid DNS subdomain
- Can be made **immutable**

```bash
kubectl create configmap example --from-file=sample.cfg
kubectl create configmap example2 --from-literal=enabled=true
```

### Secrets
- Stores small amounts of **sensitive data** (passwords, tokens, keys)
- Similar to ConfigMaps but intended for confidential data
- ⚠️ Stored **unencrypted** in etcd by default — additional security measures needed
- Individual secrets limited to **1MiB**
- Types: `Opaque`, `kubernetes.io/dockercfg`, `kubernetes.io/ssh-auth`, and more
- Has `data` (base64) and `stringData` (plain string) fields
- Pods consume Secrets as: environment variables or secret files in a volume

```bash
kubectl create secret generic example --from-literal=password=12345
kubectl get secret example -o yaml
```

### Resource Management
- Specify CPU and memory **requests** (scheduler uses to place Pod) and **limits** (kubelet enforces)
- CPU measured in CPU units (1 CPU = 1 physical/virtual core)
- Memory measured in bytes

---

## 15. Security

### Service Accounts
- Non-human account providing distinct identity in a cluster
- Used by Pods, system components, and external entities to authenticate to the API server
- Kubernetes auto-creates a `default` ServiceAccount in every namespace

### RBAC (Role-Based Access Control)
- Regulates access based on user roles
- **4 RBAC API objects:**
  - **Role** — permissions within a namespace
  - **ClusterRole** — permissions across the whole cluster
  - **RoleBinding** — binds a Role to a user/group/service account (within a namespace)
  - **ClusterRoleBinding** — binds a ClusterRole cluster-wide
- Permissions are **purely additive** (no "deny" rules)

---

## 16. Scheduling

### Kubernetes Scheduler
- Watches for Pods with no assigned Node and finds the best Node for them

### Ways to Assign Pods to Nodes
- **nodeSelector** — match node labels; Pod only scheduled on nodes with specified labels
- **Affinity & anti-affinity** — more expressive; can be soft/preferred; can use other Pod labels
- **nodeName** — direct node assignment; overrules nodeSelector and affinity
- **Pod topology spread constraints** — control how Pods spread across failure domains (regions, zones, nodes)

### Taints & Tolerations
- **Taints** — applied to **nodes**; repel Pods that don't tolerate the taint
- **Tolerations** — applied to **Pods**; allow scheduling onto tainted nodes
- Together they ensure Pods aren't scheduled on inappropriate nodes
- Taint format: `key=value:Effect` (e.g., `key1=value1:NoSchedule`)

```bash
kubectl taint nodes minikube key1=value1:NoSchedule
kubectl taint nodes minikube key1=value1:NoSchedule-   # remove taint
```

---

## 17. Helm & Helm Charts

### What is Helm?
- A **package manager** for Kubernetes
- Manages packages called **charts**

### Helm can:
- Create new charts from scratch
- Package charts into `.tgz` archive files
- Interact with chart repositories
- Install/uninstall charts into a cluster
- Manage release cycles of installed charts

### 3 Key Concepts
- **Chart** — bundle of info to create a Kubernetes application instance
- **Config** — configuration merged into a chart to create a releasable object
- **Release** — a running instance of a chart + specific config

### Helm Components
- **Helm Client** — CLI for end users
- **Helm Library** — logic for all Helm operations; interfaces with the Kubernetes API server
- Written in **Go**; uses Kubernetes client library (REST + JSON)

**Where to find charts:** [Artifact Hub](https://artifacthub.io)

**Key commands:**
```bash
helm repo add <name> <url>
helm repo update
helm install <release-name> <chart>
helm uninstall <release-name>
helm version
```

---

## 18. Bonus — Init Containers

- Run **before** the main app containers in a Pod
- Must complete successfully before any app container starts
- Can be used for bootstrapping (e.g., downloading content before nginx starts)
- Share volumes with main containers via `emptyDir`

**Example use case:** Init container downloads a webpage from `http://info.cern.ch` into a shared `emptyDir` volume, then the main nginx container serves it.

---

## 🔑 Quick Reference — Key Things to Know for the Test

| Topic | Key Point |
|---|---|
| Cluster components | Control Plane (apiserver, etcd, scheduler, controller-manager) + Nodes (kubelet, kube-proxy, runtime) |
| etcd | Key-value store; holds ALL cluster state |
| Pod phases | Pending → Running → Succeeded / Failed / Unknown |
| Container states | Waiting / Running / Terminated |
| Probe types | liveness (kill if fail) / readiness (remove from endpoints) / startup (blocks others) |
| Pod termination | SIGTERM → 30s wait → SIGKILL |
| Service types | ClusterIP (default) / NodePort / LoadBalancer / ExternalName |
| PV/PVC lifecycle | Provision → Bind → Use → Reclaim |
| Reclaim policies | Retain / Recycle (deprecated) / Delete |
| Access modes | RWO / ROX / RWX / RWOP |
| RBAC objects | Role / ClusterRole / RoleBinding / ClusterRoleBinding |
| Helm concepts | Chart / Config / Release |
| Scheduling | nodeSelector / Affinity / nodeName / Topology constraints / Taints & Tolerations |
| API stability | Alpha (buggy, off) → Beta (tested, off) → Stable (always available) |

---

*Good luck on your test! 🍀*
