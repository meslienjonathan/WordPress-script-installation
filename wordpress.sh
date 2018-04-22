#!/bin/bash

DatabasePass="test"
Directory="/var/www/html/index.html"
admin="word"
name="wordly"
email="meslien.jonathan@gmail.com"
url="wp.mywebchef.org"
urltwo="mywebchef.org"
folder="/var/www/html/toto"
ip=`hostname -I`
if [ $1 ]
then
    arg=$1
else
    arg="-p"
fi
echo "================================================================="
echo "             WordPress Serveur Configuration"
echo "                  By MESLIEN Jonathan"
echo "            https://github.com/meslienjonathan"
echo "================================================================="
echo "                                                                 "

if [ "$UID" -ne "0" ]
then
    echo "administrator rights are required"
    exit
fi

gestion_error()
{
    if [ $? != 0 ]
    then
	echo -e "\033[31m[Failed] error install: $1 check error.log\033[0m"
    else
	echo -e "\033[32m[Ok] installation succes $1\033[0m"
    fi
}

install()
{
    ok=0
    command -v $1 > /dev/null && ok=1
    if [ $ok = 1 ]
    then
	if [ $arg = "-f" ]
	then
        apt-get autoremove -y $1  >> /install.log 2>> error.log
	    apt-get purge -y $1  >> /install.log 2>> error.log
	    echo -e "\033[32m[Ok] suppression succes $1\033[0m"
	    apt-get install -y $1  >> /install.log 2>> error.log
	    gestion_error $1
	fi
	echo -e "\033[33m[Warning] $1 is already installed -f to force the installation\033[0m"
    else
	apt-get install -y $1 >> /install.log 2>> error.log
	gestion_error $1
    fi
}

apache_error()
{
    /etc/init.d/apache2 restart >> install.log 2>> error.log
    if [ $? != 0 ]
    then
	echo -e "\033[31m[Failed] error starting apache2: $1 check error.log\033[0m"
	echo -e "\033[31m-the program can not continue\033[0m"
	exit 1
    else
	echo -e "\033[32m[Ok] apache2 configuration $1\033[0m"
    fi

}
#---INSTALLATION DU SERVEUR WEB---#

echo "-------------ETAPE 1 INSTALLATION DU SERVEUR-----------" >> install.log
echo "" >> install.log
echo "-------------ETAPE 1 INSTALLATION DU SERVEUR-----------" >> error.log
echo "" >> error.log
echo "-------------ETAPE 1 INSTALLATION DU SERVEUR-----------"
echo ""
echo ""
sed -i "1i127.0.0.1      $url" /etc/hosts
install emacs
echo "deb http://packages.dotdeb.org jessie all" > /etc/apt/sources.list.d/dotdeb.list 2> /dev/null
echo "Add a key to the list of trusted keys:"
wget https://www.dotdeb.org/dotdeb.gpg >> install.log 2>> error.log && apt-key add dotdeb.gpg
echo "updating..."
apt-get update >> install.log 2>> error.log
install php7.0
install php7.0-fpm
install libapache2-mod-php7.0
install php7.0-gd
install php7.0-mysql
install php7.0-bz2
install php7.0-json
install php7.0-curl
install php7.0-pdo
install php7.0-mbstring
install php7.0-tokenizer
install php7.0-xml
install curl
rm dotdeb.gpg
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password"
export DEBIAN_FRONTEND=noninteractive
install mysql-server
install mysql-client
echo "updating..."
apt-get update >> install.log 2>> error.log
apache_error php
mkdir $folder
cd $folder
echo ""
echo "-------------ETAPE 2 INSTALLATION DE WORPRESS-----------"
echo ""
echo ""
echo ""
echo "-------------ETAPE 2 INSTALLATION DE WORPRESS-----------" >> install.log
echo "">> install.log
echo ""
echo "-------------ETAPE 2 INSTALLATION DE WORPRESS-----------" >> error.log
echo "">> error.log
a2enmod headers  >> /dev/null
a2enmod ssl  >> /dev/null
a2enmod rewrite >> /dev/null
if [ -f $Directory ]
then
    rm $Directory
    echo -e "\033[32mDirectory html clean\033[0m"
else
   echo -e "\033[32mDirectory html clean\033[0m"
fi
echo -e "\033[32mDownloading wordpress....\033[0m"
echo -e "configuration d'apache pour wordpress"
echo "<VirtualHost *:80>
        ServerName $urltwo
        ServerAlias $url
        ServerAdmin $email
        DocumentRoot $folder
        Redirect / https://$url/
        ErrorLog ${APACHE_LOG_DIR}/$url-error-wordpress.log
        CustomLog ${APACHE_LOG_DIR}/$url-custom-wordpress.log combined
</VirtualHost>
<VirtualHost *:443>

        ServerAdmin $email

        SSLEngine on
        SSLCertificateFile $folder/$url.crt
        SSLCertificateKeyFile $folder/$url.key
        DocumentRoot $folder
</VirtualHost>" > /etc/apache2/sites-available/wp.mywebchef.org.conf
apache_error worpdress
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
create_db() {
    echo "CREATE USER '$admin'@'localhost' IDENTIFIED BY  \"$DatabasePass\";" | mysql
    echo "CREATE DATABASE $name;" | mysql
    echo "GRANT ALL PRIVILEGES ON $name.* TO '$admin'@'localhost';" | mysql
    echo "FLUSH PRIVILEGES;" | mysql
    if [ `echo "SHOW DATABASES;" | mysql | grep $name` != $name ]
    then
        echo -e `date` "| Echec de la creation de la DB\n" >> error.log
        create_db
    fi
    echo -e `date` "| Base de donnÃ©e crÃ©e avec succÃ¨s\n" >> install.log
    return 0
}
create_db
install_wp() {
    wp core download --locale=fr_FR --force --allow-root
    echo -e `date` "| Telechargement du paquet WordPress" >> error.log
    wp core config --dbname=$name --dbuser=$admin --dbpass=$DatabasePass --skip-check --allow-root
    echo -e `date` "| Configuration en cours" >> install.log
    wp db create --allow-root
    echo -e `date` "| Creation de la db" >> install.log
    wp core install --url=$url --title="$name" --admin_user=$admin --admin_email=$email --admin_password=$site_password --allow-root
    echo -e `date` "| Installation" >> install.log
}
echo ""
echo "-------------ETAPE 3 INSTALLATION DU SSL-----------"
echo ""
echo ""
echo ""
echo "-------------ETAPE 3 INSTALLATION DU SSL-----------" >> install.log
echo "">> install.log
echo ""
echo "-------------ETAPE 3 INSTALLATION DU SSL-----------" >> error.log
echo "">> error.log
install_wp
if [ -f $url.key ] && [ -f $url.crt ]
then
    echo -e "certificat ssl déjà présent"
else
echo -e `date` "| Generation de la clé privée SSL\n" >> /var/log/install-debug.log
openssl req -nodes -newkey rsa:2048 -keyout $url.key -out $url.csr -subj "/C=FR/ST=IDF/L=PARIS/O=MyWebChef/OU=PrepWorkers/CN=$url"
echo -e `date` "| Generation du certificat SSL\n" >> /install.log
openssl x509 -req -days 36500 -in $url.csr -signkey $url.key -out $url.crt
fi
echo "<VirtualHost *:80>
ServerName $ip
Redirect 403 /
DocumentRoot /dev/null
</VirtualHost>">/etc/apache2/sites-available/direct.conf
a2ensite direct
a2ensite wp.mywebchef.org
apache_error wordpress
install lsb-release
sed -i 's/#PrintMotd yes/PrintMotd no/g' /etc/ssh/sshd_config
cat > /etc/profile.d/dynmotd.sh <<EOFDYN
#!/bin/bash

/usr/local/bin/dynmotd;

EOFDYN
touch /usr/local/bin/dynmotd
chmod +x /usr/local/bin/dynmotd

sudo cat > /usr/local/bin/dynmotd <<EOF
#!/bin/bash
#
# Author : Meslien Jonathan
#


# Process count
PROCCOUNT=\$( ps -Afl | wc -l )
PROCCOUNT=\$( expr \$PROCCOUNT - 5 )

# Uptime
UPTIME=\$(</proc/uptime)
UPTIME=\${UPTIME%%.*}
SECONDS=\$(( UPTIME%60 ))
MINUTES=\$(( UPTIME/60%60 ))
HOURS=\$(( UPTIME/60/60%24 ))
DAYS=\$(( UPTIME/60/60/24 ))

# SYSTEM INFO
# Hostname (UPPERCASE)
HOSTNAME=\$( echo \$(hostname)  | tr '[a-z]' '[A-Z]' )
# IP Address (list all ip addresses)
IP_ADDRESS=\$(echo \$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' |  sed ':a;N;\$!ba;s/\n/ , /g') )
# System : Description of the distribution
SYSTEM=\$(echo \$(lsb_release -d | awk -F':' '{print \$2}' | sed 's/^\s*//g') )
# Kernel release
KERNEL=\$( echo \$(uname -r) )
# CPU Info
CPU_INFO=\$(echo \$(more /proc/cpuinfo | grep processor | wc -l ) "x" \$(more /proc/cpuinfo | grep 'model name' | uniq |awk -F":"  '{print \$2}') )
# Total Memory
MEMORY=\$(echo \$(free -m |grep Mem: | awk -F " " '{print \$2}') MO)
# Memory Used
MEMORY_USED=\$(echo \$(free -m |grep Mem: | awk -F " " '{print \$3}') MO)



echo -e "
\033[1;31m+++++++++++++++++: \033[0;37mSystem Data\033[1;31m :+++++++++++++++++++
+ \033[0;37mHostname \033[1;31m= \033[1;32m\$HOSTNAME
\033[1;31m+ \033[0;37mAddress \033[1;31m= \033[1;32m\$IP_ADDRESS
\033[1;31m+ \033[0;37mSystem \033[1;31m= \033[1;32m\$SYSTEM
\033[1;31m+ \033[0;37mKernel \033[1;31m= \033[1;32m\$KERNEL
\033[1;31m+ \033[0;37mUptime \033[1;31m= \033[1;32m\$DAYS days, \$HOURS hours, \$MINUTES minutes, \$SECONDS seconds
\033[1;31m+ \033[0;37mCPU Info \033[1;31m= \033[1;32m\$CPU_INFO
\033[1;31m+ \033[0;37mMemory \033[1;31m= \033[1;32m\$MEMORY
\033[1;31m+ \033[0;37mMemory Used \033[1;31m= \033[1;32m\$MEMORY_USED
\033[1;31m+++++++++++++++++: \033[0;37mUser Data\033[1;31m :+++++++++++++++++++++
+ \033[0;37mUsername \033[1;31m= \033[1;32m`whoami`
\033[1;31m+ \033[0;37mProcesses \033[1;31m= \033[1;32m\$PROCCOUNT of `ulimit -u` MAX
\033[1;31m+++++++++++++++++: \033[0;37mInformation/Role\033[1;31m :++++++++++++++
\033[1;31m+ \033[0;37mServer \033[1;31m= \033[1;32mINFORMATION MUST BE FILLED /usr/local/bin/dynmotd
\033[1;31m+ \033[0;37m       \033[1;31m  \033[1;32m- Apache Server (ex.)
\033[1;31m+ \033[0;37m       \033[1;31m  \033[1;32m- FTP Server (ex.)
\033[1;31m+ \033[0;37m       \033[1;31m  \033[1;32m- Application Server (ex.)
\033[1;31m+++++++++++++++++++++++++++++++++++++++++++++++++++\033[0m"
EOF

echo -e "your password wordpress is $name_password"