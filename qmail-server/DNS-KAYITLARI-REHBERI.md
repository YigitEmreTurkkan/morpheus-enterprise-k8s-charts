# DNS Kayıtları Oluşturma Rehberi

## 📋 Gerekli DNS Kayıtları

Qmail mail sunucunuzun çalışması için aşağıdaki DNS kayıtlarını oluşturmanız gerekmektedir.

---

## 1️⃣ MX (Mail Exchange) Kaydı

### Ne İşe Yarar?
Mail sunucunuzun adresini belirtir. Gelen email'ler bu sunucuya yönlendirilir.

### DNS Kaydı

```
Kayıt Türü: MX
Host/Name: @ (veya cloudflex.tr)
Value/Points to: mail.cloudflex.tr
Priority: 10
TTL: 3600 (veya Auto)
```

### Adım Adım (Cloudflare Örneği)

1. Cloudflare paneline giriş yapın
2. `cloudflex.tr` domain'ini seçin
3. **DNS** sekmesine gidin
4. **Add record** butonuna tıklayın
5. Şu bilgileri girin:
   - **Type**: `MX`
   - **Name**: `@` (veya boş bırakın)
   - **Mail server**: `mail.cloudflex.tr`
   - **Priority**: `10`
   - **TTL**: `Auto` (veya `3600`)
6. **Save** butonuna tıklayın

### Adım Adım (Namecheap Örneği)

1. Namecheap paneline giriş yapın
2. **Domain List** → `cloudflex.tr` → **Manage**
3. **Advanced DNS** sekmesine gidin
4. **Add New Record** butonuna tıklayın
5. Şu bilgileri girin:
   - **Type**: `MX Record`
   - **Host**: `@`
   - **Value**: `mail.cloudflex.tr`
   - **Priority**: `10`
   - **TTL**: `Automatic` (veya `3600`)
6. **Save All Changes** butonuna tıklayın

### Kontrol

```bash
dig cloudflex.tr MX +short
```

**Beklenen Çıktı:**
```
10 mail.cloudflex.tr.
```

---

## 2️⃣ A Kaydı (Mail Sunucusu IP'si)

### Ne İşe Yarar?
Mail sunucusunun IP adresini belirtir. `mail.cloudflex.tr` domain'inin hangi IP'ye işaret ettiğini gösterir.

### Önce IP Adresini Bulun

Kubernetes Ingress Controller'ın IP adresini bulun:

```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

**EXTERNAL-IP** veya **LoadBalancer IP** değerini not edin.

### DNS Kaydı

```
Kayıt Türü: A
Host/Name: mail
Value/Points to: <YOUR-KUBERNETES-INGRESS-IP>
TTL: 3600 (veya Auto)
```

**Örnek:**
```
Kayıt Türü: A
Host/Name: mail
Value/Points to: 192.168.1.100
TTL: 3600
```

### Adım Adım (Cloudflare Örneği)

1. Cloudflare paneline giriş yapın
2. `cloudflex.tr` domain'ini seçin
3. **DNS** sekmesine gidin
4. **Add record** butonuna tıklayın
5. Şu bilgileri girin:
   - **Type**: `A`
   - **Name**: `mail`
   - **IPv4 address**: `<YOUR-KUBERNETES-INGRESS-IP>` (örn: `192.168.1.100`)
   - **Proxy status**: `DNS only` (turuncu bulut kapalı olmalı - mail için)
   - **TTL**: `Auto` (veya `3600`)
6. **Save** butonuna tıklayın

**⚠️ ÖNEMLİ:** Mail için Cloudflare proxy'yi **KAPALI** tutun (DNS only). Proxy açık olursa mail portları çalışmaz.

### Adım Adım (Namecheap Örneği)

1. Namecheap paneline giriş yapın
2. **Domain List** → `cloudflex.tr` → **Manage**
3. **Advanced DNS** sekmesine gidin
4. **Add New Record** butonuna tıklayın
5. Şu bilgileri girin:
   - **Type**: `A Record`
   - **Host**: `mail`
   - **Value**: `<YOUR-KUBERNETES-INGRESS-IP>` (örn: `192.168.1.100`)
   - **TTL**: `Automatic` (veya `3600`)
6. **Save All Changes** butonuna tıklayın

### Kontrol

```bash
dig mail.cloudflex.tr A +short
```

**Beklenen Çıktı:**
```
192.168.1.100
```

---

## 3️⃣ SPF (Sender Policy Framework) Kaydı

### Ne İşe Yarar?
Email gönderim yetkisini doğrular. Domain'inizden gönderilen email'lerin hangi sunuculardan gönderilebileceğini belirtir. Spam'i önler.

### DNS Kaydı (Önerilen - Esnek)

```
Kayıt Türü: TXT
Host/Name: @ (veya cloudflex.tr)
Value: v=spf1 mx a:mail.cloudflex.tr ~all
TTL: 3600 (veya Auto)
```

**Açıklama:**
- `v=spf1`: SPF versiyonu
- `mx`: MX kaydında belirtilen sunucular email gönderebilir
- `a:mail.cloudflex.tr`: mail.cloudflex.tr'nin A kaydındaki IP email gönderebilir
- `~all`: Diğer sunuculardan gelen email'ler "soft fail" (şüpheli ama engellenmez)

### DNS Kaydı (Daha Kısıtlayıcı - Güvenli)

```
Kayıt Türü: TXT
Host/Name: @ (veya cloudflex.tr)
Value: v=spf1 mx a:mail.cloudflex.tr -all
TTL: 3600 (veya Auto)
```

**Açıklama:**
- `-all`: Diğer sunuculardan gelen email'ler "hard fail" (tamamen reddedilir)

### Adım Adım (Cloudflare Örneği)

1. Cloudflare paneline giriş yapın
2. `cloudflex.tr` domain'ini seçin
3. **DNS** sekmesine gidin
4. **Add record** butonuna tıklayın
5. Şu bilgileri girin:
   - **Type**: `TXT`
   - **Name**: `@` (veya boş bırakın)
   - **Content**: `v=spf1 mx a:mail.cloudflex.tr ~all`
   - **TTL**: `Auto` (veya `3600`)
6. **Save** butonuna tıklayın

### Adım Adım (Namecheap Örneği)

1. Namecheap paneline giriş yapın
2. **Domain List** → `cloudflex.tr` → **Manage**
3. **Advanced DNS** sekmesine gidin
4. **Add New Record** butonuna tıklayın
5. Şu bilgileri girin:
   - **Type**: `TXT Record`
   - **Host**: `@`
   - **Value**: `v=spf1 mx a:mail.cloudflex.tr ~all`
   - **TTL**: `Automatic` (veya `3600`)
6. **Save All Changes** butonuna tıklayın

### Kontrol

```bash
dig cloudflex.tr TXT +short | grep spf
```

**Beklenen Çıktı:**
```
"v=spf1 mx a:mail.cloudflex.tr ~all"
```

---

## 📊 Özet Tablo

| Kayıt Türü | Host/Name | Value | Priority | TTL |
|------------|-----------|-------|-----------|-----|
| **MX** | `@` | `mail.cloudflex.tr` | `10` | `3600` |
| **A** | `mail` | `<YOUR-KUBERNETES-IP>` | - | `3600` |
| **TXT (SPF)** | `@` | `v=spf1 mx a:mail.cloudflex.tr ~all` | - | `3600` |

---

## ✅ Tüm Kayıtları Kontrol Etme

Tüm DNS kayıtlarınızı kontrol etmek için:

```bash
# MX kaydı
echo "=== MX Kaydı ==="
dig cloudflex.tr MX +short

# A kaydı
echo "=== A Kaydı ==="
dig mail.cloudflex.tr A +short

# SPF kaydı
echo "=== SPF Kaydı ==="
dig cloudflex.tr TXT +short | grep spf
```

---

## ⏱️ DNS Yayılımı

- **Yerel DNS**: Birkaç dakika
- **Global DNS**: 24-48 saat (genellikle 1-2 saat içinde)

DNS kayıtlarınızın yayıldığını kontrol etmek için:

```bash
# Farklı DNS sunucularından kontrol
dig @8.8.8.8 cloudflex.tr MX +short  # Google DNS
dig @1.1.1.1 cloudflex.tr MX +short  # Cloudflare DNS
```

---

## ⚠️ Önemli Notlar

1. **A Kaydı IP'si:**
   - Kubernetes Ingress Controller'ın **EXTERNAL-IP** veya **LoadBalancer IP**'sini kullanın
   - Bu IP'yi bulmak için: `kubectl get svc -n ingress-nginx ingress-nginx-controller`

2. **Cloudflare Proxy:**
   - Mail için Cloudflare proxy'yi **KAPALI** tutun (DNS only)
   - Proxy açık olursa mail portları (25, 587, vb.) çalışmaz

3. **SPF Kaydı:**
   - İlk kurulumda `~all` kullanın (esnek)
   - Test ettikten sonra `-all` kullanabilirsiniz (daha güvenli)

4. **TTL Değeri:**
   - Test aşamasında düşük TTL (300-600) kullanabilirsiniz
   - Production'da yüksek TTL (3600+) kullanın

5. **Çoklu MX Kayıtları:**
   - Birden fazla mail sunucunuz varsa, farklı priority değerleri kullanın
   - Düşük priority değeri önceliklidir (örn: 10, 20, 30)

---

## 🔧 Sorun Giderme

### MX Kaydı Çalışmıyor

```bash
# MX kaydını kontrol et
dig cloudflex.tr MX +short

# Eğer boşsa, DNS kaydını tekrar kontrol edin
# DNS sağlayıcınızda kaydın doğru oluşturulduğundan emin olun
```

### A Kaydı Çalışmıyor

```bash
# A kaydını kontrol et
dig mail.cloudflex.tr A +short

# IP adresinin doğru olduğundan emin olun
# Kubernetes Ingress IP'sini kontrol edin:
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

### SPF Kaydı Çalışmıyor

```bash
# SPF kaydını kontrol et
dig cloudflex.tr TXT +short | grep spf

# SPF kaydının doğru formatta olduğundan emin olun
# Tırnak işaretleri olmadan girmelisiniz
```

### Email Gönderemiyorum

1. Tüm DNS kayıtlarını kontrol edin
2. DNS yayılımını bekleyin (24-48 saat)
3. Firewall kurallarını kontrol edin (25, 587 portları açık olmalı)
4. Qmail pod'unun çalıştığından emin olun:
   ```bash
   kubectl get pods -n mail -l component=mail-server
   ```

---

## 📚 İlgili Dosyalar

- `qmail-server/DNS-SETUP.md` - Genel DNS yapılandırması
- `qmail-server/DMARC-KAYDI.md` - DMARC kaydı rehberi
- `qmail-server/values.yaml` - Qmail yapılandırması

---

## 🆘 Yardım

DNS kayıtlarını oluştururken sorun yaşıyorsanız:

1. DNS sağlayıcınızın dokümantasyonuna bakın
2. DNS kayıtlarını kontrol edin (yukarıdaki komutlar)
3. DNS yayılımını bekleyin (24-48 saat)
4. Qmail pod loglarını kontrol edin:
   ```bash
   kubectl logs -n mail -l component=mail-server --tail=50
   ```


