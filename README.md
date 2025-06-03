# HomeLab GitOps with Argo CD

This project demonstrates a full GitOps workflow using **Argo CD**, **Helm**, and **Kubernetes** (Docker Desktop or bare-metal/k3s). It also includes a complete setup for managing cluster-level components such as the **Cilium CNI** plugin via Argo CD.

---

## 📁 Repository Structure

```
homeLab/
├── bootstrap/
│   └── root-app.yaml            # App of Apps for Argo CD
├── apps/
│   └── cilium/
│       ├── cilium-app.yaml     # Argo Application to install Cilium
│       └── values.yaml         # Helm values for Cilium
```

---

## 🚀 Prerequisites

- Running Kubernetes cluster (e.g. Docker Desktop, k3s, kubeadm)
- `kubectl` configured to access the cluster
- Argo CD installed:
  ```bash
  kubectl create namespace argocd
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  ```

---

## ⚙️ Step-by-Step Installation

### 1. Clone this repository

```bash
git clone https://github.com/<your-user>/homeLab.git
cd homeLab
```

### 2. Apply the Argo CD Root Application (App of Apps)

```bash
kubectl apply -f bootstrap/root-app.yaml -n argocd
```

This will instruct Argo CD to look into the `apps/` directory and deploy all defined `Application` manifests, including **Cilium**.

### 3. Verify in Argo CD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Visit [https://localhost:8080](https://localhost:8080)

Login with:
```bash
# Get admin password:
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

---

## 🧠 What Gets Installed?

### ✅ Cilium CNI
- Helm chart from https://helm.cilium.io
- Installed in `kube-system` namespace
- Provides Pod-to-Pod networking, NetworkPolicies, eBPF observability, etc.

### 📦 Future additions (optional):
- `apps/ingress/` → NGINX Ingress Controller
- `apps/monitoring/` → Prometheus/Grafana
- `apps/cert-manager/` → TLS/SSL automation

---

## 🧪 Verify Cilium Installation

```bash
kubectl get pods -n kube-system -l k8s-app=cilium
```

---

## 🤝 Contributing
Pull requests are welcome. Feel free to fork and submit a PR.

---

## 📝 License
MIT