# Qmail Kullanıcı Adı ve Şifre Bilgileri

## ⚠️ ÖNEMLİ: Varsayılan Kullanıcı Yok!

Qmail mail sunucusunda **varsayılan bir kullanıcı yoktur**. İlk kullanıcıyı sizin oluşturmanız gerekiyor.

---

## 🔍 Mevcut Kullanıcıları Kontrol Etme

### Kullanıcı Listesini Görüntüle

```bash
# Qmail pod adını al
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')

# Mevcut kullanıcıları listele
kubectl exec -n mail $POD -- ls -la /home/vpopmail/domains/cloudflex.tr/
```

---

## ➕ İlk Kullanıcıyı Oluşturma

### Yöntem 1: Script ile (En Kolay)

```bash
cd qmail-server
chmod +x create-user.sh

# Kullanıcı oluştur
./create-user.sh admin@cloudflex.tr Admin123!
```

### Yöntem 2: Komut Satırı ile

```bash
# Pod adını al
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')

# Pod'a bağlan ve kullanıcı oluştur
kubectl exec -it -n mail $POD -- /home/vpopmail/bin/vadduser admin@cloudflex.tr Admin123!
```

**Not:** Eğer `vadduser` komutu çalışmazsa, manuel yöntem kullanın (aşağıda).

### Yöntem 3: Manuel Oluşturma

```bash
# Pod'a bağlan
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n mail $POD -- /bin/sh

# Pod içinde:
mkdir -p /home/vpopmail/domains/cloudflex.tr/admin
chown -R vpopmail:vchkpw /home/vpopmail/domains/cloudflex.tr/admin

# Şifre hash'i oluştur (Python ile)
python3 -c "import crypt; print(crypt.crypt('Admin123!', crypt.mksalt(crypt.METHOD_SHA512)))"

# Çıkan hash'i kopyalayın ve .password dosyasına yazın
echo "HASH_BURAYA" > /home/vpopmail/domains/cloudflex.tr/admin/.password
chown vpopmail:vchkpw /home/vpopmail/domains/cloudflex.tr/admin/.password
chmod 600 /home/vpopmail/domains/cloudflex.tr/admin/.password

# .qmail-default dosyası oluştur
touch /home/vpopmail/domains/cloudflex.tr/admin/.qmail-default
chown vpopmail:vchkpw /home/vpopmail/domains/cloudflex.tr/admin/.qmail-default
```

---

## 📧 Örnek Kullanıcı Oluşturma

### Admin Kullanıcısı

```bash
./create-user.sh admin@cloudflex.tr Admin123!
```

**SMTP Bilgileri:**
- **Kullanıcı Adı**: `admin@cloudflex.tr`
- **Şifre**: `Admin123!`
- **SMTP Sunucu**: `mail.cloudflex.tr`
- **Port**: `587`

### Test Kullanıcısı

```bash
./create-user.sh test@cloudflex.tr Test123!
```

**SMTP Bilgileri:**
- **Kullanıcı Adı**: `test@cloudflex.tr`
- **Şifre**: `Test123!`
- **SMTP Sunucu**: `mail.cloudflex.tr`
- **Port**: `587`

---

## 🔐 Şifre Değiştirme

```bash
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')

# Şifre değiştir
kubectl exec -it -n mail $POD -- /home/vpopmail/bin/vpasswd admin@cloudflex.tr YeniSifre123!
```

---

## 📋 Kullanıcı Oluşturma Özeti

1. **Kullanıcı oluştur** (yukarıdaki yöntemlerden biriyle)
2. **SMTP ayarlarını yap**:
   - Sunucu: `mail.cloudflex.tr`
   - Port: `587`
   - Kullanıcı: `kullanici@cloudflex.tr`
   - Şifre: `[oluşturduğunuz şifre]`
3. **Test et** (email gönder/al)

---

## 🚀 Hızlı Başlangıç

İlk kullanıcıyı oluşturmak için:

```bash
cd qmail-server
chmod +x create-user.sh
./create-user.sh admin@cloudflex.tr Admin123!
```

Sonra email client'ınızda:
- **SMTP**: `mail.cloudflex.tr:587`
- **Kullanıcı**: `admin@cloudflex.tr`
- **Şifre**: `Admin123!`

---

## ⚠️ Güvenlik Uyarısı

- İlk kurulumdan sonra varsayılan şifreleri değiştirin
- Güçlü şifreler kullanın (en az 12 karakter, büyük/küçük harf, rakam, özel karakter)
- Her kullanıcı için farklı şifre kullanın

---

**Not:** Eğer kullanıcı oluşturma konusunda sorun yaşıyorsanız, `USER-CREATION.md` dosyasına bakın.


