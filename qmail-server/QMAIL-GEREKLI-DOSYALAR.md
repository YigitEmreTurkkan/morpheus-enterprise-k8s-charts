# Qmail SMTP Servisleri İçin Gerekli Dosyalar

## 🚨 Tespit Edilen Sorun

Qmail loglarında şu hatalar görülüyor:
```
❌ can't find command '/var/qmail/supervise/qmail-send/run'
❌ can't find command '/var/qmail/supervise/qmail-smtpd/run'
❌ qmail-send entered FATAL state
❌ qmail-smtpd entered FATAL state
```

## 📋 Gerekli Dosyalar ve Dizinler

### 1. Supervise Dizin Yapısı

Qmail SMTP servislerini başlatmak için **daemontools/supervise** yapısı gerekiyor:

```
/var/qmail/supervise/
├── qmail-send/
│   └── run          # Qmail send servisini başlatan script
└── qmail-smtpd/
    └── run          # Qmail SMTP servisini başlatan script
```

### 2. Gerekli Dosyalar

#### `/var/qmail/supervise/qmail-send/run`
```bash
#!/bin/sh
exec /usr/bin/setuidgid qmaild /usr/bin/softlimit -m 2000000 \
  /usr/bin/qmail-send
```

#### `/var/qmail/supervise/qmail-smtpd/run`
```bash
#!/bin/sh
exec /usr/bin/tcpserver -v -R -H -l 0 \
  -x /etc/tcp.smtp.cdb \
  -c 100 \
  0 25 /usr/bin/qmail-smtpd
```

### 3. Qmail Control Dosyaları

`/var/qmail/control/` dizininde şu dosyalar olmalı:

- `rcpthosts` - Kabul edilen domain'ler
- `me` - Mail sunucu hostname
- `locals` - Local domain'ler
- `virtualdomains` - Virtual domain'ler
- `concurrencylocal` - Local concurrency limit
- `concurrencyremote` - Remote concurrency limit
- `timeoutconnect` - Connection timeout
- `timeoutremote` - Remote timeout
- `timeoutsmtpd` - SMTP daemon timeout

### 4. Qmail Binary Dosyaları

Container'da şu binary'ler olmalı:

- `/usr/bin/qmail-send` - Mail gönderme servisi
- `/usr/bin/qmail-smtpd` - SMTP daemon
- `/usr/bin/qmail-queue` - Mail kuyruğu
- `/usr/bin/qmail-inject` - Mail injection
- `/usr/bin/tcpserver` - TCP server (ucspi-tcp)
- `/usr/bin/setuidgid` - Set UID/GID
- `/usr/bin/softlimit` - Resource limits

## 🔧 Çözüm: Dosyaları Oluşturma

### Yöntem 1: Init Container ile

Helm chart'a init container ekleyerek gerekli dosyaları oluşturabilirsiniz:

```yaml
# templates/mail-deployment.yaml içine ekle
initContainers:
- name: setup-qmail
  image: busybox
  command:
  - /bin/sh
  - -c
  - |
    mkdir -p /var/qmail/supervise/qmail-send
    mkdir -p /var/qmail/supervise/qmail-smtpd
    
    cat > /var/qmail/supervise/qmail-send/run << 'EOF'
    #!/bin/sh
    exec /usr/bin/setuidgid qmaild /usr/bin/softlimit -m 2000000 \
      /usr/bin/qmail-send
    EOF
    
    cat > /var/qmail/supervise/qmail-smtpd/run << 'EOF'
    #!/bin/sh
    exec /usr/bin/tcpserver -v -R -H -l 0 \
      -x /etc/tcp.smtp.cdb \
      -c 100 \
      0 25 /usr/bin/qmail-smtpd
    EOF
    
    chmod +x /var/qmail/supervise/qmail-send/run
    chmod +x /var/qmail/supervise/qmail-smtpd/run
  volumeMounts:
  - name: mail-storage
    mountPath: /var/qmail
```

### Yöntem 2: ConfigMap ile

Supervise script'lerini ConfigMap olarak oluşturun:

```yaml
# templates/qmail-supervise-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "qmail-server.fullname" . }}-supervise
data:
  qmail-send-run: |
    #!/bin/sh
    exec /usr/bin/setuidgid qmaild /usr/bin/softlimit -m 2000000 \
      /usr/bin/qmail-send
  qmail-smtpd-run: |
    #!/bin/sh
    exec /usr/bin/tcpserver -v -R -H -l 0 \
      -x /etc/tcp.smtp.cdb \
      -c 100 \
      0 25 /usr/bin/qmail-smtpd
```

### Yöntem 3: Manuel Oluşturma

Pod'a bağlanıp manuel oluşturun:

```bash
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n mail $POD -- /bin/sh

# Container içinde:
mkdir -p /var/qmail/supervise/qmail-send
mkdir -p /var/qmail/supervise/qmail-smtpd

# qmail-send/run
cat > /var/qmail/supervise/qmail-send/run << 'EOF'
#!/bin/sh
exec /usr/bin/setuidgid qmaild /usr/bin/softlimit -m 2000000 \
  /usr/bin/qmail-send
EOF

# qmail-smtpd/run
cat > /var/qmail/supervise/qmail-smtpd/run << 'EOF'
#!/bin/sh
exec /usr/bin/tcpserver -v -R -H -l 0 \
  -x /etc/tcp.smtp.cdb \
  -c 100 \
  0 25 /usr/bin/qmail-smtpd
EOF

chmod +x /var/qmail/supervise/qmail-send/run
chmod +x /var/qmail/supervise/qmail-smtpd/run
```

## ⚠️ Önemli Notlar

1. **PVC Mount**: `/var/qmail` PVC'ye mount edilmiş olmalı ki dosyalar kalıcı olsun
2. **İzinler**: Script'ler executable olmalı (`chmod +x`)
3. **Binary Kontrolü**: Qmail binary'lerinin container'da mevcut olduğundan emin olun
4. **Container Image**: `robreardon/qmail:latest` image'ının Qmail binary'lerini içerdiğini kontrol edin

## 🔍 Kontrol Komutları

### Binary'leri Kontrol Et
```bash
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n mail $POD -- which qmail-send qmail-smtpd tcpserver
```

### Supervise Dizinlerini Kontrol Et
```bash
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n mail $POD -- ls -la /var/qmail/supervise/
```

### Control Dosyalarını Kontrol Et
```bash
POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n mail $POD -- ls -la /var/qmail/control/
```

## 🚀 Önerilen Çözüm

1. **Container Image Kontrolü**: `robreardon/qmail:latest` image'ının Qmail binary'lerini içerdiğini doğrulayın
2. **Init Container Ekle**: Helm chart'a init container ekleyerek supervise dosyalarını otomatik oluşturun
3. **PVC Mount**: Dosyaların `/var/qmail` (PVC mount point) altında oluşturulduğundan emin olun
4. **Pod Restart**: Dosyaları oluşturduktan sonra pod'u restart edin

## 📚 Referanslar

- [Qmail Installation Guide](http://www.lifewithqmail.org/lwq.html)
- [Daemontools Documentation](https://cr.yp.to/daemontools.html)
- [Qmail Supervise Setup](http://www.qmail.org/top.html#install)


