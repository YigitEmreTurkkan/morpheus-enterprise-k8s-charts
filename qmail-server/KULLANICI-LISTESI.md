# Qmail Kullanıcı Listesi

## 📧 Mevcut Kullanıcılar

Aşağıdaki kullanıcılar Qmail mail sunucusunda tanımlı:

### Kullanıcı Listesi

1. **admin@cloudflex.tr**
2. **newadmin@cloudflex.tr**
3. **postmaster@cloudflex.tr**
4. **test@cloudflex.tr**
5. **yeni@cloudflex.tr**

## 🔐 Şifre Durumu

**⚠️ ÖNEMLİ:** Şifreler bilinmiyor veya şifre dosyaları eksik olabilir.

## 📝 Kullanıcı Bilgileri

### SMTP/IMAP Ayarları (Tüm Kullanıcılar İçin)

```
SMTP Sunucu: mail.cloudflex.tr
SMTP Port: 587 (önerilen) veya 25
IMAP Sunucu: mail.cloudflex.tr
IMAP Port: 143 veya 993 (SSL)
Kullanıcı Adı: kullanici@cloudflex.tr (tam email adresi)
Şifre: [kullanıcı şifresi]
```

## 🔧 Şifre Değiştirme

### Yöntem 1: vpasswd Komutu

```bash
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n mail $POD -- /home/vpopmail/bin/vpasswd admin@cloudflex.tr YeniSifre123!
```

### Yöntem 2: Manuel Şifre Oluşturma

```bash
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n mail $POD -- /bin/sh

# Container içinde:
cd /home/vpopmail/domains/cloudflex.tr/admin
python3 -c "import crypt; print(crypt.crypt('YeniSifre123!', crypt.mksalt(crypt.METHOD_SHA512)))"

# Çıkan hash'i kopyalayın ve .password dosyasına yazın
echo "HASH_BURAYA" > .password
chown vpopmail:vchkpw .password
chmod 600 .password
```

## ➕ Yeni Kullanıcı Oluşturma

```bash
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n mail $POD -- /home/vpopmail/bin/vadduser yeni@cloudflex.tr YeniSifre123!
```

## 🔍 Kullanıcı Kontrolü

### Kullanıcı Listesini Görüntüle

```bash
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n mail $POD -- ls -la /home/vpopmail/domains/cloudflex.tr/
```

### Kullanıcı Şifresini Kontrol Et

```bash
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n mail $POD -- ls -la /home/vpopmail/domains/cloudflex.tr/admin/.password
```

## 📋 Hızlı Şifre Ayarlama

Tüm kullanıcılar için şifre ayarlamak için:

```bash
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')

# Admin kullanıcısı için
kubectl exec -it -n mail $POD -- /home/vpopmail/bin/vpasswd admin@cloudflex.tr Admin123!

# Test kullanıcısı için
kubectl exec -it -n mail $POD -- /home/vpopmail/bin/vpasswd test@cloudflex.tr Test123!

# Postmaster için
kubectl exec -it -n mail $POD -- /home/vpopmail/bin/vpasswd postmaster@cloudflex.tr Postmaster123!
```

## 🌐 Roundcube Webmail Giriş

Roundcube webmail'e giriş yapmak için:

- **URL**: `https://webmail.cloudflex.tr`
- **Kullanıcı**: `admin@cloudflex.tr` (veya diğer kullanıcılar)
- **Şifre**: [yukarıda ayarladığınız şifre]

## ⚠️ Güvenlik Notları

1. İlk kurulumdan sonra tüm kullanıcı şifrelerini değiştirin
2. Güçlü şifreler kullanın (en az 12 karakter)
3. Her kullanıcı için farklı şifre kullanın
4. Düzenli olarak şifreleri güncelleyin


