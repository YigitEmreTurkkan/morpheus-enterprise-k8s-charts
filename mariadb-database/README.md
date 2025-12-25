# MariaDB Database Helm Chart

This project is a Helm chart for deploying MariaDB database on Kubernetes. It is designed for use with cloud management platforms like Morpheus.

## Project Structure

```
mariadb-database/
├── Chart.yaml
├── values.yaml
├── README.md
└── templates/
    ├── _helpers.tpl
    ├── secret.yaml
    ├── database-deployment.yaml
    ├── database-service.yaml
    └── database-pvc.yaml
```

## Components

- **MariaDB Deployment**: MariaDB 11.0 container
- **Service**: ClusterIP service (port 3306)
- **PersistentVolumeClaim**: PVC for data persistence
- **Secret**: Database username, password, root password, and database name

## Prerequisites

- Kubernetes cluster
- Helm 3.x
- kubectl configured

## Installation

### Deploy with Helm

```bash
cd mariadb-database
helm install mariadb-db .
```

### Check deployment status

```bash
kubectl get pods
kubectl get services
kubectl get pvc
```

## Configuration

You can configure the following settings in the `values.yaml` file:

- **Database Image**: MariaDB image repository and tag
- **Storage Size**: PVC size (default: 10Gi)
- **Credentials**: Database name, username, password, and root password
- **Resources**: CPU and memory limits

## Database Connection

### Using port-forward

```bash
kubectl port-forward service/<release-name> 3306:3306
```

### Connect from pod

```bash
kubectl exec -it <pod-name> -- mysql -u <username> -p<password> <database-name>
```

## Morpheus Integration

To add this Helm chart to the Morpheus platform, follow these steps:

### 1. Git Repository Setup

Upload your chart to a Git repository (GitHub, GitLab, Bitbucket, etc.):

```bash
git init
git add .
git commit -m "MariaDB Helm chart for Morpheus"
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
7. Specify the path to your chart as **Chart Path** (e.g., `mariadb-database`)

### 4. Blueprint Configuration

- **Name**: MariaDB Database
- **Description**: MariaDB database deployment
- **Category**: Database
- **Helm Values**: You can override values from the `values.yaml` file

### 5. Deploy

1. Navigate to **Provisioning > Apps**
2. Click **+ ADD** button
3. Select the MariaDB blueprint you created
4. Fill in required parameters (database name, username, password, root password, storage size, etc.)
5. Deploy

### Notes

- Your chart must be in Helm 3.x format (✓ Chart.yaml apiVersion: v2)
- All required template files must be present (✓ _helpers.tpl, deployment, service, pvc, secret)
- The `values.yaml` file can be overridden in Morpheus

## Uninstall

```bash
helm uninstall mariadb-db
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

### Check secrets

```bash
kubectl get secret <release-name>-secret -o yaml
```

### Check PVC status

```bash
kubectl describe pvc <pvc-name>
```

## License

MIT License

