# Morpheus Enterprise K8s Charts

This repository is a library of Helm charts for deployable applications on Kubernetes. All charts are **customized for integration with Morpheus Cloud Management Platform**.

## 📁 Repository Structure

```
morpheus-enterprise-k8s-charts/
├── README.md                          # This file - General library documentation
│
├── postgresql-database/               # PostgreSQL Database Helm Chart
│   ├── Chart.yaml                     # Helm chart metadata
│   ├── values.yaml                    # PostgreSQL configuration values
│   ├── README.md                      # PostgreSQL chart documentation
│   └── templates/
│       ├── _helpers.tpl               # Helm template helper functions
│       ├── secret.yaml                # Database credentials secret
│       ├── database-deployment.yaml   # PostgreSQL deployment
│       ├── database-service.yaml      # PostgreSQL service
│       └── database-pvc.yaml          # Persistent volume claim
│
├── mongodb-database/                  # MongoDB Database Helm Chart
│   ├── Chart.yaml                     # Helm chart metadata
│   ├── values.yaml                    # MongoDB configuration values
│   ├── README.md                      # MongoDB chart documentation
│   └── templates/
│       ├── _helpers.tpl               # Helm template helper functions
│       ├── secret.yaml                # Database credentials secret
│       ├── database-deployment.yaml   # MongoDB deployment
│       ├── database-service.yaml      # MongoDB service
│       └── database-pvc.yaml          # Persistent volume claim
│
└── mysql-database/                    # MySQL Database Helm Chart
    ├── Chart.yaml                     # Helm chart metadata
    ├── values.yaml                    # MySQL configuration values
    ├── README.md                      # MySQL chart documentation
    └── templates/
        ├── _helpers.tpl               # Helm template helper functions
        ├── secret.yaml                # Database credentials secret
        ├── database-deployment.yaml   # MySQL deployment
        ├── database-service.yaml      # MySQL service
        └── database-pvc.yaml          # Persistent volume claim
```

## 🎯 Purpose

This library provides ready-to-use Helm charts for commonly used applications and services. Each chart:

- ✅ **Customized for Morpheus** - Ready to use as Morpheus App Blueprint
- ✅ **Production-ready** - Follows best practices and security standards
- ✅ **Independently deployable** - Each chart can run standalone
- ✅ **Customizable** - Easily configurable via `values.yaml`

## 📦 Available Charts

### 🐘 PostgreSQL Database
- **Directory**: `postgresql-database/`
- **Chart Name**: `postgres-database`
- **Version**: 0.1.0
- **Image**: postgres:15-alpine
- **Port**: 5432
- **Features**: Persistent storage, secret management, resource limits

### 🍃 MongoDB Database
- **Directory**: `mongodb-database/`
- **Chart Name**: `mongodb-database`
- **Version**: 0.1.0
- **Image**: mongo:7.0
- **Port**: 27017
- **Features**: Persistent storage, root and user authentication, resource limits

### 🐬 MySQL Database
- **Directory**: `mysql-database/`
- **Chart Name**: `mysql-database`
- **Version**: 0.1.0
- **Image**: mysql:8.0
- **Port**: 3306
- **Features**: Persistent storage, root and user authentication, resource limits

## 🚀 Morpheus Integration

This library is specifically designed for use with **Morpheus Cloud Management Platform**. In Morpheus, each chart appears as a separate **App Blueprint** and can be deployed independently.

### Steps to Use in Morpheus

#### 1. Git Repository Setup

```bash
git clone <this-repository>
cd morpheus-enterprise-k8s-charts
```

#### 2. Morpheus SCM Integration

1. Navigate to **Administration > Integrations > Source Control** in Morpheus UI
2. Create a new SCM Integration (GitHub, GitLab, Bitbucket, etc.)
3. Enter this repository's URL and credentials

#### 3. Create App Blueprint

Create a separate blueprint for each chart:

**PostgreSQL Blueprint:**
1. **Library > Blueprints > App Blueprints** → **+ ADD**
2. **Type**: Helm
3. **SCM Integration**: Your Git integration
4. **Repository**: This repository
5. **Branch or Tag**: `main` (or your branch)
6. **Chart Path**: `postgresql-database`
7. **Name**: PostgreSQL Database
8. **Category**: Database

**MongoDB Blueprint:**
1. Repeat the same steps
2. **Chart Path**: `mongodb-database`
3. **Name**: MongoDB Database

**MySQL Blueprint:**
1. Repeat the same steps
2. **Chart Path**: `mysql-database`
3. **Name**: MySQL Database

#### 4. Deploy

1. **Provisioning > Apps** → **+ ADD**
2. Select your desired blueprint (PostgreSQL, MongoDB, or MySQL)
3. Fill in required parameters:
   - Database name
   - Username/Password
   - Storage size
   - Resource limits
4. Deploy

### Appearance in Morpheus

Each chart appears as a **separate app** in Morpheus:

```
Provisioning > Apps
├── postgres-db-instance-1      (PostgreSQL app instance)
├── postgres-db-instance-2      (Another PostgreSQL instance)
├── mongodb-db-instance-1        (MongoDB app instance)
├── mongodb-db-instance-2        (Another MongoDB instance)
├── mysql-db-instance-1          (MySQL app instance)
└── mysql-db-instance-2          (Another MySQL instance)
```

Each app instance:
- ✅ Can be scaled independently
- ✅ Can have its own values.yaml overrides
- ✅ Can be updated/deleted separately
- ✅ Can be deployed to different environments

## 🔧 Local Usage (Without Morpheus)

You can also use the charts directly with Helm:

### Deploy PostgreSQL

```bash
cd postgresql-database
helm install postgres-db . --namespace <namespace>
```

### Deploy MongoDB

```bash
cd mongodb-database
helm install mongodb-db . --namespace <namespace>
```

### Deploy MySQL

```bash
cd mysql-database
helm install mysql-db . --namespace <namespace>
```

### Override Values

```bash
helm install postgres-db . \
  --set database.storage.size=20Gi \
  --set database.credentials.databaseName=mydb \
  --namespace <namespace>
```

## 📋 Prerequisites

- Kubernetes cluster (1.19+)
- Helm 3.x
- kubectl configured
- (For Morpheus) Morpheus platform access and SCM integration

## 🏗️ Chart Structure

Each chart follows this standard structure:

```
<chart-name>/
├── Chart.yaml              # Helm chart metadata and version info
├── values.yaml             # Default configuration values
├── README.md               # Chart-specific documentation
└── templates/
    ├── _helpers.tpl        # Template helper functions
    ├── secret.yaml         # Kubernetes Secret (credentials)
    ├── database-deployment.yaml  # Application Deployment
    ├── database-service.yaml     # Kubernetes Service
    └── database-pvc.yaml         # PersistentVolumeClaim
```

## 🔐 Security

- All credentials are stored in Kubernetes Secrets
- Passwords are base64 encoded in values.yaml (should be overridden in production)
- Resource limits are configurable in each chart
- Network policies can be added (optional)

## 📝 Adding New Charts

To add a new chart:

1. Create a new directory: `<app-name>-<type>/` (e.g., `redis-cache/`, `nginx-proxy/`)
2. Create standard Helm chart structure
3. Use a unique `name` in `Chart.yaml`
4. Customize helper names in `templates/_helpers.tpl` according to chart name
5. Add `README.md`
6. Add the new chart to this main README.md

## 🧪 Testing

Each chart has passed Helm lint and template tests:

```bash
# Lint check
helm lint "./<chart-name>/"

# Template render test
helm template test "./<chart-name>/"
```

## 📚 Documentation

Each chart has its own detailed README.md file:
- [PostgreSQL Chart Documentation](./postgresql-database/README.md)
- [MongoDB Chart Documentation](./mongodb-database/README.md)
- [MySQL Chart Documentation](./mysql-database/README.md)

## 🤝 Contributing

To add new charts or improve existing ones:

1. Create a new branch
2. Make your changes
3. Ensure it passes Helm lint and tests
4. Create a pull request

## 📄 License

MIT License

## 🔗 Related Resources

- [Helm Documentation](https://helm.sh/docs/)
- [Morpheus Documentation](https://docs.morpheusdata.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

---

**Note**: This library is customized for use with Morpheus Cloud Management Platform, but can also be used with standard Helm commands.
