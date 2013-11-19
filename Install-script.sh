#!/bin/bash

#installation et lancement pidentd
dpkg -i openbsd-inetd_1104_i386.deb
#La commande suivante ne fonctionne plus, par contre, pidentd est dans les paquets debian (wheezy)
#dpkg -i pidentd_1104_i386.deb
aptitude install pidentd
/etc/init.d/openbsd-inetd start

#declaration proxy
export http_proxy=http://172.16.0.253:3128
export ftp_proxy=ftp://172.16.0.253:3128
apt-get update

#installation libpam-ldap
apt-get -y install libpam-ldap

#modification de /etc/pam_ldap.conf
sed -i -e 's/pam_password md5/#pam_password md5/' /etc/pam_ldap.conf
sed -i -e 's/#pam_password crypt/pam_password crypt/' /etc/pam_ldap.conf

#modification config pam pour ldap
#La commande suivante ne fonctionne pas.
auth-client-config -t nss -p lac_ldap
#la commande suivante est facultative (celle là par contre fonctionne)
#pam-auth-update

#modification des repertoires par défaut dans home
sed -i -e 's/^MUSIC/#&/' /etc/xdg/user-dirs.defaults
sed -i -e 's/^DOWNLOAD/#&/' /etc/xdg/user-dirs.defaults
sed -i -e 's/^TEMPLATES/#&/' /etc/xdg/user-dirs.defaults
sed -i -e 's/^PUBLIC/#&/' /etc/xdg/user-dirs.defaults
sed -i -e 's/^DOCUMENTS/#&/' /etc/xdg/user-dirs.defaults
sed -i -e 's/^PICTURES/#&/' /etc/xdg/user-dirs.defaults
sed -i -e 's/^VIDEO/#&/' /etc/xdg/user-dirs.defaults

#installation libpam-mount/smbfs est remplacé par cis-utils
apt-get -y install libpam-mount cifs-utils

#declaration des dossiers reseau a monter
sed -i -e '/<\/pam_mount>/i\<volume fstype="cifs" server="172.16.0.253" path="homes" mountpoint="~/LecteurH" options="iocharset=utf8" />' /etc/security/pam_mount.conf.xml
sed -i -e '/<\/pam_mount>/i\<volume fstype="cifs" server="172.16.0.253" path="commun" mountpoint="~/Commun" options="iocharset=utf8" />' /etc/security/pam_mount.conf.xml
sed -i -e '/<\/pam_mount>/i\<volume fstype="cifs" server="172.16.0.253" path="public" mountpoint="~/Public" options="iocharset=utf8" />\n' /etc/security/pam_mount.conf.xml

#modif /etc/pam.d/common-session
sed -i -e '/session.*optional.*mount/i\session required\tpam_mkhomedir.so umask=077 silent skel=/etc/skel/' /etc/pam.d/common-session

#modif /etc/rc.local
sed -i -e '/^exit 0/i\modprobe cifs\necho 0 > /proc/fs/cifs/LinuxExtensionsEnabled\n' /etc/rc.local

#liens symboliques
ln -s /bin/bash /bin/kwartz-sh
ln -s /bin/umount /bin/smbumount
