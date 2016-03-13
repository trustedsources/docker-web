#!/bin/bash

set -e


# Copy nginx config from [ezp_base_dir]/doc/nginx
#cp ${BASEDIR}/doc/nginx/etc/nginx/sites-available/mysite.com /etc/nginx/conf.d/ez.conf
#cp -a ${BASEDIR}/doc/nginx/etc/nginx/ez_params.d /etc/nginx/

# Make sure nginx forwards to php5-fpm on tcp port, not unix socket
sed -i "s@  fastcgi_pass unix:/var/run/php5-fpm.sock;@  # fastcgi_pass unix:/var/run/php5-fpm.sock;@" /etc/nginx/conf.d/ez.conf
sed -i "s@  #fastcgi_pass 127.0.0.1:9000;@  fastcgi_pass ${FASTCGI_PASS};@" /etc/nginx/conf.d/ez.conf

if [ -d /var/www/ezpublish ]; then
    VAR_ENVIRONMENT="ENVIRONMENT"
    VAR_HTTP_CACHE="USE_HTTP_CACHE"
    VAR_TRUSTED_PROXIES="TRUSTED_PROXIES"
else
    VAR_ENVIRONMENT="SYMFONY_ENV"
    VAR_HTTP_CACHE="SYMFONY_HTTP_CACHE"
    VAR_TRUSTED_PROXIES="SYMFONY_TRUSTED_PROXIES"
fi

# Setting environment for ezplatform ( dev/prod/behat etc )
sed -i "s@  #fastcgi_param $VAR_ENVIRONMENT dev;@  fastcgi_param $VAR_ENVIRONMENT ${EZ_ENVIRONMENT};@" /etc/nginx/conf.d/ez.conf

# Disable asset rewrite rules if dev env
if [ "$EZ_ENVIRONMENT" == "dev" ]; then
    sed -i "s@  include ez_params.d/ez_prod_rewrite_params;@  # include ez_params.d/ez_prod_rewrite_params;@" /etc/nginx/conf.d/ez.conf
fi

# Update port number and basedir in /etc/nginx/conf.d/ez.conf
sed -i "s@%PORT%@${PORT}@" /etc/nginx/conf.d/ez.conf
sed -i "s@%BASEDIR%@${BASEDIR}@" /etc/nginx/conf.d/ez.conf

echo "fastcgi_read_timeout $FASTCGI_READ_TIMEOUT;" > /etc/nginx/conf.d/fastcgi_read_timeout.conf

if [ "$VARNISH_ENABLED" == "yes" ]; then
    sed -i "s@  #fastcgi_param $VAR_HTTP_CACHE 1;@  fastcgi_param $VAR_HTTP_CACHE 0;@" /etc/nginx/conf.d/ez.conf
    sed -i "s@  #fastcgi_param $VAR_TRUSTED_PROXIES \"%PROXY%\";@  fastcgi_param $VAR_TRUSTED_PROXIES \"${DOCKER0NET}\";@" /etc/nginx/conf.d/ez.conf
fi

exec /usr/sbin/nginx
#while [ 1 ]; do echo -n .; sleep 60; done
#exec /bin/bash
