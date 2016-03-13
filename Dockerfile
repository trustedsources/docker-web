FROM nginx:1.8.1

# Set defaults for variables used by run.sh
# If you change FASTCGI_READ_TIMEOUT, also change max_execution_time accordingly in php-fpm!
ENV PORT=80 \
    BASEDIR=/var/www \
    FASTCGI_READ_TIMEOUT=190


# Remove default config and make sure nginx starts as process for docker
RUN rm /etc/nginx/conf.d/default.conf  && echo "daemon off;" >> /etc/nginx/nginx.conf

ADD sites-available/mysite.com /etc/nginx/conf.d/ez.conf
ADD ez_params.d /etc/nginx/ez_params.d

# Most config will be done on startup by run.sh when we have access to config
ADD run.sh /run.sh
CMD ["/run.sh"]
