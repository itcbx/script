#!/bin/bash

# install nginx+mysql+php on mac.

# test if brew exits.

if ! hash brew $1 2>&-; then
    echo "Install brew."
    ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)"
    if ! hash brew $1 2>&-; then
        echo "Install brew fail."
        exit 1
    else
        echo "Install brew success."
    fi
fi

# add more Github repos
brew tap josegonzalez/homebrew-php
brew tap homebrew/dupes
# brew update

echo "Install nginx."
brew install nginx
if brew info nginx | grep "Not installed" >&-; then
    echo "nginx install fail."
    echo "you may run 'xcode-select --install' first."
    exit 1
fi

echo "Install php56."
brew install php56 --without-apache --with-imap --with-debug --with-fpm
if brew info php56 | grep "Not installed" >&-; then
    echo "php56 install fail."
    echo "you may run 'xcode-select --install' first."
    exit 1
fi

echo "Install php56-mcrypt"
brew install php56-mcrypt
if brew info php56-mcrypt | grep "Not installed" >&-; then
    echo "php56-mcrypt install fail."
    echo "you may run 'xcode-select --install' first."
    exit 1
fi

echo "Install mysql."
brew install mysql
if brew info mysql | grep "Not installed" >&-; then
    echo "mysql install fail."
    echo "you may run 'xcode-select --install' first."
    exit 1
fi

echo "Install phpmyadmin."
brew install phpmyadmin
if brew info phpmyadmin | grep "Not installed" >&-; then
    echo "phpmyadmin install fail, but you can still use mnmp."
fi

# Configure.
if [ ! -d "/usr/local/etc/nginx/conf.d/" ]; then
    mkdir /usr/local/etc/nginx/conf.d/
fi
if [ ! -d "/usr/local/etc/nginx/sites-enabled/" ]; then
    mkdir /usr/local/etc/nginx/sites-enabled/
fi
if [ ! -d "/usr/local/etc/nginx/sites-available/" ]; then
    mkdir /usr/local/etc/nginx/sites-available/
fi

cat>/usr/local/etc/nginx/nginx.conf<<EOF
#user nobody;
worker_processes 1;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {

    ##
    # Basic Settings
    ##

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    include mime.types;
    default_type application/octet-stream;

    ##
    # Logging Settings
    ##

    access_log /usr/local/var/log/nginx/access.log;
    error_log /usr/local/var/log/nginx/error.log;

    ##
    # Gzip Settings
    ##

    gzip on;
    gzip_disable "msie6";

    ##
    # Virtual Host Configs
    ##

    include /usr/local/etc/nginx/conf.d/*.conf;
    include /usr/local/etc/nginx/sites-enabled/*;
}
EOF


cat>/usr/local/etc/nginx/sites-available/default<<EOF
server {
        listen 80;
        root /usr/local/var/www;
        index index.html index.htm index.php;
        server_name localhost;
             
        location ~ \.php$ {
                fastcgi_split_path_info ^(.+.php)(/.+)$;
                fastcgi_pass 127.0.0.1:9000;
                fastcgi_index index.php;
                #fastcgi_param  SCRIPT_FILENAME  /usr/local/var/www$fastcgi_script_name;
                include fastcgi_params;
                include fastcgi.conf; 
        }

} 
EOF
ln -sfv /usr/local/share/phpmyadmin /usr/local/var/www 
ln -sfv /usr/local/etc/nginx/sites-available/default /usr/local/etc/nginx/sites-enabled/default
echo "Inorder to lanuch nginx with port 80, you must change the owner of nginx."
sudo chown root:wheel /usr/local/bin/nginx
sudo chmod u+s /usr/local/bin/nginx

mysql_secure_installation

read -p "Do you want to have launchd start nginx at login [YyNn]?" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ln -sfv /usr/local/opt/nginx/*.plist ~/Library/LaunchAgents
    echo "Nginx will start at login."
fi

read -p "Do you want to have launchd start mysql at login [YyNn]?" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents
    echo "mysql will start at login."
fi

read -p "Do you want to have launchd start php56 at login [YyNn]?" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ln -sfv /usr/local/opt/php56/*.plist ~/Library/LaunchAgents
    echo "php56 will start at login."
fi
echo "mnmp install success."
