# Yeni Servisler - Helm Charts

Bu dokümantasyon, yeni eklenen Helm chart'ları açıklar.

## 📦 Eklenen Servisler

### Monitoring & Observability
- **Prometheus** - Metrics collection ve monitoring
- **Grafana** - Visualization ve dashboard platformu
- **Jaeger** - Distributed tracing sistemi

### Logging
- **EFK Stack** - Elasticsearch, Fluentd, Kibana log yönetim platformu

### CI/CD
- **Jenkins** - Continuous Integration/Continuous Deployment platformu
- **ArgoCD** - GitOps deployment platformu
- **GitLab Runner** - GitLab CI/CD runner

### Code Quality
- **SonarQube** - Code quality ve security analiz platformu

### Message Brokers
- **Apache Kafka** - Distributed streaming platform
- **RabbitMQ** - Message broker ve queue sistemi
- **Redis** - In-memory cache ve message broker

### Identity & Access Management
- **Keycloak** - Open source Identity ve Access Management

## 🚀 Deployment

Her servis için aynı deployment yöntemi kullanılır:

```bash
# Örnek: Prometheus
helm install prometheus ./prometheus --namespace monitoring

# Örnek: Grafana
helm install grafana ./grafana --namespace monitoring

# Örnek: Jenkins
helm install jenkins ./jenkins --namespace cicd
```

## 🌐 Ingress Yapılandırması

Tüm servisler standart ingress yapılandırması kullanır:

```yaml
ingress:
  enabled: true
  className: "nginx"
  host: <service-name>.cloudflex.tr
  tls:
    enabled: true
    secretName: "cloudflex-wildcard-tls"
```

## 📋 Servis Detayları

### Prometheus
- **Port**: 9090
- **Host**: prometheus.cloudflex.tr
- **Storage**: 50Gi
- **Image**: prom/prometheus:v2.48.0

### Grafana
- **Port**: 3000
- **Host**: grafana.cloudflex.tr
- **Storage**: 10Gi
- **Image**: grafana/grafana:10.2.0
- **Default Credentials**: admin/admin

### Redis
- **Port**: 6379
- **Ingress**: Disabled (internal use)
- **Storage**: 10Gi
- **Image**: redis:7-alpine

### Keycloak
- **Port**: 8080
- **Host**: keycloak.cloudflex.tr
- **Storage**: 10Gi
- **Image**: quay.io/keycloak/keycloak:latest
- **Default Credentials**: admin/admin123

### SonarQube
- **Port**: 9000
- **Host**: sonarqube.cloudflex.tr
- **Storage**: 20Gi
- **Image**: sonarqube:community
- **Database**: PostgreSQL (external)

### Jenkins
- **Port**: 8080
- **Host**: jenkins.cloudflex.tr
- **Storage**: 50Gi
- **Image**: jenkins/jenkins:lts
- **Default Credentials**: admin/admin123

### ArgoCD
- **Port**: 8080
- **Host**: argocd.cloudflex.tr
- **Storage**: 10Gi
- **Image**: quay.io/argoproj/argocd:latest

### Jaeger
- **Port**: 16686
- **Host**: jaeger.cloudflex.tr
- **Storage**: 10Gi
- **Image**: jaegertracing/all-in-one:latest

### Apache Kafka
- **Port**: 9092
- **Ingress**: Disabled (internal use)
- **Storage**: 50Gi
- **Image**: apache/kafka:latest
- **Zookeeper**: Included

### RabbitMQ
- **Port**: 5672 (AMQP), 15672 (Management)
- **Host**: rabbitmq.cloudflex.tr
- **Storage**: 20Gi
- **Image**: rabbitmq:3-management
- **Default Credentials**: admin/admin123

### EFK Stack
- **Kibana Port**: 5601
- **Elasticsearch Port**: 9200
- **Host**: kibana.cloudflex.tr
- **Storage**: 20Gi (Kibana), 50Gi (Elasticsearch)
- **Images**: 
  - docker.elastic.co/kibana/kibana:8.11.0
  - docker.elastic.co/elasticsearch/elasticsearch:8.11.0
  - fluent/fluentd:v1.16-debian-1

### GitLab Runner
- **Port**: 8093
- **Ingress**: Disabled (internal use)
- **Storage**: 10Gi
- **Image**: gitlab/gitlab-runner:latest

## 🔐 Güvenlik Notları

- Tüm şifreler `values.yaml` dosyalarında tanımlıdır
- Production ortamında şifreleri değiştirin
- Secrets Kubernetes Secret objeleri olarak saklanır
- TLS sertifikaları ingress üzerinden yönetilir

## 📊 Resource Limits

Her servis için varsayılan resource limits tanımlıdır. Production ortamında ihtiyaca göre ayarlayın.

## 🔧 Customization

Her servis için `values.yaml` dosyasını düzenleyerek özelleştirme yapabilirsiniz:

```bash
# Örnek: Grafana storage boyutunu değiştirme
helm install grafana ./grafana \
  --set grafana.storage.size=20Gi \
  --namespace monitoring
```

## 📝 Notlar

- Bazı servisler (Redis, Kafka, GitLab Runner) internal kullanım için ingress devre dışıdır
- Database gerektiren servisler (SonarQube, Keycloak) external database kullanır
- EFK Stack için Elasticsearch ve Kibana ayrı deployment'lar olarak oluşturulmuştur
- Fluentd DaemonSet olarak deploy edilir (her node'da çalışır)
