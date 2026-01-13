# SMTP Sorun Giderme Rehberi

## SMTP Neden Çalışmıyor?

SMTP'nin çalışmamasının birkaç yaygın nedeni vardır. Bu rehber sorunları tespit etmenize ve çözmenize yardımcı olacaktır.

## 1. TCP ConfigMap Kontrolü

### ConfigMap'in Var Olup Olmadığını Kontrol Edin

```bash
kubectl get configmap tcp-services -n ingress-nginx
```

### ConfigMap İçeriğini Kontrol Edin

```bash
kubectl get configmap tcp-services -n ingress-nginx -o yaml
```

**Beklenen çıktı:** `data` bölümünde Qmail portları olmalı:
```yaml
data:
  "25": "mail/qmail-server:25"
  "587": "mail/qmail-server:587"
  "110": "mail/qmail-server:110"
  "143": "mail/qmail-server:143"
  "995": "mail/qmail-server:995"
  "993": "mail/qmail-server:993"
```

### Sorun: ConfigMap'te Qmail Portları Yok

**Çözüm:** Patch job'u çalıştırın veya manuel olarak ekleyin:

```bash
# Otomatik patch (önerilen)
helm upgrade qmail-server ./qmail-server --namespace mail

# Veya manuel patch
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

## 2. Ingress Controller Kontrolü

### Ingress Controller'ın TCP Servislerini Desteklediğini Kontrol Edin

```bash
kubectl get deployment ingress-nginx-controller -n ingress-nginx -o yaml | grep tcp-services-configmap
```

**Beklenen çıktı:** `--tcp-services-configmap=ingress-nginx/tcp-services` argümanı olmalı.

### Sorun: TCP ConfigMap Argümanı Yok

**Çözüm:** Ingress controller'ı TCP ConfigMap'i kullanacak şekilde yapılandırın:

```bash
# Ingress controller deployment'ını düzenleyin
kubectl edit deployment ingress-nginx-controller -n ingress-nginx

# Container args'a ekleyin:
# - --tcp-services-configmap=ingress-nginx/tcp-services
```

## 3. Ingress Controller'ı Yeniden Başlatma

ConfigMap değişikliklerinden sonra ingress controller'ı yeniden başlatın:

```bash
kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx
```

## 4. Service Kontrolü

### Qmail Service'inin Çalıştığını Kontrol Edin

```bash
kubectl get svc -n mail
```

**Beklenen çıktı:** `qmail-server` service'i olmalı ve portlar açık olmalı.

### Service Detaylarını Kontrol Edin

```bash
kubectl describe svc qmail-server -n mail
```

## 5. Pod Kontrolü

### Qmail Pod'unun Çalıştığını Kontrol Edin

```bash
kubectl get pods -n mail
```

### Pod Loglarını Kontrol Edin

```bash
kubectl logs -n mail -l app.kubernetes.io/name=qmail-server
```

## 6. DNS Kontrolü

### MX Record Kontrolü

```bash
dig MX cloudflex.tr
```

**Beklenen çıktı:** Mail sunucunuzun MX kaydı olmalı.

### A Record Kontrolü

```bash
dig mail.cloudflex.tr
```

**Beklenen çıktı:** Ingress controller'ın external IP'si olmalı.

## 7. Port Testi

### SMTP Portunu Test Edin

```bash
# Ingress controller'ın external IP'sini alın
INGRESS_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# SMTP portunu test edin
telnet $INGRESS_IP 25
# veya
nc -zv $INGRESS_IP 25
```

## 8. Patch Job Kontrolü

### Patch Job'un Başarılı Olduğunu Kontrol Edin

```bash
kubectl get jobs -n mail | grep tcp-configmap-patch
```

### Patch Job Loglarını Kontrol Edin

```bash
kubectl logs -n mail job/qmail-server-tcp-configmap-patch
```

## 9. Hızlı Çözüm: Manuel ConfigMap Güncelleme

Eğer yukarıdaki adımlar işe yaramazsa, ConfigMap'i manuel olarak güncelleyin:

```bash
# Mevcut ConfigMap'i al
kubectl get configmap tcp-services -n ingress-nginx -o yaml > tcp-services-backup.yaml

# Düzenleyin ve Qmail portlarını ekleyin
# data: bölümüne şunları ekleyin:
#   "25": "mail/qmail-server:25"
#   "587": "mail/qmail-server:587"
#   "110": "mail/qmail-server:110"
#   "143": "mail/qmail-server:143"
#   "995": "mail/qmail-server:995"
#   "993": "mail/qmail-server:993"

# Uygula
kubectl apply -f tcp-services-backup.yaml

# Ingress controller'ı yeniden başlat
kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx
```

## 10. Values.yaml Kontrolü

`values.yaml` dosyasında `ingress.usePatchJob: true` olduğundan emin olun:

```yaml
ingress:
  enabled: true
  usePatchJob: true  # Bu true olmalı
```

## Yaygın Hatalar ve Çözümleri

### Hata: "ConfigMap already exists"
**Çözüm:** `usePatchJob: true` kullanın veya mevcut ConfigMap'i merge edin.

### Hata: "Connection refused"
**Çözüm:** 
1. Ingress controller'ın TCP servislerini desteklediğinden emin olun
2. Ingress controller'ı yeniden başlatın
3. Firewall kurallarını kontrol edin

### Hata: "Service not found"
**Çözüm:** 
1. Service adının doğru olduğundan emin olun: `kubectl get svc -n mail`
2. Namespace'in doğru olduğundan emin olun
3. ConfigMap'teki service referansını kontrol edin

## Test Komutları

Tüm kontrolleri tek seferde yapmak için:

```bash
#!/bin/bash
echo "=== TCP ConfigMap Kontrolü ==="
kubectl get configmap tcp-services -n ingress-nginx -o yaml | grep -A 10 "data:"

echo -e "\n=== Ingress Controller TCP Support ==="
kubectl get deployment ingress-nginx-controller -n ingress-nginx -o yaml | grep tcp-services

echo -e "\n=== Qmail Service ==="
kubectl get svc -n mail

echo -e "\n=== Qmail Pods ==="
kubectl get pods -n mail

echo -e "\n=== Ingress Controller External IP ==="
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

## İletişim ve Destek

Sorun devam ederse:
1. Tüm logları toplayın
2. ConfigMap içeriğini kaydedin
3. Service ve Pod durumlarını kontrol edin
4. DNS kayıtlarını doğrulayın


