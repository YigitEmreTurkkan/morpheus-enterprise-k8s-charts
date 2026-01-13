#!/bin/bash
# Qmail Kullanıcı Oluşturma Scripti

if [ -z "$1" ]; then
    echo "Kullanım: $0 <email> <password>"
    echo "Örnek: $0 admin@cloudflex.tr Admin123!"
    exit 1
fi

EMAIL=$1
PASSWORD=${2:-"TempPass123!"}

# Email formatını kontrol et
if [[ ! $EMAIL =~ @ ]]; then
    echo "Hata: E-posta adresi formatı yanlış. Örnek: admin@cloudflex.tr"
    exit 1
fi

USERNAME=$(echo $EMAIL | cut -d@ -f1)
DOMAIN=$(echo $EMAIL | cut -d@ -f2)

POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD" ]; then
    echo "Hata: Qmail pod bulunamadı!"
    exit 1
fi

echo "Qmail pod: $POD"
echo "Kullanıcı oluşturuluyor: $EMAIL"

# Kullanıcı dizini oluştur
kubectl exec -n mail $POD -- bash -c "
mkdir -p /home/vpopmail/domains/$DOMAIN/$USERNAME
chown -R vpopmail:vchkpw /home/vpopmail/domains/$DOMAIN/$USERNAME

# .qmail-default dosyası oluştur
touch /home/vpopmail/domains/$DOMAIN/$USERNAME/.qmail-default
chown vpopmail:vchkpw /home/vpopmail/domains/$DOMAIN/$USERNAME/.qmail-default

# Şifre hash'i oluştur ve kaydet
PASS_HASH=\$(python3 -c \"import crypt; print(crypt.crypt('$PASSWORD', crypt.mksalt(crypt.METHOD_SHA512)))\" 2>/dev/null || echo '')
if [ -n \"\$PASS_HASH\" ]; then
    echo \"\$PASS_HASH\" > /home/vpopmail/domains/$DOMAIN/$USERNAME/.password
    chown vpopmail:vchkpw /home/vpopmail/domains/$DOMAIN/$USERNAME/.password
    chmod 600 /home/vpopmail/domains/$DOMAIN/$USERNAME/.password
fi

echo 'Kullanıcı dizini ve dosyaları oluşturuldu'
"

# Assign dosyasına kullanıcı ekle (eğer yoksa)
kubectl exec -n mail $POD -- bash -c "
if ! grep -q \"+$DOMAIN:$USERNAME:\" /var/qmail/users/assign 2>/dev/null; then
    echo \"+$DOMAIN:$USERNAME:5000:5000:/home/vpopmail/domains/$DOMAIN/$USERNAME::\" >> /var/qmail/users/assign
    chown vpopmail:vchkpw /var/qmail/users/assign
    echo 'Kullanıcı assign dosyasına eklendi'
else
    echo 'Kullanıcı zaten assign dosyasında'
fi
"

echo ""
echo "✅ Kullanıcı oluşturuldu: $EMAIL"
echo ""
echo "Roundcube'da test edin:"
echo "  URL: https://webmail.cloudflex.tr"
echo "  Kullanıcı: $EMAIL"
echo "  Şifre: $PASSWORD"
echo ""


