#!/usr/bin/env bash

echo "Installation Magento vHost on nginx (with xdebug) and SSL enabled"
block='server {
    listen 88;
    listen 443 ssl;

    server_name MagentoWithXdebug;
    
    root "/home/vagrant/Code";

    ssl_certificate /vagrant/ssl/mkg.cert;
    ssl_certificate_key /vagrant/ssl/mkg.key;

    #charset utf-8;

    location ~ ^/(app/|includes/|pkginfo/|var/|errors/local.xml|lib/|media/downloadable/) { deny all; }
    location ~ /\. { deny all; }
    location / {
        index  index.php index.html index.htm;
        try_files $uri $uri/ @rewrite;
    }

    location @rewrite {
        rewrite ^(/[a-zA-z0-9]+/)(.*) $1/index.php/$2;
    }

    location ~ \.php/ { ## Forward paths like /js/index.php/x.js to relevant handler
        rewrite ^(.*.php)/ $1;
    }

    #location = /favicon.ico { access_log off; log_not_found off; }
    #location = /robots.txt  { access_log off; log_not_found off; }

    #access_log off;
    #error_log  /var/log/nginx/homestead.app-error.log error;

    #sendfile off;

    #client_max_body_size 100m;

    location ~ \.php$ {
        if (!-e $request_filename) {
            rewrite / /index.php last;
        }
        fastcgi_split_path_info ^(.+\.php)(.*)$;
        fastcgi_pass  unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_script_name;
        try_files $uri =404;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}
'

echo "$block" > "/etc/nginx/sites-available/xdebugMagentoVHost"
ln -fs "/etc/nginx/sites-available/xdebugMagentoVHost" "/etc/nginx/sites-enabled/xdebugMagentoVHost"
service nginx restart
service php5-fpm restart
