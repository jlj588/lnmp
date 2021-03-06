#!/bin/bash
# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script, please use root to install lnmp" && exit 1

echo "#######################################################################"
echo "#                    LNMP for CentOS/RadHat Linux                     #" 
echo "# For more information please visit https://github.com/lj2007331/lnmp #"
echo "#######################################################################"
echo ''

# get IP
IP=`ifconfig | grep 'inet addr:' | cut -d: -f2 | grep -v ^10. | grep -v ^192.168 | grep -v ^172. | grep -v ^127. | awk '{print  $1}' | awk '{print;exit}'`

# Set password
while :
do
    read -p "Please input the root password of MySQL:" mysqlrootpwd
    read -p "Please input the manager password of Pureftpd:" ftpmanagerpwd
    if (( ${#mysqlrootpwd} >= 5 && ${#ftpmanagerpwd} >=5 ));then
        break
    else
       echo "least 5 characters"
    fi
done

# Download packages
mkdir -p /root/lnmp/{source,conf}
function Download()
{
cd /root/lnmp
[ -s init.sh ] && echo 'init.sh found' || wget https://raw.github.com/lj2007331/lnmp/master/init.sh
cd /root/lnmp/source
[ -s cmake-2.8.10.2.tar.gz ] && echo 'cmake-2.8.10.2.tar.gz found' || wget http://www.cmake.org/files/v2.8/cmake-2.8.10.2.tar.gz
[ -s mysql-5.5.32.tar.gz ] && echo 'mysql-5.5.32.tar.gz found' || wget http://fossies.org/linux/misc/mysql-5.5.32.tar.gz
[ -s libiconv-1.14.tar.gz ] && echo 'libiconv-1.14.tar.gz found' || wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
[ -s libmcrypt-2.5.8.tar.gz ] && echo 'bmcrypt-2.5.8.tar.gz found' || wget http://iweb.dl.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
[ -s mhash-0.9.9.9.tar.gz ] && echo 'mhash-0.9.9.9.tar.gz found' || wget http://iweb.dl.sourceforge.net/project/mhash/mhash/0.9.9.9/mhash-0.9.9.9.tar.gz
[ -s mcrypt-2.6.8.tar.gz ] && echo 'mcrypt-2.6.8.tar.gz found' || wget http://vps.googlecode.com/files/mcrypt-2.6.8.tar.gz
[ -s php-5.3.27.tar.gz ] && echo 'php-5.3.27.tar.gz found' || wget http://kr1.php.net/distributions/php-5.3.27.tar.gz
[ -s memcache-2.2.5.tgz ] && echo 'memcache-2.2.5.tgz found' || wget http://pecl.php.net/get/memcache-2.2.5.tgz
[ -s eaccelerator-0.9.6.1.tar.bz2 ] && echo 'eaccelerator-0.9.6.1.tar.bz2 found' || wget http://superb-dca2.dl.sourceforge.net/project/eaccelerator/eaccelerator/eAccelerator%200.9.6.1/eaccelerator-0.9.6.1.tar.bz2
[ -s PDO_MYSQL-1.0.2.tgz ] && echo 'PDO_MYSQL-1.0.2.tgz found' || wget http://pecl.php.net/get/PDO_MYSQL-1.0.2.tgz
[ -s ImageMagick-6.8.3-10.tar.gz ] && echo 'ImageMagick-6.8.3-10.tar.gz found' || wget http://www.imagemagick.org/download/legacy/ImageMagick-6.8.3-10.tar.gz
[ -s imagick-3.0.1.tgz ] && echo 'imagick-3.0.1.tgz found' || wget http://pecl.php.net/get/imagick-3.0.1.tgz
[ -s pecl_http-1.7.5.tgz ] && echo 'pecl_http-1.7.5.tgz found' || wget http://pecl.php.net/get/pecl_http-1.7.5.tgz
[ -s pcre-8.32.tar.gz ] && echo 'pcre-8.32.tar.gz found' || wget http://iweb.dl.sourceforge.net/project/pcre/pcre/8.32/pcre-8.32.tar.gz
[ -s nginx-1.4.1.tar.gz ] && echo 'nginx-1.4.1.tar.gz found' || wget http://nginx.org/download/nginx-1.4.1.tar.gz
[ -s pure-ftpd-1.0.36.tar.gz ] && echo 'pure-ftpd-1.0.36.tar.gz found' || wget ftp://ftp.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.36.tar.gz
[ -s ftp_v2.1.tar.gz ] && echo 'ftp_v2.1.tar.gz found' || wget http://acelnmp.googlecode.com/files/ftp_v2.1.tar.gz
cd ../conf
[ -s init.d.nginx ] && echo 'init.d.nginx found' || wget https://raw.github.com/lj2007331/lnmp/master/conf/init.d.nginx
[ -s nginx.conf ] && echo 'nginx.conf found' || wget https://raw.github.com/lj2007331/lnmp/master/conf/nginx.conf
[ -s pure-ftpd.conf ] && echo 'pure-ftpd.conf found' || wget https://raw.github.com/lj2007331/lnmp/master/conf/pure-ftpd.conf
[ -s pureftpd-mysql.conf ] && echo 'pureftpd-mysql.conf found' || wget https://raw.github.com/lj2007331/lnmp/master/conf/pureftpd-mysql.conf
[ -s script.mysql ] && echo 'script.mysql found' || wget https://raw.github.com/lj2007331/lnmp/master/conf/script.mysql
}


function MySQL()
# install MySQL 
{
cd /root/lnmp/source
useradd -M -s /sbin/nologin mysql
mkdir -p /data/mysql;chown mysql.mysql -R /data/mysql
tar xzf cmake-2.8.10.2.tar.gz 
cd cmake-2.8.10.2
./configure
make &&  make install
cd ..
tar zxf mysql-5.5.32.tar.gz
cd mysql-5.5.32
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql/ \
-DMYSQL_DATADIR=/data/mysql  \
-DMYSQL_UNIX_ADDR=/data/mysql/mysqld.sock \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DMYSQL_TCP_PORT=3306 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DMYSQL_UNIX_ADDR=/data/mysql/mysql.sock \
-DWITH_DEBUG=0
make && make install

/bin/cp support-files/my-medium.cnf /etc/my.cnf
cp support-files/mysql.server /etc/init.d/mysqld 
chmod 755 /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on
cd ..

# my.cf
sed -i '38a ##############' /etc/my.cnf
sed -i '39a skip-name-resolve' /etc/my.cnf
sed -i '40a basedir=/usr/local/mysql' /etc/my.cnf
sed -i '41a datadir=/data/mysql' /etc/my.cnf
sed -i '42a user=mysql' /etc/my.cnf
sed -i '43a #lower_case_table_names = 1' /etc/my.cnf
sed -i '44a max_connections=1000' /etc/my.cnf
sed -i '45a ft_min_word_len=1' /etc/my.cnf
sed -i '46a expire_logs_days = 7' /etc/my.cnf
sed -i '47a query_cache_size=64M' /etc/my.cnf
sed -i '48a query_cache_type=1' /etc/my.cnf
sed -i '49a ##############' /etc/my.cnf

/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql/ --datadir=/data/mysql

chown mysql.mysql -R /data/mysql
/sbin/service mysqld start
export PATH=$PATH:/usr/local/mysql/bin
echo 'export PATH=$PATH:/usr/local/mysql/bin' >> /etc/profile
source /etc/profile

/usr/local/mysql/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"$mysqlrootpwd\" with grant option;"
/usr/local/mysql/bin/mysql -uroot -p$mysqlrootpwd -e "delete from mysql.user where Password='';"
/sbin/service mysqld restart
}

function PHP()
# install PHP 
{
cd /root/lnmp/source
tar xzf libiconv-1.14.tar.gz
cd libiconv-1.14
./configure --prefix=/usr/local
make && make install
cd ../

tar xzf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure
make && make install
/sbin/ldconfig
cd libltdl/
./configure --enable-ltdl-install
make && make install
cd ../../

tar xzf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9
./configure
make && make install
cd ../

if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	ln -s /usr/local/lib/libmcrypt.la /usr/lib64/libmcrypt.la
	ln -s /usr/local/lib/libmcrypt.so /usr/lib64/libmcrypt.so
	ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib64/libmcrypt.so.4
	ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib64/libmcrypt.so.4.4.8
	ln -s /usr/local/lib/libmhash.a /usr/lib64/libmhash.a
	ln -s /usr/local/lib/libmhash.la /usr/lib64/libmhash.la
	ln -s /usr/local/lib/libmhash.so /usr/lib64/libmhash.so
	ln -s /usr/local/lib/libmhash.so.2 /usr/lib64/libmhash.so.2
	ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib64/libmhash.so.2.0.1
	ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config
	ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /lib64/libmysqlclient.so.18
        ln -s /lib64/libpcre.so.0.0.1 /lib64/libpcre.so.1
        ln -s /usr/local/include/ImageMagick-6 /usr/local/include/ImageMagick
        cp -frp /usr/lib64/libldap* /usr/lib
else
	ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
	ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
	ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
	ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
	ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
	ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
	ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
	ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
	ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1
	ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config
	ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /lib/libmysqlclient.so.18
        ln -s /usr/local/include/ImageMagick-6 /usr/local/include/ImageMagick
        ln -s /lib/libpcre.so.0.0.1 /lib/libpcre.so.1
fi

tar xzf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8
/sbin/ldconfig
./configure
make && make install
cd ../

tar xzf php-5.3.27.tar.gz
useradd -M -s /sbin/nologin www
cd php-5.3.27
./configure  --prefix=/usr/local/php --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fpm --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-ldap --with-ldap-sasl --with-xmlrpc --enable-ftp --with-gettext --enable-zip --enable-soap --disable-debug
make ZEND_EXTRA_LIBS='-liconv'
make install
cp php.ini-production /usr/local/php/lib/php.ini

#php-fpm Init Script
cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
chkconfig --add php-fpm
chkconfig php-fpm on
cd ../

tar xzf memcache-2.2.5.tgz
cd memcache-2.2.5
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

tar xjf eaccelerator-0.9.6.1.tar.bz2
cd eaccelerator-0.9.6.1
/usr/local/php/bin/phpize
./configure --enable-eaccelerator=shared --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

tar xzf PDO_MYSQL-1.0.2.tgz
cd PDO_MYSQL-1.0.2
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-pdo-mysql=/usr/local/mysql
make && make install
cd ../

tar xzf ImageMagick-6.8.3-10.tar.gz
cd ImageMagick-6.8.3-10
./configure
make && make install
cd ../

tar xzf imagick-3.0.1.tgz
cd imagick-3.0.1
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

# Support HTTP request curls
tar xzf pecl_http-1.7.5.tgz
cd pecl_http-1.7.5 
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

# Modify php.ini
mkdir /tmp/eaccelerator
/bin/chown -R www.www /tmp/eaccelerator/
sed -i '808a extension_dir = "/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/"' /usr/local/php/lib/php.ini 
sed -i '809a extension = "memcache.so"' /usr/local/php/lib/php.ini 
sed -i '810a extension = "pdo_mysql.so"' /usr/local/php/lib/php.ini 
sed -i '811a extension = "imagick.so"' /usr/local/php/lib/php.ini 
sed -i '812a extension = "http.so"' /usr/local/php/lib/php.ini 
sed -i '135a output_buffering = On' /usr/local/php/lib/php.ini 
sed -i '848a cgi.fix_pathinfo=0' /usr/local/php/lib/php.ini 
sed -i 's@short_open_tag = Off@short_open_tag = On@g' /usr/local/php/lib/php.ini
sed -i 's@expose_php = On@expose_php = Off@g' /usr/local/php/lib/php.ini
sed -i 's@;date.timezone =@date.timezone = Asia/Shanghai@g' /usr/local/php/lib/php.ini
sed -i 's@#sendmail_path.*@#sendmail_path = /usr/sbin/sendmail -t@g' /usr/local/php/lib/php.ini
echo '[eaccelerator]
zend_extension="/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/eaccelerator.so"
eaccelerator.shm_size="64"
eaccelerator.cache_dir="/tmp/eaccelerator"
eaccelerator.enable="1"
eaccelerator.optimizer="1"
eaccelerator.check_mtime="1"
eaccelerator.debug="0"
eaccelerator.filter=""
eaccelerator.shm_max="0"
eaccelerator.shm_ttl="0"
eaccelerator.shm_prune_period="0"
eaccelerator.shm_only="0"
eaccelerator.compress="0"
eaccelerator.compress_level="9"
eaccelerator.keys = "disk_only"
eaccelerator.sessions = "disk_only"
eaccelerator.content = "disk_only"' >> /usr/local/php/lib/php.ini

cat > /usr/local/php/etc/php-fpm.conf <<EOF 
;;;;;;;;;;;;;;;;;;;;;
; FPM Configuration ;
;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;
; Global Options ;
;;;;;;;;;;;;;;;;;;

[global]
pid = run/php-fpm.pid
error_log = log/php-fpm.log
log_level = notice

emergency_restart_threshold = 30
emergency_restart_interval = 1m
process_control_timeout = 5s
daemonize = yes

;;;;;;;;;;;;;;;;;;;;
; Pool Definitions ;
;;;;;;;;;;;;;;;;;;;;

[www]

listen = 127.0.0.1:9000
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www

pm = dynamic
pm.max_children = 32
pm.start_servers = 4 
pm.min_spare_servers = 4
pm.max_spare_servers = 16
pm.max_requests = 512

request_terminate_timeout = 0
request_slowlog_timeout = 0

slowlog = log/$pool.log.slow
rlimit_files = 51200
rlimit_core = 0

catch_workers_output = yes
env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
EOF

# php start
service php-fpm start
}

function Nginx()
# install Nginx
{
cd /root/lnmp/source
tar xzf pcre-8.32.tar.gz
cd pcre-8.32
./configure
make && make install
cd ../

#tar xzf ngx_cache_purge-2.1.tar.gz 
tar xzf nginx-1.4.1.tar.gz
cd nginx-1.4.1

# Modify Nginx version
sed -i 's@#define NGINX_VERSION.*$@#define NGINX_VERSION      "2.2.14"@g' src/core/nginx.h 
sed -i 's@#define NGINX_VER.*NGINX_VERSION$@#define NGINX_VER          "Apache/" NGINX_VERSION@g' src/core/nginx.h 
#./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_stub_status_module --with-http_ssl_module --add-module=../ngx_cache_purge-2.1
./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_stub_status_module --with-http_ssl_module
make && make install
cd /root/lnmp/conf
cp init.d.nginx /etc/init.d/nginx
chmod 755 /etc/init.d/nginx
chkconfig --add nginx
chkconfig nginx on
mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf_bk
cp nginx.conf /usr/local/nginx/conf/nginx.conf

#logrotate nginx log
echo '/usr/local/nginx/logs/*.log {
daily
rotate 5
missingok
dateext
compress
notifempty
sharedscripts
postrotate
    [ -f /usr/local/nginx/logs/nginx.pid ] && kill -USR1 `cat /usr/local/nginx/logs/nginx.pid`
endscript
}' > /etc/logrotate.d/nginx

service nginx restart
}

function Pureftp()
# install Pureftpd and pureftpd_php_manager 
{
cd /root/lnmp/source
tar xzf pure-ftpd-1.0.36.tar.gz
cd pure-ftpd-1.0.36
./configure --prefix=/usr/local/pureftpd CFLAGS=-O2 --with-mysql=/usr/local/mysql --with-quotas --with-cookie --with-virtualhosts --with-virtualchroot --with-diraliases --with-sysquotas --with-ratios --with-altlog --with-paranoidmsg --with-shadow --with-welcomemsg  --with-throttling --with-uploadscript --with-language=simplified-chinese
make && make install
cp configuration-file/pure-config.pl /usr/local/pureftpd/sbin
chmod +x /usr/local/pureftpd/sbin/pure-config.pl
cp contrib/redhat.init /etc/init.d/pureftpd
sed -i 's@fullpath=.*@fullpath=/usr/local/pureftpd/sbin/$prog@' /etc/init.d/pureftpd
sed -i 's@pureftpwho=.*@pureftpwho=/usr/local/pureftpd/sbin/pure-ftpwho@' /etc/init.d/pureftpd
sed -i 's@/etc/pure-ftpd.conf@/usr/local/pureftpd/pure-ftpd.conf@' /etc/init.d/pureftpd
chmod +x /etc/init.d/pureftpd
chkconfig --add pureftpd
chkconfig pureftpd on

cd /root/lnmp/conf
/bin/cp pure-ftpd.conf /usr/local/pureftpd/
/bin/cp pureftpd-mysql.conf /usr/local/pureftpd/
mysqlftppwd=`cat /dev/urandom | head -1 | md5sum | head -c 8`
sed -i 's/tmppasswd/'$mysqlftppwd'/g' /usr/local/pureftpd/pureftpd-mysql.conf
sed -i 's/mysqlftppwd/'$mysqlftppwd'/g' script.mysql
sed -i 's/ftpmanagerpwd/'$ftpmanagerpwd'/g' script.mysql
/usr/local/mysql/bin/mysql -uroot -p$mysqlrootpwd< script.mysql
service pureftpd start

mkdir -p /data/admin
cd ../source
tar xzf ftp_v2.1.tar.gz
mv ftp /data/admin;chown -R www.www /data/admin
sed -i 's/tmppasswd/'$mysqlftppwd'/g' /data/admin/ftp/config.php
sed -i "s/myipaddress.com/`echo $IP`/g" /data/admin/ftp/config.php
sed -i 's/127.0.0.1/localhost/g' /data/admin/ftp/config.php
sed -i 's@iso-8859-1@UTF-8@' /data/admin/ftp/language/english.php
rm -rf  /data/admin/ftp/install.php
echo '<?php
phpinfo()
?>' > /data/admin/index.php
cd ../
}

function Iptables()
{
cat > /etc/sysconfig/iptables << EOF
# Firewall configuration written by system-config-securitylevel
# Manual customization of this file is not recommended.
*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 21 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 20000:30000 -j ACCEPT
-A INPUT -p icmp -m limit --limit 100/sec --limit-burst 100 -j ACCEPT
-A INPUT -p icmp -m limit --limit 1/s --limit-burst 10 -j ACCEPT
COMMIT
EOF
service iptables restart
}

Download 2>&1 | tee -a /root/lnmp/lnmp_install.log 
Download
chmod +x /root/lnmp/init.sh
/root/lnmp/init.sh 2>&1 | tee -a /root/lnmp/lnmp_install.log 
echo -e "\033[32minitialized successfully\033[0m"
MySQL 2>&1 | tee -a /root/lnmp/lnmp_install.log 
[ -d "/usr/local/mysql" ] && echo -e "\033[32mMySQL install successfully\033[0m" || echo "MySQL install failed"
PHP 2>&1 | tee -a /root/lnmp/lnmp_install.log 
[ -d "/usr/local/php" ] && echo -e "\033[32mPHP install successfully\033[0m" || echo "PHP install failed"
Nginx 2>&1 | tee -a /root/lnmp/lnmp_install.log 
[ -d "/usr/local/nginx" ] && echo -e "\033[32mNginx install successfully\033[0m" || echo "Nginx install failed"
Pureftp 2>&1 | tee -a /root/lnmp/lnmp_install.log 
[ -d "/usr/local/pureftpd" ] && echo -e "\033[32mPureftpd install successfully\033[0m" || echo "Pureftpd install failed"
Iptables 2>&1 | tee -a /root/lnmp/lnmp_install.log 

echo "################Congratulations####################"
echo "The path of some dirs:"
echo -e "Nginx dir:                     \033[32m/usr/local/nginx\033[0m"
echo -e "MySQL dir:                     \033[32m/usr/local/mysql\033[0m"
echo -e "PHP dir:                       \033[32m/usr/local/php\033[0m"
echo -e "Pureftpd dir:                  \033[32m/usr/local/pureftpd\033[0m"
echo -e "Pureftp_php_manager dir:       \033[32m/data/admin\033[0m"
echo -e "MySQL Password:                \033[32m${mysqlrootpwd}\033[0m"
echo -e "Pureftp_manager url:           \033[32mhttp://$IP/ftp\033[0m"
echo -e "Pureftp_manager Password:      \033[32m${ftpmanagerpwd}\033[0m"
echo "###################################################"
