# Roundcube ↔ Qmail Bağlantı Test Sonuçları

## 🔍 Test Sonuçları

### ✅ Başarılı Bağlantılar

- **IMAP Port (143)**: ✅ Erişilebilir
  - Qmail pod'unda dovecot IMAP servisi çalışıyor
  - Port dinleniyor: `0.0.0.0:143`

### ❌ Sorunlu Bağlantılar

- **SMTP Port (25)**: ❌ Connection Refused
  - Qmail pod'unda SMTP servisi çalışmıyor görünüyor
  - Port 25 dinlenmiyor

- **IMAP Authentication**: ❌ Unsupported authentication mechanism
  - Roundcube Qmail IMAP'e bağlanabiliyor ama authentication başarısız
  - Log hatası: `Login failed. Unsupported authentication mechanism.`

## 📊 Mevcut Durum

### Qmail Service
- **Service IP**: `172.30.235.168`
- **Portlar**: 25, 587, 110, 143, 995, 993, 80
- **Durum**: Service tanımlı ama SMTP portu container'da çalışmıyor

### Qmail Pod
- **IMAP (143)**: ✅ Çalışıyor (dovecot)
- **SMTP (25)**: ❌ Çalışmıyor
- **SMTP (587)**: ❓ Kontrol edilmeli

### Roundcube Config
- **IMAP Host**: `qmail-server.mail:143` ✅
- **SMTP Host**: `qmail-server.mail:25` ⚠️
- **Authentication**: Auto-detect (güncellendi)

## 🔧 Çözüm Önerileri

### 1. SMTP Port Sorunu

Qmail container'ında SMTP servisi başlatılmamış olabilir. Kontrol edin:

```bash
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n mail $POD -- /bin/sh

# Container içinde SMTP servisini kontrol et
ps aux | grep qmail
netstat -tlnp | grep 25
```

### 2. SMTP Port 587 Kullan

Roundcube config'de SMTP portunu 587'ye değiştirin:

```yaml
# roundcube-webmail/values.yaml
webmail:
  mailServer:
    smtpPort: 587  # 25 yerine 587
```

Sonra:
```bash
helm upgrade roundcube-webmail ./roundcube-webmail --namespace mail
kubectl rollout restart deployment roundcube-webmail -n mail
```

### 3. IMAP Authentication Sorunu

Roundcube config güncellendi ama pod restart edilmedi. Restart edin:

```bash
kubectl rollout restart deployment roundcube-webmail -n mail
```

### 4. Qmail SMTP Servisini Başlat

Qmail container'ında SMTP servisinin çalıştığından emin olun. Container image'ı kontrol edin veya Qmail SMTP servisini manuel başlatın.

## 🧪 Test Komutları

### IMAP Bağlantı Testi
```bash
POD=$(kubectl get pods -n mail -l app.kubernetes.io/name=roundcube-webmail -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n mail $POD -- timeout 3 bash -c "echo > /dev/tcp/qmail-server.mail/143" && echo "✅ IMAP OK"
```

### SMTP Bağlantı Testi
```bash
POD=$(kubectl get pods -n mail -l app.kubernetes.io/name=roundcube-webmail -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n mail $POD -- timeout 3 bash -c "echo > /dev/tcp/qmail-server.mail/25" && echo "✅ SMTP 25 OK" || echo "❌ SMTP 25 FAILED"
kubectl exec -n mail $POD -- timeout 3 bash -c "echo > /dev/tcp/qmail-server.mail/587" && echo "✅ SMTP 587 OK" || echo "❌ SMTP 587 FAILED"
```

## 📝 Özet

| Servis | Port | Durum | Not |
|--------|------|-------|-----|
| IMAP | 143 | ✅ | Dovecot çalışıyor, bağlantı var ama auth sorunu |
| SMTP | 25 | ❌ | Port dinlenmiyor |
| SMTP | 587 | ❓ | Test edilmeli |

## 🚀 Hızlı Çözüm

1. **Roundcube'u restart et** (config güncellemesi için):
   ```bash
   kubectl rollout restart deployment roundcube-webmail -n mail
   ```

2. **SMTP portunu 587'ye değiştir**:
   ```bash
   # values.yaml'da smtpPort: 587 yap
   helm upgrade roundcube-webmail ./roundcube-webmail --namespace mail
   ```

3. **Qmail SMTP servisini kontrol et**:
   ```bash
   POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
   kubectl exec -it -n mail $POD -- /bin/sh
   # Container içinde SMTP servisini başlat
   ```


