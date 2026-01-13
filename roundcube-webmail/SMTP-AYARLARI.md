# Roundcube SMTP Ayarları (Qmail Yapılandırmasına Göre)

## 📧 SMTP Yapılandırması

Roundcube, **Qmail SMTP sunucusuna** bağlanmak için aşağıdaki ayarları kullanır. Bu ayarlar **Qmail'in yapılandırmasına göre** (`qmail-server/values.yaml`) yapılandırılmıştır.

### Qmail SMTP Ayarları (Kaynak)

Qmail'in SMTP yapılandırması `qmail-server/values.yaml` dosyasında tanımlıdır:

```yaml
# qmail-server/values.yaml
mail:
  domain: cloudflex.tr
  hostname: mail.cloudflex.tr
  ports:
    smtp: 25              # SMTP port
    smtpSubmission: 587   # SMTP Submission port (authenticated)
```

### Roundcube SMTP Ayarları (Qmail'e Göre)

Roundcube'un SMTP ayarları Qmail'in ayarlarına göre yapılandırılmıştır:

```yaml
# roundcube-webmail/values.yaml
webmail:
  mailServer:
    host: qmail-server.mail  # Qmail Kubernetes service name
    smtpPort: 25             # Qmail SMTP port (matches qmail-server mail.ports.smtp)
    smtpSubmissionPort: 587  # Qmail SMTP Submission port (matches qmail-server mail.ports.smtpSubmission)
    smtpSecure: ""          # Empty = no TLS (Qmail default for internal)
```

### SMTP Bağlantı Bilgileri (Qmail'den)

- **SMTP Host**: `qmail-server.mail` (Kubernetes service name)
- **SMTP Port**: `25` (Qmail SMTP port - `qmail-server/values.yaml` → `mail.ports.smtp`)
- **SMTP Submission Port**: `587` (Qmail Submission port - `qmail-server/values.yaml` → `mail.ports.smtpSubmission`)
- **SMTP Auth Type**: `PLAIN` (Qmail vpopmail authentication)
- **TLS/SSL**: Kapalı (internal cluster communication - Qmail default)
- **Qmail Domain**: `cloudflex.tr` (Qmail `mail.domain`)
- **Qmail Hostname**: `mail.cloudflex.tr` (Qmail `mail.hostname`)
- **Kullanıcı Adı**: IMAP ile aynı (Qmail vpopmail format: `user@domain`)
- **Şifre**: IMAP ile aynı (Qmail vpopmail password)

### SMTP Ayarlarını Değiştirme

#### 1. SMTP Port Değiştirme (Qmail'e Göre)

**ÖNEMLİ**: SMTP portunu değiştirmeden önce Qmail'in `qmail-server/values.yaml` dosyasındaki `mail.ports.smtp` değerini kontrol edin.

Eğer Qmail'de submission port (587) kullanıyorsanız:

```yaml
# roundcube-webmail/values.yaml
webmail:
  mailServer:
    smtpPort: 587  # Qmail'in smtpSubmission port'u ile eşleşmeli
```

**Not**: Qmail'in `mail.ports.smtpSubmission: 587` ayarı ile eşleşmeli.

#### 2. TLS/SSL Etkinleştirme

External bağlantılar için TLS kullanmak isterseniz:

```yaml
# values.yaml
webmail:
  mailServer:
    smtpSecure: "tls"  # veya "ssl"
```

#### 3. Helm Chart'ı Güncelleme

Ayarları değiştirdikten sonra:

```bash
helm upgrade roundcube-webmail ./roundcube-webmail --namespace mail
```

Roundcube pod'unu yeniden başlatın:

```bash
kubectl rollout restart deployment roundcube-webmail -n mail
```

### SMTP Test Etme

#### 1. Roundcube Web Arayüzünden

1. Roundcube'a giriş yapın: `https://webmail.cloudflex.tr`
2. Yeni bir e-posta oluşturun
3. Test e-postası gönderin
4. Gönderilen e-postaları kontrol edin

#### 2. Pod'dan Test

```bash
# Roundcube pod'una bağlan
POD=$(kubectl get pods -n mail -l app.kubernetes.io/name=roundcube-webmail -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n mail $POD -- /bin/sh

# SMTP bağlantısını test et
telnet qmail-server.mail 25
```

#### 3. Qmail SMTP Loglarını Kontrol Etme

```bash
# Qmail pod'una bağlan
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n mail $POD -- /bin/sh

# SMTP loglarını kontrol et
tail -f /var/log/qmail/smtpd/current
```

### SMTP Sorun Giderme

#### Sorun 1: "SMTP Error: Connection refused"

**Neden**: Qmail SMTP servisi çalışmıyor veya port erişilemiyor.

**Çözüm**:
```bash
# Qmail SMTP servisini kontrol et
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n mail $POD -- netstat -tlnp | grep 25

# SMTP servisini başlat (gerekirse)
kubectl exec -n mail $POD -- svc -u /var/qmail/supervise/qmail-smtpd
```

#### Sorun 2: "SMTP Error: Authentication failed"

**Neden**: SMTP authentication başarısız.

**Çözüm**:
- Kullanıcı adı ve şifresinin doğru olduğundan emin olun
- Dovecot authentication'ın çalıştığını kontrol edin
- Roundcube config'de `smtp_auth_type = 'PLAIN'` olduğunu doğrulayın

#### Sorun 3: "SMTP Error: Timeout"

**Neden**: SMTP sunucusuna bağlantı zaman aşımına uğruyor.

**Çözüm**:
- Qmail pod'unun çalıştığını kontrol edin
- Network policy'lerin SMTP portunu engellemediğinden emin olun
- `smtp_timeout` değerini artırın (varsayılan: 30 saniye)

### Dış Uygulamalar İçin SMTP Ayarları

Diğer uygulamalardan (ör. PHP, Python, Node.js) SMTP kullanmak için:

```
SMTP Host: mail.cloudflex.tr (external)
         veya qmail-server.mail (internal cluster)
SMTP Port: 25 (veya 587 submission)
SMTP Auth: PLAIN
Username: admin@cloudflex.tr
Password: Admin123!
TLS/SSL: Kapalı (internal) veya TLS (external)
```

**Not**: External erişim için NGINX Ingress Controller'ın TCP ConfigMap'inde SMTP portu tanımlı olmalı.

### İlgili Dosyalar

- `roundcube-webmail/values.yaml` - SMTP port ve host ayarları
- `roundcube-webmail/templates/webmail-config.yaml` - Roundcube SMTP config
- `qmail-server/values.yaml` - Qmail SMTP port ayarları
- `qmail-server/templates/tcp-configmap.yaml` - External SMTP erişimi

