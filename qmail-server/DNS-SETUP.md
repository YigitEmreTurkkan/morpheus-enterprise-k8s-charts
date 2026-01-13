# DNS Yapılandırması - cloudflex.tr

Qmail mail sunucunuzun düzgün çalışması için aşağıdaki DNS kayıtlarını `cloudflex.tr` domaini için yapılandırmanız gerekmektedir.

## Gerekli DNS Kayıtları

### 1. MX (Mail Exchange) Kaydı

Mail sunucunuzun adresini belirtir. Öncelik değeri düşük olan kayıt öncelikli kullanılır.

```
cloudflex.tr.    IN    MX    10    mail.cloudflex.tr.
```

### 2. A Kaydı (Mail Sunucusu)

Mail sunucunuzun IP adresini belirtir. Kubernetes cluster'ınızın LoadBalancer IP'si veya Ingress IP'si olmalıdır.

```
mail.cloudflex.tr.    IN    A    <YOUR-KUBERNETES-IP>
```

**Not**: `<YOUR-KUBERNETES-IP>` yerine Kubernetes servisinizin dış IP adresini yazın.

### 3. SPF (Sender Policy Framework) Kaydı

Gönderen e-posta sunucunuzun yetkisini doğrular ve spam'i önler.

```
cloudflex.tr.    IN    TXT    "v=spf1 mx a:mail.cloudflex.tr ~all"
```

veya daha kısıtlayıcı:

```
cloudflex.tr.    IN    TXT    "v=spf1 mx a:mail.cloudflex.tr -all"
```

### 4. DKIM (DomainKeys Identified Mail) Kaydı (Önerilen)

E-postalarınızın gerçekten sizden geldiğini doğrular. Qmail image'ı DKIM desteği sağlıyorsa yapılandırılmalıdır.

```
default._domainkey.cloudflex.tr.    IN    TXT    "v=DKIM1; k=rsa; p=<YOUR-PUBLIC-KEY>"
```

**Not**: DKIM public key'ini Qmail container'ından almanız gerekebilir.

### 5. DMARC (Domain-based Message Authentication) Kaydı (Önerilen)

E-posta kimlik doğrulama politikalarınızı tanımlar.

```
_dmarc.cloudflex.tr.    IN    TXT    "v=DMARC1; p=none; rua=mailto:admin@cloudflex.tr; ruf=mailto:admin@cloudflex.tr; fo=1"
```

Başlangıç için `p=none` kullanın. Test ettikten sonra `p=quarantine` veya `p=reject` olarak değiştirebilirsiniz.

### 6. PTR (Reverse DNS) Kaydı (Önerilen)

IP adresinden domain'e ters arama. VPS/Cloud sağlayıcınızdan yapılandırılmalıdır.

```
<YOUR-IP>    IN    PTR    mail.cloudflex.tr.
```

## DNS Yapılandırma Kontrolü

DNS kayıtlarınızı kontrol etmek için:

```bash
# MX kaydı kontrolü
dig cloudflex.tr MX

# A kaydı kontrolü
dig mail.cloudflex.tr A

# SPF kaydı kontrolü
dig cloudflex.tr TXT | grep spf

# DMARC kaydı kontrolü
dig _dmarc.cloudflex.tr TXT
```

## Kubernetes Yapılandırması

### LoadBalancer Service Kullanımı

Eğer LoadBalancer kullanıyorsanız, service'i güncelleyin:

```yaml
# templates/mail-service.yaml içinde
spec:
  type: LoadBalancer  # ClusterIP yerine
```

### Ingress Kullanımı

NGINX Ingress Controller kullanıyorsanız, TCP/UDP portları için ConfigMap oluşturun:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: tcp-services
  namespace: ingress-nginx
data:
  "25": "default/qmail-server:25"
  "587": "default/qmail-server:587"
  "110": "default/qmail-server:110"
  "143": "default/qmail-server:143"
  "995": "default/qmail-server:995"
  "993": "default/qmail-server:993"
```

## Test Etme

DNS yapılandırması tamamlandıktan sonra (genellikle 24-48 saat içinde yayılır):

1. **MX kaydı testi:**
   ```bash
   dig cloudflex.tr MX +short
   ```

2. **E-posta gönderme testi:**
   - Gmail veya başka bir e-posta servisinden `test@cloudflex.tr` adresine mail gönderin
   - Mail'in gelip gelmediğini kontrol edin

3. **E-posta alma testi:**
   - `test@cloudflex.tr` adresinden dış bir adrese mail gönderin
   - Spam klasörüne düşmemesini kontrol edin

## Önemli Notlar

- DNS değişikliklerinin yayılması 24-48 saat sürebilir
- SPF kaydı olmadan e-postalar spam olarak işaretlenebilir
- DMARC kaydı e-posta güvenliğini artırır
- PTR kaydı bazı mail sunucuları tarafından zorunlu tutulabilir
- Firewall kurallarınızın 25, 587, 110, 143, 995, 993 portlarını açtığından emin olun

