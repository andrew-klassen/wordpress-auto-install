#!/bin/bash


apt update
add-apt-repository ppa:ondrej/php -y

apt install -y apache2 mysql-server php7.3 php7.3-curl php7.3-gd php7.3-mbstring php7.3-xml php7.3-xmlrpc php7.3-soap php7.3-intl php7.3-zip php7.3-mysql

wordpressuser_password=$(openssl rand -base64 30)

mysql -u root -N -e "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql -u root -N -e "GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost' IDENTIFIED BY '${wordpressuser_password}';"

wget https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz

web_root='/var/www/html'

rm -rf ${web_root}/index.html
cp -R wordpress/* ${web_root}/
mkdir ${web_root}/wp-content/upgrade


echo "<?php" > ${web_root}/wp-config.php

echo '' >> ${web_root}/wp-config.php
echo '' >> ${web_root}/wp-config.php

echo "define( 'DB_NAME', 'wordpress' );" >> ${web_root}/wp-config.php
echo "define( 'DB_USER', 'wordpressuser' );" >> ${web_root}/wp-config.php
echo "define( 'DB_PASSWORD', '${wordpressuser_password}' );" >> ${web_root}/wp-config.php
echo "define('FS_METHOD', 'direct');" >> ${web_root}/wp-config.php
echo "define( 'DB_HOST', 'localhost' );" >> ${web_root}/wp-config.php
echo "define( 'DB_CHARSET', 'utf8' );" >> ${web_root}/wp-config.php
echo "define( 'DB_COLLATE', '' );" >> ${web_root}/wp-config.php

echo '' >> ${web_root}/wp-config.php

curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> ${web_root}/wp-config.php

echo '' >> ${web_root}/wp-config.php

echo "\$table_prefix = 'wp_';" >> ${web_root}/wp-config.php
echo "define( 'WP_DEBUG', false );" >> ${web_root}/wp-config.php

echo '' >> ${web_root}/wp-config.php

echo "if ( ! defined( 'ABSPATH' ) ) {" >> ${web_root}/wp-config.php
echo -e "\tdefine( 'ABSPATH', dirname( __FILE__ ) . '/' );" >> ${web_root}/wp-config.php
echo "}" >> ${web_root}/wp-config.php

echo '' >> ${web_root}/wp-config.php

echo "require_once( ABSPATH . 'wp-settings.php' );" >> ${web_root}/wp-config.php


chown -R www-data:www-data ${web_root}
find ${web_root}/ -type d -exec chmod 750 {} \;
find ${web_root}/ -type f -exec chmod 640 {} \;

a2enmod rewrite

systemctl restart mysql
systemctl restart apache2
