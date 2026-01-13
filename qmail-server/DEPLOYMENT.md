# Qmail Server Deployment Guide - cloudflex.tr

Bu rehber, Qmail mail sunucusunu Kubernetes cluster'ınızda Ingress kullanarak deploy etmek için adım adım talimatlar içerir.

## Ön Gereksinimler

- Kubernetes cluster (1.19+)
- Helm 3.x
- NGINX Ingress Controller kurulu ve çalışıyor
- kubectl yapılandırılmış
- DNS yönetim erişimi (cloudflex.tr için)

## 1. Deployment

### Namespace Oluşturma (Opsiyonel)

```bash
kubectl create namespace mail
```

### Helm ile Deploy

```bash
cd qmail-server
helm install qmail-server . --namespace mail
```

veya namespace belirtmeden:

```bash
helm install qmail-server . --namespace mail --create-namespace
```

## 2. Ingress Yapılandırması

### Mevcut TCP ConfigMap Kontrolü

Önce mevcut `tcp-services` ConfigMap'inin olup olmadığını kontrol edin:

```bash
kubectl get configmap tcp-services -n ingress-nginx
```

### Senaryo A: ConfigMap Yoksa

Chart otomatik olarak oluşturacaktır. Sadece deploy edin:

```bash
helm install qmail-server . --namespace mail
```

### Senaryo B: ConfigMap Zaten Varsa

Mevcut ConfigMap'e Qmail portlarını eklemeniz gerekiyor:

#### Yöntem 1: Manuel Merge

```bash
# Mevcut ConfigMap'i al
kubectl get configmap tcp-services -n ingress-nginx -o yaml > tcp-services-backup.yaml

# Düzenle ve Qmail portlarını ekle
# data: bölümüne şunları ekleyin:
#   "25": "mail/qmail-server:25"
#   "587": "mail/qmail-server:587"
#   "110": "mail/qmail-server:110"
#   "143": "mail/qmail-server:143"
#   "995": "mail/qmail-server:995"
#   "993": "mail/qmail-server:993"

# Uygula
kubectl apply -f tcp-services-backup.yaml
```

#### Yöntem 2: kubectl patch ile

```bash
kubectl patch configmap tcp-services -n ingress-nginx --type merge -p '{
  "data": {
    "25": "mail/qmail-server:25",
    "587": "mail/qmail-server:587",
    "110": "mail/qmail-server:110",
    "143": "mail/qmail-server:143",
    "995": "mail/qmail-server:995",
    "993": "mail/qmail-server:993"
  }
}'
```

### Ingress Controller'ı Yeniden Başlat

ConfigMap değişikliklerinin etkili olması için:

```bash
kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx
```

## 3. Durum Kontrolü

### Pod Durumu

```bash
kubectl get pods -n mail
```

### Service Durumu

```bash
kubectl get svc -n mail
```

### PVC Durumu

```bash
kubectl get pvc -n mail
```

### TCP ConfigMap Kontrolü

```bash
kubectl get configmap tcp-services -n ingress-nginx -o yaml
```

## 4. Ingress IP Adresini Alma

```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

`EXTERNAL-IP` veya `LoadBalancer IP` değerini not edin. Bu IP'yi DNS A kaydında kullanacaksınız.

## 5. DNS Yapılandırması

DNS sağlayıcınızda (örneğin Cloudflare, Namecheap, vb.) aşağıdaki kayıtları oluşturun:

### A Kaydı

```
mail.cloudflex.tr    A    <INGRESS-EXTERNAL-IP>
```

### MX Kaydı

```
cloudflex.tr    MX    10    mail.cloudflex.tr
```

### SPF Kaydı

```
cloudflex.tr    TXT    "v=spf1 mx a:mail.cloudflex.tr ~all"
```

### DMARC Kaydı (Önerilen)

```
_dmarc.cloudflex.tr    TXT    "v=DMARC1; p=none; rua=mailto:admin@cloudflex.tr"
```

## 6. DNS Yayılımını Kontrol Etme

DNS kayıtlarının yayıldığını kontrol edin:

```bash
# MX kaydı
dig cloudflex.tr MX +short

# A kaydı
dig mail.cloudflex.tr A +short

# SPF kaydı
dig cloudflex.tr TXT +short | grep spf

# DMARC kaydı
dig _dmarc.cloudflex.tr TXT +short
```

## 7. Test Etme

### SMTP Port Testi

```bash
telnet mail.cloudflex.tr 25
```

veya

```bash
nc -zv mail.cloudflex.tr 25
```

### E-posta Gönderme Testi

1. E-posta istemcinizi yapılandırın:
   - SMTP Server: `mail.cloudflex.tr`
   - SMTP Port: `25` veya `587`
   - IMAP Server: `mail.cloudflex.tr`
   - IMAP Port: `143` veya `993` (SSL)

2. Test e-postası gönderin ve alın.

## 8. Troubleshooting

### Pod Çalışmıyor

```bash
kubectl describe pod <pod-name> -n mail
kubectl logs <pod-name> -n mail
```

### Service Bağlantı Sorunu

```bash
kubectl get endpoints -n mail
kubectl describe svc qmail-server -n mail
```

### Ingress TCP Portları Çalışmıyor

```bash
# ConfigMap'i kontrol et
kubectl get configmap tcp-services -n ingress-nginx -o yaml

# Ingress Controller loglarını kontrol et
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Ingress Controller'ı yeniden başlat
kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx
```

### DNS Sorunları

- DNS kayıtlarının yayılması 24-48 saat sürebilir
- DNS cache'i temizleyin: `sudo systemd-resolve --flush-caches` (Linux)
- Online DNS checker kullanın: https://mxtoolbox.com/

## 9. Upgrade

```bash
helm upgrade qmail-server . --namespace mail
```

## 10. Uninstall

```bash
helm uninstall qmail-server --namespace mail
```

**Not**: ConfigMap'teki Qmail portlarını manuel olarak kaldırmanız gerekebilir:

```bash
kubectl patch configmap tcp-services -n ingress-nginx --type json -p='[
  {"op": "remove", "path": "/data/25"},
  {"op": "remove", "path": "/data/587"},
  {"op": "remove", "path": "/data/110"},
  {"op": "remove", "path": "/data/143"},
  {"op": "remove", "path": "/data/995"},
  {"op": "remove", "path": "/data/993"}
]'
```

## Önemli Notlar

- DNS yayılımı 24-48 saat sürebilir
- Firewall kurallarınızın 25, 587, 110, 143, 995, 993 portlarını açtığından emin olun
- SPF kaydı olmadan e-postalar spam olarak işaretlenebilir
- Production ortamında TLS/SSL sertifikaları kullanın
- Düzenli olarak logları kontrol edin

