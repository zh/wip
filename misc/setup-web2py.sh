echo "This script will:
1) install all modules need to run web2py on Ubuntu/Debian
2) install web2py in /home/www-data/
3) create a self signed sll certificate
4) setup web2py with mod_wsgi
5) overwrite /etc/apache2/sites-available/default
6) restart apache.

You may want to read this cript before running it.

Press a key to continue...[ctrl+C to abort]"

read CONFIRM

#!/bin/bash
# optional
# dpkg-reconfigure console-setup
# dpkg-reconfigure timezoneconf
# nano /etc/hostname
# nano /etc/network/interfaces
# nano /etc/resolv.conf
# reboot now
# ifconfig eth0

echo "installing useful packages"
echo "=========================="
apt-get update
apt-get -y upgrade
apt-get -y install emacs
apt-get -y install ssh
apt-get -y install zip unzip
apt-get -y install tar
apt-get -y install openssh-server
apt-get -y install build-essential
apt-get -y install python2.5
apt-get -y install ipython
apt-get -y install python-dev
apt-get -y install postgresql-8.3
apt-get -y install apache2
apt-get -y install libapache2-mod-wsgi
apt-get -y install python2.5-psycopg2
apt-get -y install postfix
apt-get -y install wget
/etc/init.d/postgresql-8.3 restart
# optional, uncomment for backups using samba
# apt-get -y install samba
# apt-get -y install smbfs

echo "downloading, installing and starting web2py"
echo "==========================================="
cd /home
mkdir www-data
cd www-data
rm web2py_src.zip*
wget http://web2py.com/examples/static/web2py_src.zip
unzip web2py_src.zip
chown -R www-data:www-data web2py
cd web2py
killall python2.5
# starting local web2py (optional) for debugging and tunelling
if [ -f parameters_8123.py ]
then
  echo "keeping existing admin password"
  sudo -u www-data nohup python2.5 web2py.py -i 127.0.0.1 -p 8123 -a '<recycle>' &
else
  echo 'your new admin password is "web2py". change it!!!'
  sudo -u www-data nohup python2.5 web2py.py -i 127.0.0.1 -p 8123 -a 'web2py' &
fi
# setup password for remote 443 access to 'web2py', uncomment file to enable
# echo 'password="098f6bcd4621d373cade4e832627b4f6"' > parameters_443.py
cd ..

echo "setting up apache modules"
echo "========================="
a2enmod ssl
a2enmod proxy
a2enmod proxy_http
mkdir /etc/apache2/ssl

echo "creating a self signed certificate"
echo "=================================="
openssl genrsa 1024 > /etc/apache2/ssl/self_signed.key
chmod 400 /etc/apache2/ssl/self_signed.key
openssl req -new -x509 -nodes -sha1 -days 365 -key /etc/apache2/ssl/self_signed.key > /etc/apache2/ssl/self_signed.cert
openssl x509 -noout -fingerprint -text < /etc/apache2/ssl/self_signed.cert > /etc/apache2/ssl/self_signed.info

echo "rewriting your apache config file to use mod_wsgi"
echo "================================================="
echo '
NameVirtualHost *:80
NameVirtualHost *:443

<VirtualHost *:80>
  WSGIDaemonProcess web2py user=www-data group=www-data display-name=%{GROUP}
  WSGIProcessGroup web2py
  WSGIScriptAlias / /home/www-data/web2py/wsgihandler.py

  <Directory /home/www-data/web2py>
    AllowOverride None
    Order Allow,Deny
    Deny from all
    <Files wsgihandler.py>
      Allow from all
    </Files>
  </Directory>

  AliasMatch ^/([^/]+)/static/(.*) \
           /home/www-data/web2py/applications/$1/static/$2
  <Directory /home/www-data/web2py/applications/*/static/>
    Order Allow,Deny
    Allow from all
  </Directory>

  <Location /admin>
  Deny from all
  </Location>

  <LocationMatch ^/([^/]+)/appadmin>
  Deny from all
  </LocationMatch>

  CustomLog /var/log/apache2/access.log common
  ErrorLog /var/log/apache2/error.log
</VirtualHost>

<VirtualHost *:443>
  SSLEngine on
  SSLCertificateFile /etc/apache2/ssl/self_signed.cert
  SSLCertificateKeyFile /etc/apache2/ssl/self_signed.key

  WSGIProcessGroup web2py

  WSGIScriptAlias / /home/www-data/web2py/wsgihandler.py

  <Directory /home/www-data/web2py>
    AllowOverride None
    Order Allow,Deny
    Deny from all
    <Files wsgihandler.py>
      Allow from all
    </Files>
  </Directory>

  AliasMatch ^/([^/]+)/static/(.*) \
        /home/www-data/web2py/applications/$1/static/$2

  <Directory /home/www-data/web2py/applications/*/static/>
    Order Allow,Deny
    Allow from all
  </Directory>

  CustomLog /var/log/apache2/access.log common
  ErrorLog /var/log/apache2/error.log
</VirtualHost>
' > /etc/apache2/sites-available/default

echo "restarting apage"
echo "================"

/etc/init.d/apache2 restart

echo "done!"