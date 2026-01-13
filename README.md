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
├── mysql-database/                    # MySQL Database Helm Chart
│   ├── Chart.yaml                     # Helm chart metadata
│   ├── values.yaml                    # MySQL configuration values
│   ├── README.md                      # MySQL chart documentation
│   └── templates/
│       ├── _helpers.tpl               # Helm template helper functions
│       ├── secret.yaml                # Database credentials secret
│       ├── database-deployment.yaml   # MySQL deployment
│       ├── database-service.yaml      # MySQL service
│       └── database-pvc.yaml          # Persistent volume claim
│
├── mariadb-database/                  # MariaDB Database Helm Chart
│   ├── Chart.yaml                     # Helm chart metadata
│   ├── values.yaml                    # MariaDB configuration values
│   ├── README.md                      # MariaDB chart documentation
│   └── templates/
│       ├── _helpers.tpl               # Helm template helper functions
│       ├── secret.yaml                # Database credentials secret
│       ├── database-deployment.yaml   # MariaDB deployment
│       ├── database-service.yaml      # MariaDB service
│       └── database-pvc.yaml          # Persistent volume claim
│
├── mssql-database/                    # Microsoft SQL Server Database Helm Chart
│   ├── Chart.yaml                     # Helm chart metadata
│   ├── values.yaml                    # MSSQL configuration values
│   ├── README.md                      # MSSQL chart documentation
│   └── templates/
│       ├── _helpers.tpl               # Helm template helper functions
│       ├── secret.yaml                # Database credentials secret
│       ├── database-deployment.yaml   # MSSQL deployment
│       ├── database-service.yaml      # MSSQL service
│       └── database-pvc.yaml          # Persistent volume claim
│
├── qmail-server/                      # Qmail Mail Server Helm Chart
│   ├── Chart.yaml                     # Helm chart metadata
│   ├── values.yaml                    # Qmail configuration values
│   ├── README.md                      # Qmail chart documentation
│   └── templates/
│       ├── _helpers.tpl               # Helm template helper functions
│       ├── mail-deployment.yaml       # Qmail deployment
│       ├── mail-service.yaml          # Qmail service
│       └── mail-pvc.yaml             # Persistent volume claim
│
└── roundcube-webmail/                 # Roundcube Webmail Helm Chart
    ├── Chart.yaml                     # Helm chart metadata
    ├── values.yaml                    # Roundcube configuration values
    ├── README.md                      # Roundcube chart documentation
    └── templates/
        ├── _helpers.tpl               # Helm template helper functions
        ├── webmail-deployment.yaml    # Roundcube deployment
        ├── webmail-service.yaml       # Roundcube service
        ├── webmail-ingress.yaml       # Ingress for web access
        └── webmail-pvc.yaml           # Persistent volume claim
```
<｜tool▁calls▁begin｜><｜tool▁call▁begin｜>
read_file

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

### 🗄️ MariaDB Database
- **Directory**: `mariadb-database/`
- **Chart Name**: `mariadb-database`
- **Version**: 0.1.0
- **Image**: mariadb:11.0
- **Port**: 3306
- **Features**: Persistent storage, root and user authentication, resource limits

### 🪟 Microsoft SQL Server Database
- **Directory**: `mssql-database/`
- **Chart Name**: `mssql-database`
- **Version**: 0.1.0
- **Image**: mcr.microsoft.com/mssql/server:2022-latest
- **Port**: 1433
- **Features**: Persistent storage, SA authentication, product ID selection (Express/Developer/Enterprise), resource limits (minimum 2GB memory)

### 📧 Qmail Mail Server
- **Directory**: `qmail-server/`
- **Chart Name**: `qmail-server`
- **Version**: 0.1.0
- **Image**: robreardon/qmail:latest
- **Ports**: 25 (SMTP), 587 (SMTP Submission), 110 (POP3), 143 (IMAP), 995 (POP3S), 993 (IMAPS)
- **Features**: Standalone SMTP server, no external relay required, persistent storage, configurable domain, full mail server capabilities

### 🌐 Roundcube Webmail
- **Directory**: `roundcube-webmail/`
- **Chart Name**: `roundcube-webmail`
- **Version**: 0.1.0
- **Image**: roundcube/roundcubemail:1.6-apache
- **Port**: 80 (HTTP)
- **Features**: Modern webmail interface, Qmail integration via IMAP/SMTP, HTTPS support, persistent storage, responsive UI

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

**MariaDB Blueprint:**
1. Repeat the same steps
2. **Chart Path**: `mariadb-database`
3. **Name**: MariaDB Database

**MSSQL Blueprint:**
1. Repeat the same steps
2. **Chart Path**: `mssql-database`
3. **Name**: Microsoft SQL Server Database

**Qmail Blueprint:**
1. Repeat the same steps
2. **Chart Path**: `qmail-server`
3. **Name**: Qmail Mail Server

**Roundcube Blueprint:**
1. Repeat the same steps
2. **Chart Path**: `roundcube-webmail`
3. **Name**: Roundcube Webmail

#### 4. Deploy

1. **Provisioning > Apps** → **+ ADD**
2. Select your desired blueprint (PostgreSQL, MongoDB, MySQL, MariaDB, MSSQL, Qmail, or Roundcube)
3. Fill in required parameters:
   - For databases: Database name, Username/Password, Storage size, Resource limits
   - For Qmail: Mail domain, Hostname, Storage size, Resource limits
   - For Roundcube: Webmail hostname, Mail server connection, Storage size, Resource limits
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
├── mysql-db-instance-2          (Another MySQL instance)
├── mariadb-db-instance-1        (MariaDB app instance)
├── mariadb-db-instance-2        (Another MariaDB instance)
├── mssql-db-instance-1          (MSSQL app instance)
├── mssql-db-instance-2          (Another MSSQL instance)
├── qmail-server-instance-1      (Qmail mail server instance)
├── qmail-server-instance-2      (Another Qmail mail server instance)
├── roundcube-webmail-instance-1  (Roundcube webmail instance)
└── roundcube-webmail-instance-2  (Another Roundcube webmail instance)
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

### Deploy MariaDB

```bash
cd mariadb-database
helm install mariadb-db . --namespace <namespace>
```

### Deploy MSSQL

```bash
cd mssql-database
helm install mssql-db . --namespace <namespace>
```

**Note**: MSSQL requires minimum 2GB memory. Ensure your cluster has sufficient resources.

### Deploy Qmail Mail Server

```bash
cd qmail-server
helm install qmail-server . --namespace <namespace>
```

**Note**: Configure DNS records (MX, SPF, DKIM, DMARC) for proper mail delivery.

### Deploy Roundcube Webmail

```bash
cd roundcube-webmail
helm install roundcube-webmail . --namespace <namespace>
```

**Note**: Ensure Qmail server is deployed and accessible. Configure ingress hostname for web access.

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
- NGINX Ingress Controller (or compatible ingress controller)
- (For Morpheus) Morpheus platform access and SCM integration

## 🌐 Ingress Configuration

All charts that require external access are configured to work with **NGINX Ingress Controller**. The ingress configuration is standardized across all charts.

### Charts with Ingress Support

1. **Roundcube Webmail** - HTTP/HTTPS ingress for webmail access
2. **Qmail Server** - TCP ConfigMap for mail ports (SMTP, IMAP, POP3) + HTTP ingress for web admin

### Standard Ingress Configuration

All ingress-enabled charts use the following standard configuration in `values.yaml`:

```yaml
ingress:
  enabled: true
  className: "nginx"                    # NGINX Ingress Controller
  host: <your-hostname>                 # e.g., webmail.cloudflex.tr
  http:
    enabled: true                        # Enable HTTP ingress (for Qmail)
  annotations:
    # Custom annotations can be added here
    # Example: cert-manager.io/cluster-issuer: "letsencrypt-prod"
  tls:
    enabled: true
    secretName: "cloudflex-wildcard-tls" # TLS certificate secret name
```

### Qmail Server Ingress

Qmail server uses a **dual ingress approach**:

1. **TCP ConfigMap** - For mail protocol ports (25, 587, 110, 143, 995, 993)
   - Automatically created in `ingress-nginx` namespace
   - Routes TCP traffic to Qmail service

2. **HTTP Ingress** - For web admin interface (port 80)
   - Standard HTTP ingress for web access
   - Configured via `ingress.http.enabled: true`

### Customizing Ingress

To customize ingress settings for your environment:

1. **Update values.yaml** in each chart:
   ```yaml
   ingress:
     enabled: true
     className: "nginx"              # Your ingress class name
     host: "your-domain.com"         # Your domain
     tls:
       enabled: true
       secretName: "your-tls-secret" # Your TLS certificate
   ```

2. **Or override during deployment**:
   ```bash
   helm install roundcube-webmail . \
     --set ingress.host=webmail.yourdomain.com \
     --set ingress.tls.secretName=your-tls-secret \
     --namespace mail
   ```

### DNS Configuration

After deploying, configure DNS records:

- **Roundcube Webmail**: `webmail.cloudflex.tr` → Ingress IP
- **Qmail Web Admin**: `mail.cloudflex.tr` → Ingress IP
- **Qmail Mail**: `mail.cloudflex.tr` → Ingress IP (for MX records)

Get the Ingress Controller's external IP:
```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

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
- [MariaDB Chart Documentation](./mariadb-database/README.md)
- [MSSQL Chart Documentation](./mssql-database/README.md)
- [Qmail Mail Server Chart Documentation](./qmail-server/README.md)
- [Roundcube Webmail Chart Documentation](./roundcube-webmail/README.md)

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
