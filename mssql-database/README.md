# Microsoft SQL Server Database Helm Chart

This project is a Helm chart for deploying Microsoft SQL Server database on Kubernetes. It is designed for use with cloud management platforms like Morpheus.

## Project Structure

```
mssql-database/
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

- **MSSQL Deployment**: Microsoft SQL Server 2022 container
- **Service**: ClusterIP service (port 1433)
- **PersistentVolumeClaim**: PVC for data persistence
- **Secret**: SA password, database name, username, and password

## Prerequisites

- Kubernetes cluster
- Helm 3.x
- kubectl configured
- **Important**: MSSQL requires minimum 2GB memory

## Installation

### Deploy with Helm

```bash
cd mssql-database
helm install mssql-db .
```

### Check deployment status

```bash
kubectl get pods
kubectl get services
kubectl get pvc
```

## Configuration

You can configure the following settings in the `values.yaml` file:

- **Database Image**: MSSQL image repository and tag
- **Storage Size**: PVC size (default: 10Gi)
- **Credentials**: SA password, database name, username, and password
- **Product ID**: SQL Server edition (Express, Developer, Enterprise, etc.)
- **Resources**: CPU and memory limits (minimum 2GB memory recommended)

### Product ID Options

- `Express` - Free edition (default)
- `Developer` - Free for development
- `Enterprise` - Full-featured edition (requires license)
- `EnterpriseCore` - Enterprise core edition
- `Standard` - Standard edition
- `Web` - Web edition

## Database Connection

### Using port-forward

```bash
kubectl port-forward service/<release-name> 1433:1433
```

### Connect from pod

```bash
kubectl exec -it <pod-name> -- /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P '<sa-password>'
```

### Create Database and User

After connecting, you can create a database and user:

```sql
CREATE DATABASE votingdb;
GO
USE votingdb;
GO
CREATE LOGIN votinguser WITH PASSWORD = 'YourStrong@Passw0rd';
GO
CREATE USER votinguser FOR LOGIN votinguser;
GO
ALTER SERVER ROLE sysadmin ADD MEMBER votinguser;
GO
```

## Morpheus Integration

To add this Helm chart to the Morpheus platform, follow these steps:

### 1. Git Repository Setup

Upload your chart to a Git repository (GitHub, GitLab, Bitbucket, etc.):

```bash
git init
git add .
git commit -m "MSSQL Helm chart for Morpheus"
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
7. Specify the path to your chart as **Chart Path** (e.g., `mssql-database`)

### 4. Blueprint Configuration

- **Name**: Microsoft SQL Server Database
- **Description**: MSSQL database deployment
- **Category**: Database
- **Helm Values**: You can override values from the `values.yaml` file

### 5. Deploy

1. Navigate to **Provisioning > Apps**
2. Click **+ ADD** button
3. Select the MSSQL blueprint you created
4. Fill in required parameters:
   - SA password (must meet complexity requirements)
   - Database name
   - Username/Password
   - Product ID (Express, Developer, etc.)
   - Storage size
   - Resource limits (minimum 2GB memory)
5. Deploy

### Notes

- Your chart must be in Helm 3.x format (✓ Chart.yaml apiVersion: v2)
- All required template files must be present (✓ _helpers.tpl, deployment, service, pvc, secret)
- The `values.yaml` file can be overridden in Morpheus
- **Important**: MSSQL requires at least 2GB of memory to run properly
- SA password must meet SQL Server complexity requirements (uppercase, lowercase, numbers, special characters)

## Uninstall

```bash
helm uninstall mssql-db
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

### Check if pod is running

MSSQL may take a few minutes to start. Check status:

```bash
kubectl get pods -w
```

### Check secrets

```bash
kubectl get secret <release-name>-secret -o yaml
```

### Check PVC status

```bash
kubectl describe pvc <pvc-name>
```

### Common Issues

1. **Pod crashes**: Ensure memory limit is at least 2GB
2. **Connection refused**: Wait for MSSQL to fully initialize (may take 2-3 minutes)
3. **Password complexity**: SA password must meet SQL Server requirements

## License

MIT License

