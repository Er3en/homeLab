<!-- ## 📦 homeLab — GitOps Kubernetes Cluster with Argo CD, Cilium, Prometheus, Loki and Grafana

This project sets up a complete **GitOps-powered home Kubernetes lab**, managed by **Argo CD**, and includes modern networking, monitoring, and logging components. Ideal for learning, experimenting, and managing clusters declaratively.

---

## 🔧 What's included?

| Component     | Purpose                                                                 |
|---------------|-------------------------------------------------------------------------|
| **Argo CD**   | GitOps controller that automatically syncs manifests from Git           |
| **Cilium**    | CNI plugin with eBPF-based networking and security for Kubernetes       |
| **Prometheus**| Collects time-series metrics from nodes, pods, and applications         |
| **Grafana**   | Visualizes metrics from Prometheus and logs from Loki                   |
| **Loki**      | Lightweight log aggregation system (Prometheus-style for logs)          |
| **Promtail**  | Log shipping agent that collects logs from pods and sends them to Loki  |

---

## 📁 Project Structure

```bash
.
├── bootstrap/
│   └── root-app.yaml         # Root Argo CD Application (App of Apps)
├── apps/
│   ├── cilium-app.yaml       # Installs Cilium from Helm repo
│   ├── prometheus-app.yaml   # Installs Prometheus from community Helm chart
│   ├── grafana-app.yaml      # Installs Grafana with NodePort access
│   ├── loki-app.yaml         # Installs Loki (log backend)
│   ├── promtail-app.yaml     # Installs Promtail (log shipper)
│   └── cilium/
│       └── values.yaml       # Custom values for Cilium Helm chart
```

---

## 🚀 How to Use

### 1. Prerequisites
- Kubernetes cluster (e.g. Docker Desktop, K3s, or VMs)
- `kubectl` access
- Argo CD installed in the cluster

### 2. Create namespaces (if missing)
```bash
kubectl create namespace argocd || true
kubectl create namespace monitoring || true
```

### 3. Deploy the root Argo CD application
```bash
kubectl apply -f bootstrap/root-app.yaml -n argocd
```

This bootstraps all other applications from the `apps/` directory using the App of Apps pattern.

---

## 🌐 Access Grafana

Once Grafana is deployed via Argo CD:

```bash
http://localhost:32000
```

- Username: `admin`
- Password: `admin`

> ⚠️ Port `32000` is exposed via NodePort; adjust if necessary for your environment.

---

## 🧠 Notes

- Prometheus is the metric engine (no Alertmanager/PushGateway enabled)
- Loki + Promtail handle logs from pods and integrate with Grafana
- Cilium provides advanced networking using eBPF

Feel free to extend the stack with:
- Ingress (e.g. ingress-nginx)
- Cert-Manager for TLS
- Sealed Secrets for secure GitOps secrets
- Argo Rollouts for progressive delivery -->
