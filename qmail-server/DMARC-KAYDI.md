# DMARC TXT Kaydı Oluşturma

## 📋 DMARC Nedir?

DMARC (Domain-based Message Authentication, Reporting & Conformance), e-posta kimlik doğrulama politikalarınızı tanımlayan bir protokoldür. SPF ve DKIM kayıtlarınızla birlikte çalışır.

## 🔧 DMARC Kaydı Parametreleri

### Zorunlu Parametreler

- **v=DMARC1** - DMARC versiyonu (her zaman DMARC1)

### Önemli Parametreler

- **p=** - Policy (politika)
  - `none`: Sadece raporlama yap, email'leri engelleme (test için önerilen)
  - `quarantine`: Şüpheli email'leri spam klasörüne gönder
  - `reject`: Şüpheli email'leri tamamen reddet (production için önerilen)

- **rua=** - Aggregate Reports Email (toplu raporlar)
  - Format: `mailto:email@domain.com`
  - Örnek: `mailto:dmarc@cloudflex.tr`

### Opsiyonel Parametreler

- **ruf=** - Forensic Reports Email (detaylı raporlar)
  - Format: `mailto:email@domain.com`
  - Örnek: `mailto:dmarc@cloudflex.tr`

- **pct=** - Percentage (yüzde)
  - Varsayılan: `100`
  - Test için düşük değer (örn: `10`) kullanılabilir

- **adkim=** - DKIM Alignment
  - `r` (relaxed) - Varsayılan, daha esnek
  - `s` (strict) - Daha katı

- **aspf=** - SPF Alignment
  - `r` (relaxed) - Varsayılan, daha esnek
  - `s` (strict) - Daha katı

- **fo=** - Failure Options
  - `0`: Sadece SPF ve DKIM başarısız olduğunda rapor (varsayılan)
  - `1`: SPF veya DKIM başarısız olduğunda rapor
  - `d`: DKIM başarısız olduğunda rapor
  - `s`: SPF başarısız olduğunda rapor

- **sp=** - Subdomain Policy
  - Alt domain'ler için ayrı policy
  - Örnek: `sp=quarantine`

- **rf=** - Report Format
  - `afrf` (Authentication Failure Reporting Format) - Varsayılan

- **ri=** - Report Interval
  - Rapor gönderme aralığı (saniye cinsinden)
  - Varsayılan: `86400` (24 saat)

## 📝 DMARC Kaydı Örnekleri

### 1. Test/İlk Kurulum (Önerilen)

```
_dmarc.cloudflex.tr.    IN    TXT    "v=DMARC1; p=none; rua=mailto:dmarc@cloudflex.tr; ruf=mailto:dmarc@cloudflex.tr; pct=100; fo=1"
```

**Açıklama:**
- `p=none`: Email'leri engelleme, sadece raporlama
- `rua=mailto:dmarc@cloudflex.tr`: Toplu raporlar bu adrese gönderilecek
- `ruf=mailto:dmarc@cloudflex.tr`: Detaylı raporlar bu adrese gönderilecek
- `pct=100`: Tüm email'ler için uygulanacak
- `fo=1`: SPF veya DKIM başarısız olduğunda rapor

### 2. Production (Güvenli)

```
_dmarc.cloudflex.tr.    IN    TXT    "v=DMARC1; p=quarantine; rua=mailto:dmarc@cloudflex.tr; ruf=mailto:dmarc@cloudflex.tr; pct=100; adkim=r; aspf=r; fo=1"
```

**Açıklama:**
- `p=quarantine`: Şüpheli email'ler spam klasörüne gönderilecek
- `adkim=r`: DKIM alignment relaxed
- `aspf=r`: SPF alignment relaxed

### 3. Production (Çok Güvenli)

```
_dmarc.cloudflex.tr.    IN    TXT    "v=DMARC1; p=reject; rua=mailto:dmarc@cloudflex.tr; ruf=mailto:dmarc@cloudflex.tr; pct=100; adkim=s; aspf=s; fo=1"
```

**Açıklama:**
- `p=reject`: Şüpheli email'ler tamamen reddedilecek
- `adkim=s`: DKIM alignment strict
- `aspf=s`: SPF alignment strict

### 4. Kademeli Geçiş (Test için)

```
_dmarc.cloudflex.tr.    IN    TXT    "v=DMARC1; p=none; rua=mailto:dmarc@cloudflex.tr; pct=10; fo=1"
```

**Açıklama:**
- `pct=10`: Sadece %10 email için uygulanacak (test için)

## 🚀 DNS'e Ekleme

### DNS Sağlayıcınızda (Cloudflare, Namecheap, vb.)

1. **Kayıt Türü**: TXT
2. **Host/Name**: `_dmarc`
3. **Value/Content**: DMARC kaydınız (tırnak işaretleri olmadan)
4. **TTL**: 3600 (veya varsayılan)

### Örnek (Cloudflare)

```
Type: TXT
Name: _dmarc
Content: v=DMARC1; p=none; rua=mailto:dmarc@cloudflex.tr; ruf=mailto:dmarc@cloudflex.tr; pct=100; fo=1
TTL: Auto
```

## ✅ Kontrol Etme

DMARC kaydınızı kontrol etmek için:

```bash
# DMARC kaydı kontrolü
dig _dmarc.cloudflex.tr TXT +short

# veya
nslookup -type=TXT _dmarc.cloudflex.tr
```

## 📊 DMARC Raporlarını İnceleme

DMARC raporları XML formatında gönderilir. Raporları okumak için:

1. **Online Araçlar:**
   - https://dmarcian.com/dmarc-xml-parser/
   - https://www.dmarcanalyzer.com/

2. **Rapor Email Adresini Kontrol:**
   - `dmarc@cloudflex.tr` adresine gelen raporları kontrol edin

## ⚠️ Önemli Notlar

1. **Test Aşaması:**
   - İlk kurulumda mutlaka `p=none` kullanın
   - Raporları inceleyin ve sorunları çözün
   - Sonra `p=quarantine` veya `p=reject`'e geçin

2. **SPF ve DKIM:**
   - DMARC çalışması için SPF ve DKIM kayıtlarınızın da doğru yapılandırılmış olması gerekir

3. **Rapor Email Adresi:**
   - `dmarc@cloudflex.tr` veya `postmaster@cloudflex.tr` adresini oluşturduğunuzdan emin olun
   - Bu adrese gelen raporları düzenli olarak kontrol edin

4. **DNS Yayılımı:**
   - DNS değişikliklerinin yayılması 24-48 saat sürebilir

## 🔗 İlgili Kayıtlar

DMARC ile birlikte şu DNS kayıtlarının da olması gerekir:

1. **SPF Kaydı:**
   ```
   cloudflex.tr.    IN    TXT    "v=spf1 mx a:mail.cloudflex.tr ~all"
   ```

2. **DKIM Kaydı (Önerilen):**
   ```
   default._domainkey.cloudflex.tr.    IN    TXT    "v=DKIM1; k=rsa; p=<YOUR-PUBLIC-KEY>"
   ```

3. **MX Kaydı:**
   ```
   cloudflex.tr.    IN    MX    10    mail.cloudflex.tr.
   ```

## 📚 Kaynaklar

- [DMARC.org](https://dmarc.org/)
- [RFC 7489 - DMARC Specification](https://tools.ietf.org/html/rfc7489)
- [DMARC Record Assistant](https://dmarcian.com/dmarc-record-assistant/)


