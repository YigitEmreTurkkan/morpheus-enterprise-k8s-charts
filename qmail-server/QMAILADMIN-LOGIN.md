# QmailAdmin Giriş Bilgileri

QmailAdmin web arayüzüne erişim için kullanıcı bilgileri.

## Varsayılan Durum

QmailAdmin genellikle **authentication gerektirmez** veya **vpopmail kullanıcıları** ile giriş yapılır.

## Giriş Yöntemleri

### Yöntem 1: Authentication Yok (Direkt Erişim)

Bazı QmailAdmin kurulumlarında authentication olmayabilir. Direkt erişim deneyin:

1. `http://localhost:8080/qmailadmin` adresine gidin
2. Eğer login ekranı çıkmazsa, direkt kullanabilirsiniz

### Yöntem 2: Vpopmail Kullanıcısı ile Giriş

QmailAdmin, vpopmail kullanıcıları ile çalışır. İlk admin kullanıcısını oluşturun:

```bash
# Pod'a bağlan
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n mail $POD -- su - vpopmail

# Admin kullanıcısı oluştur
/home/vpopmail/bin/vadduser admin@cloudflex.tr
# Şifre girin (örnek: Admin123!)
```

Sonra QmailAdmin'de:
- **Kullanıcı**: `admin@cloudflex.tr`
- **Şifre**: Oluşturduğunuz şifre

### Yöntem 3: Varsayılan Admin (Eğer Varsa)

Bazı kurulumlarda varsayılan:
- **Kullanıcı**: `admin` veya `root`
- **Şifre**: `admin` veya boş

**Deneyin:**
- `admin` / `admin`
- `root` / `root`
- `admin` / (boş)
- `root` / (boş)

## İlk Kullanıcı Oluşturma

Eğer hiç kullanıcı yoksa, önce bir admin kullanıcısı oluşturun:

```bash
# Pod'a bağlan
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n mail $POD -- /bin/sh

# Vpopmail kullanıcısı olarak geç
su - vpopmail

# Admin kullanıcısı oluştur
/home/vpopmail/bin/vadduser admin@cloudflex.tr
# Şifre: Admin123! (veya istediğiniz şifre)
```

## Sorun Giderme

### Login Ekranı Görünmüyor

QmailAdmin authentication gerektirmiyor olabilir. Direkt kullanmayı deneyin.

### "Invalid Credentials" Hatası

1. Vpopmail kullanıcısı oluşturduğunuzdan emin olun
2. Tam e-posta adresi kullanın: `admin@cloudflex.tr`
3. Şifrenin doğru olduğundan emin olun

### Kullanıcı Oluşturulamıyor

Domain'in önce oluşturulduğundan emin olun:
```bash
# Domain kontrolü
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n mail $POD -- cat /var/qmail/control/rcpthosts
```

## Hızlı Başlangıç

```bash
# 1. Pod'a bağlan
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n mail $POD -- su - vpopmail

# 2. Admin kullanıcısı oluştur
/home/vpopmail/bin/vadduser admin@cloudflex.tr
# Şifre: Admin123!

# 3. QmailAdmin'e giriş yap
# http://localhost:8080/qmailadmin
# Kullanıcı: admin@cloudflex.tr
# Şifre: Admin123!
```


