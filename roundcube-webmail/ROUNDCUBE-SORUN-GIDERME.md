# Roundcube "İstek Geçersiz" Hatası - Sorun Giderme

## 🔴 Sorun: "İstek geçersiz herhangi bir veri kaydedilmedi"

Bu hata genellikle Roundcube'un Qmail IMAP sunucusuna bağlanamaması veya authentication sorunlarından kaynaklanır.

## 🔍 Tespit Edilen Sorunlar

### 1. IMAP Authentication Hatası

**Hata Mesajı:**
```
IMAP Error: Login failed for test@cloudflex.tr against qmail-server.mail. 
Unsupported authentication mechanism.
```

**Neden:** Qmail IMAP sunucusu ile Roundcube arasında authentication mekanizması uyumsuzluğu.

## ✅ Çözümler

### Çözüm 1: Roundcube Yapılandırmasını Güncelleme

Roundcube config'de authentication mekanizmasını otomatik algılamaya ayarlayın:

```yaml
# values.yaml
webmail:
  mailServer:
    host: qmail-server.mail
    smtpPort: 25
    imapPort: 143
    smtpSecure: ""
    imapSecure: ""
```

Chart'ı yeniden deploy edin:

```bash
helm upgrade roundcube-webmail ./roundcube-webmail --namespace mail
```

### Çözüm 2: Qmail IMAP Authentication Kontrolü

Qmail pod'una bağlanıp IMAP authentication'ı kontrol edin:

```bash
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n mail $POD -- /bin/sh

# IMAP servisini kontrol et
netstat -tlnp | grep 143
```

### Çözüm 3: Kullanıcı Şifresini Kontrol Etme

Kullanıcı şifresinin doğru olduğundan emin olun:

```bash
# Şifre değiştir
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n mail $POD -- /home/vpopmail/bin/vpasswd admin@cloudflex.tr YeniSifre123!
```

### Çözüm 4: Roundcube Pod'unu Yeniden Başlatma

ConfigMap değişikliklerinden sonra pod'u yeniden başlatın:

```bash
kubectl rollout restart deployment roundcube-webmail -n mail
```

### Çözüm 5: IMAP Bağlantısını Test Etme

Roundcube pod'undan Qmail IMAP sunucusuna bağlantıyı test edin:

```bash
POD=$(kubectl get pods -n mail -l app.kubernetes.io/name=roundcube-webmail -o jsonpath='{.items[0].metadata.name}')

# IMAP portunu test et
kubectl exec -n mail $POD -- telnet qmail-server.mail 143

# veya
kubectl exec -n mail $POD -- nc -zv qmail-server.mail 143
```

### Çözüm 6: Roundcube Loglarını Kontrol Etme

Detaylı hata mesajlarını görmek için:

```bash
POD=$(kubectl get pods -n mail -l app.kubernetes.io/name=roundcube-webmail -o jsonpath='{.items[0].metadata.name}')
kubectl logs -n mail $POD --tail=100 | grep -i error
```

## 🔧 Manuel Yapılandırma Düzeltmesi

Eğer yukarıdaki çözümler işe yaramazsa, Roundcube config dosyasını manuel olarak düzenleyin:

```bash
POD=$(kubectl get pods -n mail -l app.kubernetes.io/name=roundcube-webmail -o jsonpath='{.items[0].metadata.name}')

# Config dosyasını düzenle
kubectl exec -it -n mail $POD -- vi /var/www/html/config/config.inc.php
```

Şu satırları ekleyin veya güncelleyin:

```php
$config['imap_auth_type'] = null;  // Auto-detect
$config['smtp_auth_type'] = null;  // Auto-detect
$config['imap_conn_options'] = array(
    'ssl' => array(
        'verify_peer' => false,
        'verify_peer_name' => false,
        'allow_self_signed' => true,
    ),
);
```

## 📋 Kontrol Listesi

- [ ] Qmail pod'u çalışıyor mu?
- [ ] Qmail service'i erişilebilir mi?
- [ ] IMAP portu (143) açık mı?
- [ ] Kullanıcı şifresi doğru mu?
- [ ] Roundcube config doğru mu?
- [ ] Network policy engellemesi var mı?

## 🧪 Test Komutları

### Qmail IMAP Bağlantı Testi

```bash
# Qmail pod'undan
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n mail $POD -- netstat -tlnp | grep 143
```

### Roundcube'dan Qmail'e Bağlantı Testi

```bash
# Roundcube pod'undan
POD=$(kubectl get pods -n mail -l app.kubernetes.io/name=roundcube-webmail -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n mail $POD -- ping -c 3 qmail-server.mail
kubectl exec -n mail $POD -- nc -zv qmail-server.mail 143
```

## 💡 Öneriler

1. **Kullanıcı oluştururken güçlü şifre kullanın**
2. **Roundcube ve Qmail aynı namespace'de olmalı**
3. **Service DNS adlarını doğru kullanın** (`qmail-server.mail`)
4. **IMAP portunun açık olduğundan emin olun**

## 📞 Daha Fazla Yardım

Sorun devam ederse:
1. Roundcube loglarını toplayın
2. Qmail loglarını kontrol edin
3. Network connectivity'yi test edin
4. Kullanıcı authentication'ı doğrulayın


