# SMTP Bağlantı Bilgileri

## 📧 Qmail Mail Server SMTP Yapılandırması

### Temel Bilgiler

- **Domain**: `cloudflex.tr`
- **Hostname**: `mail.cloudflex.tr`
- **Mail Server**: Qmail (robreardon/qmail:latest)

---

## 🔌 SMTP Bağlantı Bilgileri

### Harici Erişim (Internet üzerinden)

**SMTP Sunucu Adresi:**
```
mail.cloudflex.tr
```

**SMTP Portları:**
- **Port 25** (SMTP) - Sunucudan sunucuya mail gönderimi
- **Port 587** (SMTP Submission) - Kullanıcı mail gönderimi (önerilen)

**Bağlantı Türü:**
- Port 25: Genellikle şifresiz (sunucu-sunucu)
- Port 587: STARTTLS/TLS destekli (kullanıcı gönderimi için önerilen)

### Dahili Erişim (Kubernetes Cluster içinden)

**SMTP Sunucu Adresi:**
```
qmail-server.mail.svc.cluster.local
```

veya

```
qmail-server.mail
```

**SMTP Portları:**
- **Port 25** (SMTP)
- **Port 587** (SMTP Submission)

---

## 📝 Email Client Yapılandırması

### Outlook / Microsoft 365

```
Giden Posta Sunucusu (SMTP): mail.cloudflex.tr
Port: 587
Şifreleme: STARTTLS
Kimlik Doğrulama: Gerekli
Kullanıcı Adı: kullanici@cloudflex.tr
Şifre: [kullanıcı şifresi]
```

### Gmail / Google Mail

Gmail, harici SMTP sunucularını kullanmak için "Gönderen" adresi olarak ekleyebilirsiniz.

### Thunderbird

1. **Hesap Ayarları** → **Sunucu Ayarları**
2. **Giden Posta (SMTP) Sunucusu**:
   - **Sunucu**: `mail.cloudflex.tr`
   - **Port**: `587`
   - **Güvenlik**: `STARTTLS`
   - **Kimlik Doğrulama**: `Normal şifre`
   - **Kullanıcı Adı**: `kullanici@cloudflex.tr`

### Apple Mail (macOS / iOS)

1. **Mail** → **Hesaplar** → **Hesap Ekle**
2. **Giden Posta Sunucusu**:
   - **SMTP Sunucu**: `mail.cloudflex.tr`
   - **Port**: `587`
   - **Güvenlik**: `STARTTLS`
   - **Kimlik Doğrulama**: `Şifre`
   - **Kullanıcı Adı**: `kullanici@cloudflex.tr`

### Android Email

1. **Email Uygulaması** → **Hesap Ekle**
2. **Giden Sunucu Ayarları**:
   - **SMTP Sunucu**: `mail.cloudflex.tr`
   - **Port**: `587`
   - **Güvenlik Türü**: `STARTTLS`
   - **Kimlik Doğrulama**: `Evet`
   - **Kullanıcı Adı**: `kullanici@cloudflex.tr`

---

## 💻 Uygulama/API Entegrasyonu

### PHP (PHPMailer)

```php
<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;

$mail = new PHPMailer(true);

$mail->isSMTP();
$mail->Host       = 'mail.cloudflex.tr';
$mail->SMTPAuth   = true;
$mail->Username   = 'kullanici@cloudflex.tr';
$mail->Password   = 'sifre';
$mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
$mail->Port       = 587;

$mail->setFrom('gonderici@cloudflex.tr', 'Gönderen Adı');
$mail->addAddress('alici@example.com', 'Alıcı Adı');

$mail->isHTML(true);
$mail->Subject = 'Test Email';
$mail->Body    = 'Bu bir test emailidir.';

$mail->send();
?>
```

### Python (smtplib)

```python
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# SMTP ayarları
smtp_server = "mail.cloudflex.tr"
smtp_port = 587
smtp_username = "kullanici@cloudflex.tr"
smtp_password = "sifre"

# Email oluştur
msg = MIMEMultipart()
msg['From'] = "gonderici@cloudflex.tr"
msg['To'] = "alici@example.com"
msg['Subject'] = "Test Email"

body = "Bu bir test emailidir."
msg.attach(MIMEText(body, 'plain'))

# SMTP bağlantısı ve gönderim
try:
    server = smtplib.SMTP(smtp_server, smtp_port)
    server.starttls()
    server.login(smtp_username, smtp_password)
    text = msg.as_string()
    server.sendmail(msg['From'], msg['To'], text)
    server.quit()
    print("Email başarıyla gönderildi!")
except Exception as e:
    print(f"Hata: {e}")
```

### Node.js (nodemailer)

```javascript
const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
    host: 'mail.cloudflex.tr',
    port: 587,
    secure: false, // true for 465, false for other ports
    auth: {
        user: 'kullanici@cloudflex.tr',
        pass: 'sifre'
    },
    tls: {
        rejectUnauthorized: false
    }
});

const mailOptions = {
    from: 'gonderici@cloudflex.tr',
    to: 'alici@example.com',
    subject: 'Test Email',
    text: 'Bu bir test emailidir.',
    html: '<p>Bu bir test emailidir.</p>'
};

transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
        console.log('Hata:', error);
    } else {
        console.log('Email gönderildi:', info.response);
    }
});
```

### .NET / C#

```csharp
using System.Net;
using System.Net.Mail;

SmtpClient client = new SmtpClient("mail.cloudflex.tr", 587);
client.EnableSsl = true;
client.Credentials = new NetworkCredential("kullanici@cloudflex.tr", "sifre");

MailMessage message = new MailMessage();
message.From = new MailAddress("gonderici@cloudflex.tr");
message.To.Add("alici@example.com");
message.Subject = "Test Email";
message.Body = "Bu bir test emailidir.";

try
{
    client.Send(message);
    Console.WriteLine("Email başarıyla gönderildi!");
}
catch (Exception ex)
{
    Console.WriteLine($"Hata: {ex.Message}");
}
```

### Java (JavaMail)

```java
import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;

Properties props = new Properties();
props.put("mail.smtp.host", "mail.cloudflex.tr");
props.put("mail.smtp.port", "587");
props.put("mail.smtp.auth", "true");
props.put("mail.smtp.starttls.enable", "true");

Session session = Session.getInstance(props, new javax.mail.Authenticator() {
    protected PasswordAuthentication getPasswordAuthentication() {
        return new PasswordAuthentication("kullanici@cloudflex.tr", "sifre");
    }
});

try {
    Message message = new MimeMessage(session);
    message.setFrom(new InternetAddress("gonderici@cloudflex.tr"));
    message.setRecipients(Message.RecipientType.TO, 
        InternetAddress.parse("alici@example.com"));
    message.setSubject("Test Email");
    message.setText("Bu bir test emailidir.");

    Transport.send(message);
    System.out.println("Email başarıyla gönderildi!");
} catch (MessagingException e) {
    throw new RuntimeException(e);
}
```

---

## 🔍 SMTP Test Komutları

### Telnet ile Test

```bash
# SMTP port 25 test
telnet mail.cloudflex.tr 25

# SMTP port 587 test
telnet mail.cloudflex.tr 587
```

### OpenSSL ile TLS Test

```bash
# STARTTLS test (port 587)
openssl s_client -connect mail.cloudflex.tr:587 -starttls smtp

# SSL/TLS test (port 465 - eğer aktifse)
openssl s_client -connect mail.cloudflex.tr:465
```

### nc (netcat) ile Test

```bash
# Port bağlantı testi
nc -zv mail.cloudflex.tr 25
nc -zv mail.cloudflex.tr 587
```

### swaks (Swiss Army Knife for SMTP)

```bash
# Basit test
swaks --to test@example.com \
      --from kullanici@cloudflex.tr \
      --server mail.cloudflex.tr \
      --port 587 \
      --auth LOGIN \
      --auth-user kullanici@cloudflex.tr \
      --auth-password sifre \
      --tls
```

---

## 📊 IMAP/POP3 Bilgileri (Email Alma)

### IMAP Ayarları

- **IMAP Sunucu**: `mail.cloudflex.tr`
- **IMAP Port**: `143` (STARTTLS) veya `993` (SSL/TLS)
- **Güvenlik**: STARTTLS veya SSL/TLS
- **Kullanıcı Adı**: `kullanici@cloudflex.tr`

### POP3 Ayarları

- **POP3 Sunucu**: `mail.cloudflex.tr`
- **POP3 Port**: `110` (STARTTLS) veya `995` (SSL/TLS)
- **Güvenlik**: STARTTLS veya SSL/TLS
- **Kullanıcı Adı**: `kullanici@cloudflex.tr`

---

## 🌐 Ingress Controller Bilgileri

### External IP Kontrolü

```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

**Çıktı örneği:**
```
NAME                       TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)
ingress-nginx-controller   LoadBalancer   10.0.0.100    203.0.113.10     80:30080/TCP,443:30443/TCP,25:30025/TCP,587:30587/TCP
```

Bu durumda `EXTERNAL-IP` (203.0.113.10) DNS A kaydında kullanılmalıdır.

### DNS A Kaydı

```
mail.cloudflex.tr    IN    A    203.0.113.10
```

---

## ⚙️ Mevcut Yapılandırma Özeti

| Özellik | Değer |
|---------|-------|
| Domain | `cloudflex.tr` |
| Hostname | `mail.cloudflex.tr` |
| SMTP Port | `25` |
| SMTP Submission Port | `587` |
| IMAP Port | `143` |
| IMAPS Port | `993` |
| POP3 Port | `110` |
| POP3S Port | `995` |
| HTTP Port | `80` |
| Namespace | `mail` |
| Service Name | `qmail-server` |

---

## 🔐 Güvenlik Notları

1. **Port 587 kullanın**: Kullanıcı mail gönderimi için port 587 (SMTP Submission) kullanın, STARTTLS ile.
2. **Port 25**: Genellikle sunucu-sunucu iletişimi için kullanılır, bazı ISP'ler tarafından engellenebilir.
3. **TLS/SSL**: Mümkün olduğunca şifreli bağlantı kullanın.
4. **Şifreler**: Güçlü şifreler kullanın ve düzenli olarak değiştirin.

---

## 📞 Sorun Giderme

SMTP bağlantı sorunları yaşıyorsanız, `SMTP-TROUBLESHOOTING.md` dosyasına bakın.

---

**Son Güncelleme**: Chart deployment tarihi
**Versiyon**: 0.1.0


