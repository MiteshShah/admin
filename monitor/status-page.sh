#!/bin/bash
# Configure status pages using cachethq


# Configure Variables
# Random characters
DOMAIN=$1
DB_NAME=cachet
DB_USER=cachet
ROOT=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n1)
DB_PASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n1)
APP_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n1)

# Define echo function
# Blue color
function echo_blue()
{
    echo $(tput setaf 4)$@$(tput sgr0)
}
# White color
function echo_white()
{
    echo $(tput setaf 7)$@$(tput sgr0)
}
# Red color
function echo_red()
{
    echo $(tput setaf 1)$@$(tput sgr0)
}

# Capture errors
function error()
{
    echo "[ `date` ] $(tput setaf 1)$@$(tput sgr0)"
    exit $2
}

# Checking permissions
if [[ $EUID -ne 0 ]]; then
    echo_red "Sudo privilege required..."
    exit 100
fi


echo_blue "Updating system packages, please wait..."
yum -y update

echo_blue "Installing required repository, please wait..."
yum -y install epel-release
yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
yum -y install http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm

echo_blue "Installing required packages, please wait..."
yum --enablerepo=remi,remi-php56 install nginx php-fpm php-common php-mcrypt php-mbstring php-apcu php-xml php-pdo php-intl php-mysql php-cli openssl mysql-community-server vim curl git

echo_blue "Start NGINX and MySQL Service, please wait"
systemctl start nginx
systemctl start mysqld

echo_blue "Updating MySQL root user password, please wait... "
mysqladmin -u root password $ROOT \
|| error "Unable to update MySQL root user password, exit status = " $?
echo -e "[client]\nuser=root\npassword=$ROOT" > ~/.my.cnf
mysql -e "flush privileges"

echo_blue "Createing cachet database, please wait..."
mysql -e "create database \`$DB_NAME\`" \
|| error "Unable to create $DB_NAME database, exit status = " $?

# Create MySQL User
mysql -e "create user '$DB_USER'@'localhost' identified by '$DB_PASS'" \
|| error "Unable to create $DB_USER database user, exit status = " $?

# Grant permission
mysql -e "grant all privileges on \`$DB_NAME\`.* to '$DB_USER'@'localhost'" \
|| error "Unable to grant privileges for $DB_USER database user, exit status = " $?
mysql -e "flush privileges"

echo_blue "Installing composer, please wait..."
curl -sS https://getcomposer.org/installer | php -- --install-dir=/bin --filename=composer

echo_blue "Cloning cachet repository, please wait..."
cd /var/www
git clone https://github.com/cachethq/Cachet.git
cd Cachet
echo_blue "Setup cachet environment variables, please wait..."
echo -e "APP_ENV=local
APP_DEBUG=false
APP_URL=$DOMAIN
APP_KEY=$APP_KEY

DB_DRIVER=mysql
DB_HOST=127.0.0.1
DB_DATABASE=cachet
DB_USERNAME=$DB_USER
DB_PASSWORD=$DB_PASS

CACHE_DRIVER=apc
SESSION_DRIVER=apc
QUEUE_DRIVER=database

MAIL_DRIVER=smtp
MAIL_HOST=mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null" > .env

echo_blue "Changing permission, please wait..."
# php-fpm running as apache user
chown -R apache:apache /var/www/Cachet/

echo_blue "Executing: composer install --no-dev -o, please wait..."
composer install --no-dev -o

echo_blue "Running database migrations, please wait..."
php artisan migrate

echo_blue "Setup NGINX configuration for cachet, please wait..."
echo -e "server {
    listen 80;
    server_name ${DOMAIN};

    root /var/www/Cachet/public;
    index index.php;

    location / {
        try_files \$uri /index.php\$is_args\$args;
    }

    location ~ \.php$ {
                include fastcgi_params;
                fastcgi_pass 127.0.0.1:9000;
                fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                fastcgi_index index.php;
                fastcgi_keep_conn on;
    }
}" > /etc/nginx/conf.d/cachet.conf

echo_blue "Restart NGINX and PHP-FPM Service, please wait"
systemctl start nginx
systemctl start php-fpm
