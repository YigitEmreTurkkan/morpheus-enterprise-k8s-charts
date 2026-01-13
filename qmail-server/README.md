# Qmail Mail Server Helm Chart

This project is a Helm chart for deploying Qmail mail server on Kubernetes. It is designed for use with cloud management platforms like Morpheus.

## Project Structure

```
qmail-server/
├── Chart.yaml
├── values.yaml
├── README.md
└── templates/
    ├── _helpers.tpl
    ├── mail-deployment.yaml
    ├── mail-service.yaml
    └── mail-pvc.yaml
```

## Components

- **Qmail Deployment**: Qmail mail server container (robreardon/qmail)
- **Service**: ClusterIP service with multiple ports
- **PersistentVolumeClaim**: PVC for mail data persistence

## Features

- ✅ **Standalone SMTP Server** - No external SMTP relay required
- ✅ **Full Mail Server** - SMTP, POP3, IMAP support
- ✅ **Persistent Storage** - Mail data is persisted
- ✅ **Configurable Domain** - Set your own mail domain
- ✅ **Multiple Protocols** - SMTP (25), SMTP Submission (587), POP3 (110), IMAP (143), POP3S (995), IMAPS (993)

## Prerequisites

- Kubernetes cluster
- Helm 3.x
- kubectl configured
- DNS configuration for your mail domain (MX records, SPF, DKIM, DMARC)

## Installation

### Deploy with Helm

```bash
cd qmail-server
helm install qmail-server . --namespace <namespace>
```

### Check deployment status

```bash
kubectl get pods
kubectl get services
kubectl get pvc
```

## Configuration

You can configure the following settings in the `values.yaml` file:

- **Mail Image**: Qmail image repository and tag
- **Storage Size**: PVC size (default: 10Gi)
- **Domain**: Your mail domain (e.g., example.com)
- **Hostname**: Mail server hostname (e.g., mail.example.com)
- **Resources**: CPU and memory limits
- **Ports**: Mail service ports (SMTP, POP3, IMAP, etc.)

## DNS Configuration

For your mail server to work properly, you need to configure DNS records:

### MX Record
```
example.com.    IN    MX    10    mail.example.com.
```

### A Record
```
mail.example.com.    IN    A    <your-kubernetes-ingress-ip>
```

### SPF Record
```
example.com.    IN    TXT    "v=spf1 mx a:mail.example.com ~all"
```

### DKIM Record (if supported)
Configure DKIM signing for your domain.

### DMARC Record (recommended)
```
_dmarc.example.com.    IN    TXT    "v=DMARC1; p=none; rua=mailto:admin@example.com"
```

## Network Configuration

### Using LoadBalancer Service

If you want to expose the mail server directly, you can change the service type:

```yaml
# In values.yaml or via --set
service:
  type: LoadBalancer
```

### Using Ingress (Recommended)

This chart automatically creates a TCP ConfigMap for NGINX Ingress Controller. The ConfigMap is created in the ingress namespace (default: `ingress-nginx`).

**Automatic Configuration:**

The chart creates a `tcp-services` ConfigMap automatically when `ingress.enabled: true` is set in `values.yaml`.

**Important Notes:**

1. **If a `tcp-services` ConfigMap already exists** in the ingress namespace, you need to merge the Qmail ports manually:

```bash
# Get existing ConfigMap
kubectl get configmap tcp-services -n ingress-nginx -o yaml > existing-tcp-configmap.yaml

# Add Qmail ports to the data section
# Then apply the merged ConfigMap
kubectl apply -f existing-tcp-configmap.yaml

# Restart NGINX Ingress Controller to pick up changes
kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx
```

2. **If no `tcp-services` ConfigMap exists**, the chart will create it automatically.

3. **After deployment**, verify the ConfigMap:

```bash
kubectl get configmap tcp-services -n ingress-nginx -o yaml
```

4. **Get the Ingress Controller's external IP** for DNS A record:

```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
# Use the EXTERNAL-IP for your DNS A record
```

## Mail Server Usage

### Sending Mail

Configure your email client or application to use:
- **SMTP Server**: `<service-name>.<namespace>.svc.cluster.local` (internal) or your external domain
- **SMTP Port**: 25 or 587
- **Authentication**: Configure as needed

### Receiving Mail

Configure your email client to use:
- **POP3 Server**: `<service-name>.<namespace>.svc.cluster.local` (internal) or your external domain
- **POP3 Port**: 110 (or 995 for POP3S)
- **IMAP Server**: `<service-name>.<namespace>.svc.cluster.local` (internal) or your external domain
- **IMAP Port**: 143 (or 993 for IMAPS)

## Morpheus Integration

To add this Helm chart to the Morpheus platform, follow these steps:

### 1. Git Repository Setup

Upload your chart to a Git repository (GitHub, GitLab, Bitbucket, etc.):

```bash
git init
git add .
git commit -m "Qmail mail server Helm chart for Morpheus"
git remote add origin <your-repo-url>
git push -u origin main
```

### 2. SCM Integration in Morpheus

1. Navigate to **Administration > Integrations > Source Control** in Morpheus UI
2. Create a new SCM Integration (GitHub, GitLab, etc.)
3. Enter the repository URL and credentials

### 3. Create App Blueprint

1. Navigate to **Library > Blueprints > App Blueprints**
2. Click **+ ADD** button
3. Select **"Helm"** as the **Type**
4. Select the Git integration you created in the **SCM Integration** section
5. Select the repository where your chart is located as **Repository**
6. Enter the branch name as **Branch or Tag** (e.g., `main`, `master`)
7. Specify the path to your chart as **Chart Path** (e.g., `qmail-server`)

### 4. Blueprint Configuration

- **Name**: Qmail Mail Server
- **Description**: Qmail standalone mail server deployment
- **Category**: Mail Server
- **Helm Values**: You can override values from the `values.yaml` file

### 5. Deploy

1. Navigate to **Provisioning > Apps**
2. Click **+ ADD** button
3. Select the Qmail blueprint you created
4. Fill in required parameters:
   - Mail domain
   - Hostname
   - Storage size
   - Resource limits
5. Deploy

### Notes

- Your chart must be in Helm 3.x format (✓ Chart.yaml apiVersion: v2)
- All required template files must be present (✓ _helpers.tpl, deployment, service, pvc)
- The `values.yaml` file can be overridden in Morpheus
- **Important**: Configure DNS records (MX, SPF, DKIM, DMARC) for proper mail delivery

## Uninstall

```bash
helm uninstall qmail-server
```

**Note**: PVCs are not deleted by default. To delete manually:

```bash
kubectl delete pvc <pvc-name>
```

## Troubleshooting

### Check pod logs

```bash
kubectl logs <pod-name>
```

### Check service endpoints

```bash
kubectl get endpoints <service-name>
```

### Test SMTP connection

```bash
kubectl exec -it <pod-name> -- telnet localhost 25
```

### Check PVC status

```bash
kubectl describe pvc <pvc-name>
```

### Common Issues

1. **Mail not being delivered**: Check DNS MX records and SPF configuration
2. **Connection refused**: Ensure service is properly exposed (LoadBalancer or Ingress)
3. **Authentication issues**: Verify user accounts are properly configured in qmail

## Security Considerations

- Configure firewall rules to allow only necessary ports
- Use TLS/SSL for encrypted connections (POP3S, IMAPS)
- Implement proper authentication mechanisms
- Configure SPF, DKIM, and DMARC records to prevent spam
- Regularly update the mail server image
- Monitor logs for suspicious activity

## License

MIT License

