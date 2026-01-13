#!/bin/bash
# Qmail Domain ve Kullanıcı Kurulum Scripti

POD=$(kubectl get pods -n mail -l component=mail-server -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD" ]; then
    echo "Qmail pod bulunamadı!"
    exit 1
fi

echo "Qmail pod: $POD"
echo "Domain ve gerekli dosyalar oluşturuluyor..."

kubectl exec -n mail $POD -- bash -c "
# Gerekli dizinleri ve dosyaları oluştur
mkdir -p /var/qmail/control /var/qmail/users /home/vpopmail/domains/cloudflex.tr
touch /var/qmail/control/rcpthosts /var/qmail/users/assign /var/qmail/control/rcpthosts.lock

# İzinleri ayarla
chown -R vpopmail:vchkpw /var/qmail/users /home/vpopmail/domains/cloudflex.tr
chown qmaild:qmail /var/qmail/control
chown vpopmail:vchkpw /var/qmail/control/rcpthosts /var/qmail/control/rcpthosts.lock
chmod 755 /var/qmail/control
chmod 644 /var/qmail/control/rcpthosts /var/qmail/users/assign
chmod 666 /var/qmail/control/rcpthosts.lock

# Domain ekle (eğer yoksa)
if ! grep -q 'cloudflex.tr' /var/qmail/control/rcpthosts 2>/dev/null; then
    echo 'cloudflex.tr' >> /var/qmail/control/rcpthosts
    echo 'Domain cloudflex.tr rcpthosts dosyasına eklendi'
else
    echo 'Domain cloudflex.tr zaten mevcut'
fi

# Assign dosyasına ekle (eğer yoksa)
if ! grep -q 'cloudflex.tr' /var/qmail/users/assign 2>/dev/null; then
    echo '+cloudflex.tr::5000:5000:/home/vpopmail/domains/cloudflex.tr::' >> /var/qmail/users/assign
    echo 'Domain cloudflex.tr assign dosyasına eklendi'
else
    echo 'Domain cloudflex.tr zaten assign dosyasında'
fi

echo 'Domain yapılandırması tamamlandı!'
"

echo ""
echo "✅ Domain hazır!"
echo ""
echo "Şimdi kullanıcı oluşturmak için:"
echo "1. QmailAdmin kullanın (önerilen):"
echo "   kubectl port-forward -n mail $POD 8080:80"
echo "   Sonra http://localhost:8080/qmailadmin adresine gidin"
echo ""
echo "2. Veya pod'a bağlanıp komut satırından:"
echo "   kubectl exec -it -n mail $POD -- su - vpopmail -c '/home/vpopmail/bin/vadduser test@cloudflex.tr'"
