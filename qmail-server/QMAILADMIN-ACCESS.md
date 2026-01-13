# QmailAdmin Erişim Bilgileri

## QmailAdmin Login

QmailAdmin web arayüzü bir **login ekranı** gösteriyor. Giriş için:

### Durum

QmailAdmin authentication gerektiriyor. İlk kullanıcıyı oluşturmanız gerekiyor.

### Çözüm: Manuel Kullanıcı Oluşturma

vadduser komutu çalışmadığı için, manuel olarak kullanıcı oluşturun:

```bash
# Pod'a bağlan
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n mail $POD -- /bin/sh

# Vpopmail kullanıcısı olarak geç
su - vpopmail

# Kullanıcı dizini oluştur
mkdir -p /home/vpopmail/domains/cloudflex.tr/admin
chown vpopmail:vchkpw /home/vpopmail/domains/cloudflex.tr/admin

# Şifre hash'i oluştur (Python ile)
python3 -c "import crypt; print(crypt.crypt('Admin123!', crypt.mksalt(crypt.METHOD_SHA512)))"

# .qmail-default dosyası oluştur
touch /home/vpopmail/domains/cloudflex.tr/admin/.qmail-default
chown vpopmail:vchkpw /home/vpopmail/domains/cloudflex.tr/admin/.qmail-default
```

### Alternatif: QmailAdmin'de Direkt Deneme

QmailAdmin login ekranında şunları deneyin:

1. **Boş bırakın** - Authentication olmayabilir
2. **admin / admin**
3. **root / root**
4. **vpopmail / (boş)**

### En Kolay Yöntem: Roundcube Kullanın

QmailAdmin yerine, direkt **Roundcube** kullanarak kullanıcı oluşturabilirsiniz:

1. Roundcube'da ilk girişte kurulum yapılandırması yapın
2. Veya Qmail pod'una bağlanıp manuel kullanıcı oluşturun
3. Sonra Roundcube'da o kullanıcı ile giriş yapın

## Hızlı Çözüm

Eğer QmailAdmin'de giriş yapamıyorsanız:

1. **Roundcube kullanın**: `https://webmail.cloudflex.tr`
2. **Pod'a bağlanıp manuel kullanıcı oluşturun**
3. **Roundcube'da o kullanıcı ile giriş yapın**

Roundcube, QmailAdmin'den daha kolay kullanılabilir ve kullanıcı oluşturma için QmailAdmin'e gerek yoktur.


