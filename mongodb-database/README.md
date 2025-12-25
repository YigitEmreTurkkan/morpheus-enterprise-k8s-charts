# MongoDB Database Helm Chart

This project is a Helm chart for deploying MongoDB database on Kubernetes. It is designed for use with cloud management platforms like Morpheus.

## Project Structure

```
mongodb-database/
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

- **MongoDB Deployment**: MongoDB 7.0 container
- **Service**: ClusterIP service (port 27017)
- **PersistentVolumeClaim**: PVC for data persistence
- **Secret**: Database username, password, and database name

## Prerequisites

- Kubernetes cluster
- Helm 3.x
- kubectl configured

## Installation

### Deploy with Helm

```bash
cd mongodb-database
helm install mongodb-db .
```

### Check deployment status

```bash
kubectl get pods
kubectl get services
kubectl get pvc
```

## Configuration

You can configure the following settings in the `values.yaml` file:

- **Database Image**: MongoDB image repository and tag
- **Storage Size**: PVC size (default: 10Gi)
- **Credentials**: Database name, username, password, root user credentials
- **Resources**: CPU and memory limits

## Database Connection

### Using port-forward

```bash
kubectl port-forward service/<release-name> 27017:27017
```

### Connect from pod

```bash
kubectl exec -it <pod-name> -- mongosh -u <username> -p <password>
```

### Connect with MongoDB Compass

Connection string:
```
mongodb://<username>:<password>@localhost:27017/<database-name>?authSource=admin
```

## Morpheus Integration

To add this Helm chart to the Morpheus platform, follow these steps:

### 1. Git Repository Setup

Upload your chart to a Git repository (GitHub, GitLab, Bitbucket, etc.):

```bash
git init
git add .
git commit -m "MongoDB Helm chart for Morpheus"
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
7. Specify the path to your chart as **Chart Path** (e.g., `mongodb-database`)

### 4. Blueprint Configuration

- **Name**: MongoDB Database
- **Description**: MongoDB database deployment
- **Category**: Database
- **Helm Values**: You can override values from the `values.yaml` file

### 5. Deploy

1. Navigate to **Provisioning > Apps**
2. Click **+ ADD** button
3. Select the MongoDB blueprint you created
4. Fill in required parameters (database name, username, password, storage size, etc.)
5. Deploy

### Notes

- Your chart must be in Helm 3.x format (✓ Chart.yaml apiVersion: v2)
- All required template files must be present (✓ _helpers.tpl, deployment, service, pvc, secret)
- The `values.yaml` file can be overridden in Morpheus
- PostgreSQL and MongoDB charts can be in different folders in the same repository

## Uninstall

```bash
helm uninstall mongodb-db
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

### Test MongoDB connection

```bash
kubectl exec -it <pod-name> -- mongosh --eval "db.adminCommand('ping')"
```

## License

MIT License
