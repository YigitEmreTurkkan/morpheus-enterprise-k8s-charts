# Roundcube Webmail Helm Chart

This project is a Helm chart for deploying Roundcube webmail interface on Kubernetes. It integrates with Qmail mail server for web-based email access.

## Project Structure

```
roundcube-webmail/
├── Chart.yaml
├── values.yaml
├── README.md
└── templates/
    ├── _helpers.tpl
    ├── webmail-deployment.yaml
    ├── webmail-service.yaml
    ├── webmail-ingress.yaml
    └── webmail-pvc.yaml
```

## Components

- **Roundcube Deployment**: Roundcube webmail container
- **Service**: ClusterIP service (port 80)
- **Ingress**: HTTP/HTTPS ingress for web access
- **PersistentVolumeClaim**: PVC for configuration and data persistence

## Features

- ✅ **Web-based Email Access** - Access your emails through a modern web interface
- ✅ **Qmail Integration** - Connects to Qmail mail server via IMAP/SMTP
- ✅ **HTTPS Support** - TLS/SSL encryption via Ingress
- ✅ **Persistent Storage** - Configuration and data persisted
- ✅ **Modern UI** - Clean and responsive webmail interface

## Prerequisites

- Kubernetes cluster
- Helm 3.x
- kubectl configured
- Qmail mail server deployed (or any IMAP/SMTP server)
- Ingress controller configured
- (Optional) cert-manager for TLS certificates

## Installation

### Deploy with Helm

```bash
cd roundcube-webmail
helm install roundcube-webmail . --namespace mail
```

### Check deployment status

```bash
kubectl get pods -n mail
kubectl get services -n mail
kubectl get ingress -n mail
kubectl get pvc -n mail
```

## Configuration

You can configure the following settings in the `values.yaml` file:

- **Webmail Image**: Roundcube image repository and tag
- **Storage Size**: PVC size (default: 5Gi)
- **Domain**: Your mail domain
- **Hostname**: Webmail hostname (e.g., webmail.cloudflex.tr)
- **Mail Server**: Qmail server connection settings (host, ports, security)
- **Resources**: CPU and memory limits
- **Ingress**: Ingress configuration (host, TLS, annotations)

### Mail Server Configuration

The chart is pre-configured to connect to Qmail server:

```yaml
mailServer:
  host: qmail-server.mail.svc.cluster.local
  smtpPort: 25
  imapPort: 143
  smtpSecure: "tls"
  imapSecure: "tls"
```

If your Qmail server is in a different namespace, update the host accordingly.

## Access

After deployment, access Roundcube webmail at:

- **URL**: `https://webmail.cloudflex.tr` (or your configured hostname)
- **Login**: Use your email address and password configured in Qmail

## Initial Setup

On first access, Roundcube will guide you through the initial configuration:

1. Database setup (SQLite by default, or MySQL/PostgreSQL)
2. Mail server connection settings
3. Application configuration

## DNS Configuration

Add a DNS record for webmail access:

```
webmail.cloudflex.tr    A    <INGRESS-IP>
```

Or use a CNAME if you prefer:

```
webmail.cloudflex.tr    CNAME    mail.cloudflex.tr
```

## TLS/SSL Configuration

### Using cert-manager (Recommended)

If cert-manager is installed, TLS certificates are automatically provisioned:

```yaml
ingress:
  enabled: true
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  tls:
    enabled: true
    secretName: roundcube-webmail-tls
```

### Manual TLS Certificate

1. Create a TLS secret:
```bash
kubectl create secret tls roundcube-webmail-tls \
  --cert=path/to/cert.pem \
  --key=path/to/key.pem \
  -n mail
```

2. Update values.yaml:
```yaml
ingress:
  tls:
    enabled: true
    secretName: roundcube-webmail-tls
```

## Morpheus Integration

To add this Helm chart to the Morpheus platform:

### 1. Git Repository Setup

Upload your chart to a Git repository:

```bash
git add roundcube-webmail/
git commit -m "Roundcube webmail Helm chart for Morpheus"
git push
```

### 2. Create App Blueprint

1. Navigate to **Library > Blueprints > App Blueprints**
2. Click **+ ADD** button
3. Select **"Helm"** as the **Type**
4. Select your Git integration
5. Select the repository
6. Enter branch name (e.g., `main`)
7. Specify **Chart Path**: `roundcube-webmail`

### 3. Blueprint Configuration

- **Name**: Roundcube Webmail
- **Description**: Webmail interface for email access
- **Category**: Mail Server
- **Helm Values**: Override values as needed

### 4. Deploy

1. Navigate to **Provisioning > Apps**
2. Click **+ ADD** button
3. Select the Roundcube blueprint
4. Fill in required parameters
5. Deploy

## Uninstall

```bash
helm uninstall roundcube-webmail --namespace mail
```

**Note**: PVCs are not deleted by default. To delete manually:

```bash
kubectl delete pvc roundcube-webmail-pvc -n mail
```

## Troubleshooting

### Check pod logs

```bash
kubectl logs <pod-name> -n mail
```

### Check service endpoints

```bash
kubectl get endpoints -n mail
```

### Check ingress status

```bash
kubectl describe ingress roundcube-webmail -n mail
```

### Mail server connection issues

Verify Qmail server is accessible:

```bash
# From within the cluster
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup qmail-server.mail.svc.cluster.local
```

### Database connection issues

If using MySQL/PostgreSQL, verify database connectivity:

```bash
kubectl exec -it <roundcube-pod> -n mail -- php -r "echo 'Database test';"
```

## Customization

### Custom Configuration

Roundcube configuration is stored in `/var/www/html/config/config.inc.php`. You can customize it by:

1. Mounting a ConfigMap with custom configuration
2. Using init containers to modify configuration
3. Editing the configuration file directly in the pod

### Themes and Plugins

Roundcube supports themes and plugins. To add them:

1. Create a custom Docker image based on `roundcube/roundcubemail`
2. Install themes/plugins in the Dockerfile
3. Update the image in `values.yaml`

## Security Considerations

- Use HTTPS/TLS for all webmail access
- Regularly update Roundcube image
- Configure proper authentication
- Use strong passwords
- Enable security headers via Ingress annotations
- Consider using network policies to restrict access

## License

MIT License

