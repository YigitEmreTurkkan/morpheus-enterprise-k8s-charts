# PostgreSQL Database Helm Chart

Bu proje, Kubernetes üzerinde PostgreSQL veritabanını deploy etmek için bir Helm chart'ıdır. Morpheus gibi cloud management platformlarında kullanılmak üzere tasarlanmıştır.

## Proje Yapısı

```
PostgreSQL Manifests/
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

## Bileşenler

- **PostgreSQL Deployment**: PostgreSQL 15-alpine container'ı
- **Service**: ClusterIP servisi (port 5432)
- **PersistentVolumeClaim**: Veri kalıcılığı için PVC
- **Secret**: Veritabanı kullanıcı adı, şifre ve database adı

## Prerequisites

- Kubernetes cluster
- Helm 3.x
- kubectl yapılandırılmış

## Kurulum

### Helm ile Deploy

```bash
cd "PostgreSQL Manifests"
helm install postgres-db .
```

### Deploy durumunu kontrol et

```bash
kubectl get pods
kubectl get services
kubectl get pvc
```

## Konfigürasyon

`values.yaml` dosyasından aşağıdaki ayarları yapabilirsiniz:

- **Database Image**: PostgreSQL image repository ve tag
- **Storage Size**: PVC boyutu (varsayılan: 10Gi)
- **Credentials**: Database adı, kullanıcı adı ve şifre
- **Resources**: CPU ve memory limitleri

## Veritabanına Bağlanma

### Port-forward ile

```bash
kubectl port-forward service/<release-name> 5432:5432
```

### Pod içinden bağlanma

```bash
kubectl exec -it <pod-name> -- psql -U <username> -d <database-name>
```

## Morpheus Entegrasyonu

Bu Helm chart'ı Morpheus platformuna eklemek için aşağıdaki adımları izleyin:

### 1. Git Deposu Hazırlığı

Chart'ınızı bir Git deposuna yükleyin (GitHub, GitLab, Bitbucket vb.):

```bash
git init
git add .
git commit -m "PostgreSQL Helm chart for Morpheus"
git remote add origin <your-repo-url>
git push -u origin main
```

### 2. Morpheus'ta SCM Entegrasyonu

1. Morpheus UI'da **Administration > Integrations > Source Control** bölümüne gidin
2. Yeni bir SCM Integration oluşturun (GitHub, GitLab vb.)
3. Repository URL'ini ve credentials'ları girin

### 3. App Blueprint Oluşturma

1. **Library > Blueprints > App Blueprints** yolunu izleyin
2. **+ ADD** butonuna tıklayın
3. **Type** olarak **"Helm"** seçeneğini belirleyin
4. **SCM Integration** bölümünde oluşturduğunuz Git entegrasyonunu seçin
5. **Repository** olarak chart'ınızın bulunduğu repo'yu seçin
6. **Branch or Tag** olarak branch adını girin (örn: `main`, `master`)
7. **Chart Path** olarak chart'ınızın yolunu belirtin (örn: `PostgreSQL Manifests` veya `.`)

### 4. Blueprint Yapılandırması

- **Name**: PostgreSQL Database
- **Description**: PostgreSQL database deployment
- **Category**: Database
- **Helm Values**: `values.yaml` dosyasındaki değerleri override edebilirsiniz

### 5. Deploy

1. **Provisioning > Apps** bölümüne gidin
2. **+ ADD** butonuna tıklayın
3. Oluşturduğunuz PostgreSQL blueprint'ini seçin
4. Gerekli parametreleri doldurun (database name, username, password, storage size vb.)
5. Deploy edin

### Notlar

- Chart'ınız Helm 3.x formatında olmalıdır (✓ Chart.yaml apiVersion: v2)
- Tüm gerekli template dosyaları mevcut olmalıdır (✓ _helpers.tpl, deployment, service, pvc, secret)
- `values.yaml` dosyası Morpheus'ta override edilebilir

## Uninstall

```bash
helm uninstall postgres-db
```

**Not**: PVC'ler varsayılan olarak silinmez. Manuel olarak silmek için:

```bash
kubectl delete pvc <pvc-name>
```

## Troubleshooting

### Pod loglarını kontrol et

```bash
kubectl logs <pod-name>
```

### Secret'ları kontrol et

```bash
kubectl get secret <release-name>-secret -o yaml
```

### PVC durumunu kontrol et

```bash
kubectl describe pvc <pvc-name>
```

## License

MIT License
