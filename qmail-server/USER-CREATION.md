# Qmail Kullanıcı Oluşturma Rehberi

Qmail mail sunucusunda e-posta kullanıcıları oluşturmak için aşağıdaki adımları izleyin.

## Kullanıcı Oluşturma

### Yöntem 1: kubectl exec ile (Önerilen)

Qmail pod'una bağlanıp kullanıcı oluşturun:

```bash
# Qmail pod adını alın
POD_NAME=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')

# Pod'a bağlanın
kubectl exec -it -n mail $POD_NAME -- /bin/sh

# Pod içinde kullanıcı oluşturun
# Format: /home/vpopmail/bin/vadduser email@domain.com password
/home/vpopmail/bin/vadduser test@cloudflex.tr TestPassword123!
```

### Yöntem 2: Tek Komut ile

```bash
kubectl exec -it -n mail $(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}') -- /home/vpopmail/bin/vadduser test@cloudflex.tr TestPassword123!
```

**Not:** TTY gerektiğinden `-it` flag'leri gerekli.

## Örnek Kullanıcı Oluşturma

### cloudflex.tr domain'i için kullanıcı:

```bash
# Pod'a bağlan
kubectl exec -it -n mail $(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}') -- /bin/sh

# Kullanıcı oluştur (örnek: admin@cloudflex.tr)
/home/vpopmail/bin/vadduser admin@cloudflex.tr AdminPass123!

# Başka bir kullanıcı (örnek: info@cloudflex.tr)
/home/vpopmail/bin/vadduser info@cloudflex.tr InfoPass123!
```

## Kullanıcı Listesi

Mevcut kullanıcıları listelemek için:

```bash
kubectl exec -it -n mail $(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}') -- ls -la /home/vpopmail/domains/cloudflex.tr/
```

## Kullanıcı Şifresi Değiştirme

```bash
kubectl exec -it -n mail $(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}') -- /home/vpopmail/bin/vpasswd test@cloudflex.tr YeniSifre123!
```

## Kullanıcı Silme

```bash
kubectl exec -it -n mail $(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}') -- /home/vpopmail/bin/vdeluser test@cloudflex.tr
```

## Roundcube'da Giriş

Kullanıcı oluşturduktan sonra Roundcube webmail'e giriş yapın:

1. **URL**: `https://webmail.cloudflex.tr`
2. **Kullanıcı Adı**: Tam e-posta adresi (örn: `test@cloudflex.tr`)
3. **Şifre**: Oluştururken belirlediğiniz şifre

## Önemli Notlar

- Kullanıcı adı **tam e-posta adresi** olmalıdır (örn: `user@cloudflex.tr`)
- Şifre güçlü olmalıdır (büyük/küçük harf, rakam, özel karakter)
- Domain `cloudflex.tr` olarak yapılandırılmıştır
- Kullanıcılar `/home/vpopmail/domains/cloudflex.tr/` dizininde saklanır

## Hızlı Test Kullanıcısı Oluşturma

Hızlı bir test için:

```bash
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n mail $POD -- /home/vpopmail/bin/vadduser test@cloudflex.tr Test123!
```

Sonra Roundcube'da:
- **Kullanıcı**: `test@cloudflex.tr`
- **Şifre**: `Test123!`

