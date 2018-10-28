#!/bin/bash

# Credential Variable
MYSQL_PASS='root'
PHPMYADMIN_PASS='root'
RABBITMQ_PASS='root'

# Config File
php_config_file='/etc/php/7.2/apache2/php.ini'
xdebug_config_file='/etc/php/7.2/mods-available/xdebug.ini'
mysql_config_file='/etc/mysql/my.cnf'
mailcatcher_config_file='/etc/systemd/system/mailcatcher.service'

IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')
sed -i "s/^${IPADDR}.*//" hosts
echo $IPADDR ubuntu.localhost >> /etc/hosts			# Just to quiet down some error messages

# Update the server
sudo apt-get -y update
sudo apt-get -y upgrade

# Install basic tools
sudo apt-get -y install build-essential binutils-doc git

# Install Apache
sudo apt-get -y install apache2

#Enable apache mod rewrite
a2enmod rewrite
sed -ie '\#<Directory /var/www/>#, \#</Directory># s/AllowOverride None/AllowOverride All/i' /etc/apache2/apache2.conf

# Configure firewall
sudo ufw allow OpenSSH
sudo ufw allow in "Apache Full"

# Install Php
sudo apt-get -y install php libapache2-mod-php php-curl php-mysql php-sqlite3 php-xdebug php-bcmath

# Configure Php
sed -i "s/display_startup_errors = Off/display_startup_errors = On/g" $php_config_file
sed -i "s/display_errors = Off/display_errors = On/g" $php_config_file

# Configure Xdebug
echo "xdebug.remote_enable=1" >> $xdebug_config_file
echo "xdebug.remote_connect_back=1" >> $xdebug_config_file
echo "xdebug.profiler_enable_trigger=1" >> $xdebug_config_file
echo "xdebug.profiler_output_dir=\"/vagrant/cachegrind\"" >> $xdebug_config_file
echo "xdebug.profiler_output_name=\"cachegrind.out.%H.%t\"" >> $xdebug_config_file

# Configure MySql -- need to configure before installing mysql and phpmyadmin
echo "mysql-server mysql-server/root_password password $MYSQL_PASS" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $MYSQL_PASS" | debconf-set-selections

# Configure PhpMyadmin -- need to configure before installing mysql and phpmyadmin
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_PASS" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_PASS" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $PHPMYADMIN_PASS" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections

# Install MySQL
sudo apt-get -y install mysql-client mysql-server 

# Make Mysql daemon accessible through any host
sed -i "s/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" $mysql_config_file

# Allow root access from any host
echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION" | mysql -u root --password=$MYSQL_PASS
echo "GRANT PROXY ON ''@'' TO 'root'@'%' WITH GRANT OPTION" | mysql -u root --password=$MYSQL_PASS

# Restart MySql
sudo service mysql restart

# Install PhpMyadmin
sudo apt-get -y install phpmyadmin php-mbstring php-gettext
sudo phpenmod mbstring

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install Mailcatcher Dependencies (sqlite, ruby)
sudo apt-get install -y libsqlite3-dev ruby-dev

# Install Mailcatcher as a Ruby gem
sudo gem install mailcatcher

# Create Mailcatcher upstart
cat > $mailcatcher_config_file << EOL
[Unit]
Description=Mailcatcher Service
After=network.service vagrant.mount
[Service]
Type=simple
ExecStart=/usr/local/bin/mailcatcher --foreground --ip 0.0.0.0
Restart=always
[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable mailcatcher.service #Start mailcatcher during machine boot

# Enable Mailcatcher with php
echo "sendmail_path = /usr/bin/env $(which catchmail) -f webmaster@localhost" >> /etc/php/7.2/mods-available/mailcatcher.ini
phpenmod mailcatcher

# Install Earlang
wget -O- https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | sudo apt-key add -
echo "deb https://packages.erlang-solutions.com/ubuntu bionic contrib" | sudo tee /etc/apt/sources.list.d/rabbitmq.list
sudo apt-get update
sudo apt-get -y install erlang

# Intall RabbitMq
wget -O- https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc | sudo apt-key add -
wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -
echo "deb https://dl.bintray.com/rabbitmq/debian $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/rabbitmq.list
sudo apt-get update
sudo apt-get -y install rabbitmq-server
sudo systemctl enable rabbitmq-server
sudo rabbitmq-plugins enable rabbitmq_management
sudo rabbitmqctl add_user root $RABBITMQ_PASS
sudo rabbitmqctl set_user_tags root administrator

# Install Supervisor
sudo apt-get install -y supervisor

# Start service
sudo systemctl restart apache2
sudo systemctl restart mysql
sudo systemctl start mailcatcher
sudo systemctl restart rabbitmq-server