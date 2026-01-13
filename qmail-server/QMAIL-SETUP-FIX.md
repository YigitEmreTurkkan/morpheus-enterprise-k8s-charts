# Qmail Kullanıcı Oluşturma Sorunu ve Çözümü

`robreardon/qmail` image'ında vpopmail ile kullanıcı oluşturma sırasında assign dosyası sorunu yaşanıyor.

## Sorun

- `vadddomain` komutu "could not open assign file" hatası veriyor
- Qmail'in yapılandırma dosyaları (`/var/qmail/control/`, `/var/qmail/users/`) eksik veya yanlış izinlerde

## Geçici Çözüm

### Yöntem 1: QmailAdmin Web Arayüzü (Önerilen)

Qmail image'ı QmailAdmin web arayüzü içeriyor olabilir. Kontrol edin:

```bash
# QmailAdmin servisini kontrol et
kubectl get svc -n mail

# Eğer varsa, port-forward yapın
kubectl port-forward -n mail svc/qmail-server 8080:80
```

Sonra `http://localhost:8080` adresinden QmailAdmin'e erişin ve oradan kullanıcı oluşturun.

### Yöntem 2: Pod Restart Sonrası Manuel Yapılandırma

Qmail pod'unu restart edip, gerekli dosyaları oluşturun:

```bash
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')

# Pod'a bağlan
kubectl exec -it -n mail $POD -- /bin/sh

# Gerekli dizinleri ve dosyaları oluştur
mkdir -p /var/qmail/control /var/qmail/users
touch /var/qmail/control/rcpthosts /var/qmail/users/assign
chown -R vpopmail:vchkpw /var/qmail/users
chown qmaild:qmail /var/qmail/control
chmod 755 /var/qmail/control
chmod 644 /var/qmail/control/rcpthosts /var/qmail/users/assign

# Domain ekle (manuel)
echo "cloudflex.tr" >> /var/qmail/control/rcpthosts
echo "+cloudflex.tr::5000:5000:/home/vpopmail/domains/cloudflex.tr::" >> /var/qmail/users/assign

# Kullanıcı dizini oluştur
mkdir -p /home/vpopmail/domains/cloudflex.tr/test
chown -R vpopmail:vchkpw /home/vpopmail/domains/cloudflex.tr
```

### Yöntem 3: Init Container ile Otomatik Yapılandırma

Deployment'a init container ekleyerek Qmail yapılandırmasını otomatikleştirin. (Chart güncellemesi gerekir)

## Kalıcı Çözüm

Qmail deployment'ına init container ekleyerek bu sorunu kalıcı olarak çözebiliriz. İsterseniz chart'ı güncelleyebilirim.

## Alternatif: Farklı Qmail Image Kullanımı

Eğer sorun devam ederse, farklı bir Qmail image'ı kullanmayı düşünebilirsiniz:
- `tiredofit/qmail` 
- `qmailrocks/docker-qmail`

## Not

`robreardon/qmail` image'ının dokümantasyonunu kontrol edin veya image sahibiyle iletişime geçin.

