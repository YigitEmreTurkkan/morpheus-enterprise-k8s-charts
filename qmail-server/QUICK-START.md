# Qmail Domain ve Kullanıcı Oluşturma - Hızlı Başlangıç

Bu rehber, `cloudflex.tr` domain'i için Qmail'de domain tanımlama ve kullanıcı oluşturma adımlarını içerir.

## Yöntem 1: QmailAdmin Web Arayüzü (Önerilen - En Kolay)

### 1. QmailAdmin'e Erişim

```bash
# Qmail pod adını al
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')

# Port-forward başlat (8080 portunda)
kubectl port-forward -n mail $POD 8080:80
```

Tarayıcıda açın: **http://localhost:8080/qmailadmin**

### 2. Domain Oluşturma

1. QmailAdmin arayüzünde **"Virtual Domains"** veya **"Domains"** bölümüne gidin
2. **"Add Domain"** veya **"New Domain"** butonuna tıklayın
3. Domain adını girin: `cloudflex.tr`
4. Domain şifresi belirleyin (domain yönetimi için)
5. **"Add"** veya **"Create"** butonuna tıklayın

### 3. Kullanıcı Oluşturma

1. QmailAdmin'de **"Users"** veya **"Mailboxes"** bölümüne gidin
2. **"Add User"** veya **"New User"** butonuna tıklayın
3. Kullanıcı bilgilerini girin:
   - **E-posta**: `test@cloudflex.tr` (sadece `test` yazın, domain otomatik eklenir)
   - **Şifre**: Güçlü bir şifre belirleyin
   - **Quota** (opsiyonel): Mail kutusu boyutu limiti
4. **"Add"** veya **"Create"** butonuna tıklayın

### 4. Roundcube'da Test

1. **URL**: `https://webmail.cloudflex.tr`
2. **Kullanıcı**: `test@cloudflex.tr`
3. **Şifre**: Oluşturduğunuz şifre

---

## Yöntem 2: Komut Satırı ile (Manuel)

### 1. Qmail Pod'una Bağlanma

```bash
# Pod adını al
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')

# Pod'a bağlan
kubectl exec -it -n mail $POD -- /bin/sh
```

### 2. Gerekli Dosyaları Oluşturma (İlk Kez)

Pod içinde şu komutları çalıştırın:

```bash
# Gerekli dizinleri oluştur
mkdir -p /var/qmail/control /var/qmail/users
touch /var/qmail/control/rcpthosts /var/qmail/users/assign
touch /var/qmail/control/rcpthosts.lock

# İzinleri ayarla
chown -R vpopmail:vchkpw /var/qmail/users
chown qmaild:qmail /var/qmail/control
chown vpopmail:vchkpw /var/qmail/control/rcpthosts /var/qmail/control/rcpthosts.lock
chmod 755 /var/qmail/control
chmod 644 /var/qmail/control/rcpthosts /var/qmail/users/assign
chmod 666 /var/qmail/control/rcpthosts.lock
```

### 3. Domain Ekleme

```bash
# rcpthosts dosyasına domain ekle
echo "cloudflex.tr" >> /var/qmail/control/rcpthosts

# assign dosyasına domain kaydı ekle
echo "+cloudflex.tr::5000:5000:/home/vpopmail/domains/cloudflex.tr::" >> /var/qmail/users/assign

# Domain dizinini oluştur
mkdir -p /home/vpopmail/domains/cloudflex.tr
chown -R vpopmail:vchkpw /home/vpopmail/domains/cloudflex.tr
```

### 4. Kullanıcı Oluşturma

```bash
# vpopmail kullanıcısı olarak geç
su - vpopmail

# Kullanıcı oluştur (şifre soracak)
/home/vpopmail/bin/vadduser test@cloudflex.tr

# Şifre girin ve onaylayın
```

**Not:** Eğer `vadduser` komutu çalışmazsa, manuel olarak:

```bash
# Kullanıcı dizini oluştur
mkdir -p /home/vpopmail/domains/cloudflex.tr/test
chown -R vpopmail:vchkpw /home/vpopmail/domains/cloudflex.tr/test

# Şifre hash'i oluştur (Python ile)
python3 -c "import crypt; print(crypt.crypt('Test123!', crypt.mksalt(crypt.METHOD_SHA512)))"

# .qmail-default dosyası oluştur (gerekirse)
touch /home/vpopmail/domains/cloudflex.tr/test/.qmail-default
chown vpopmail:vchkpw /home/vpopmail/domains/cloudflex.tr/test/.qmail-default
```

---

## Yöntem 3: Tek Komut ile Hızlı Kurulum

Aşağıdaki script'i çalıştırarak domain ve ilk kullanıcıyı oluşturabilirsiniz:

```bash
#!/bin/bash
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')

# Domain ve kullanıcı oluştur
kubectl exec -it -n mail $POD -- bash -c "
mkdir -p /var/qmail/control /var/qmail/users /home/vpopmail/domains/cloudflex.tr/test
touch /var/qmail/control/rcpthosts /var/qmail/users/assign /var/qmail/control/rcpthosts.lock
chown -R vpopmail:vchkpw /var/qmail/users /home/vpopmail/domains/cloudflex.tr
chown qmaild:qmail /var/qmail/control
chown vpopmail:vchkpw /var/qmail/control/rcpthosts /var/qmail/control/rcpthosts.lock
chmod 755 /var/qmail/control
chmod 644 /var/qmail/control/rcpthosts /var/qmail/users/assign
chmod 666 /var/qmail/control/rcpthosts.lock
echo 'cloudflex.tr' >> /var/qmail/control/rcpthosts
echo '+cloudflex.tr::5000:5000:/home/vpopmail/domains/cloudflex.tr::' >> /var/qmail/users/assign
echo 'Domain cloudflex.tr oluşturuldu'
"
```

**Kullanıcı için:** QmailAdmin kullanın veya pod'a bağlanıp `vadduser` komutunu çalıştırın.

---

## Kontrol ve Test

### Domain Kontrolü

```bash
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n mail $POD -- cat /var/qmail/control/rcpthosts
kubectl exec -n mail $POD -- ls -la /home/vpopmail/domains/cloudflex.tr/
```

### Kullanıcı Kontrolü

```bash
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n mail $POD -- ls -la /home/vpopmail/domains/cloudflex.tr/
```

### Roundcube'da Test

1. `https://webmail.cloudflex.tr` adresine gidin
2. Oluşturduğunuz kullanıcı ile giriş yapın
3. Test e-postası gönderin/alın

---

## Örnek: İlk Kullanıcı Oluşturma

```bash
# 1. QmailAdmin'e eriş
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl port-forward -n mail $POD 8080:80

# 2. Tarayıcıda http://localhost:8080/qmailadmin açın
# 3. Domain: cloudflex.tr ekleyin
# 4. Kullanıcı: admin@cloudflex.tr ekleyin
# 5. Roundcube'da test edin: https://webmail.cloudflex.tr
```

---

## Sorun Giderme

### Domain eklenmiyor

- `/var/qmail/control/rcpthosts` dosyasına yazma izni kontrol edin
- `vpopmail` kullanıcısının dosyalara erişimi olduğundan emin olun

### Kullanıcı oluşturulamıyor

- Domain'in önce oluşturulduğundan emin olun
- `/home/vpopmail/domains/cloudflex.tr/` dizininin var olduğunu kontrol edin
- QmailAdmin web arayüzünü kullanmayı deneyin

### Roundcube'da giriş yapılamıyor

- Kullanıcı adının tam e-posta adresi olduğundan emin olun: `test@cloudflex.tr`
- Şifrenin doğru olduğundan emin olun
- Qmail pod'unun çalıştığını kontrol edin

---

## Önemli Notlar

- **Domain**: `cloudflex.tr` (`.com.tr` değil!)
- **E-posta formatı**: `kullanici@cloudflex.tr`
- **QmailAdmin**: En kolay yöntem, web arayüzü üzerinden
- **İlk kurulum**: Gerekli dosyalar yoksa manuel oluşturulmalı


