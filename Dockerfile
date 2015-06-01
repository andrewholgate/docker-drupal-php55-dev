FROM andrewholgate/drupal-php55:latest
MAINTAINER Andrew Holgate <andrewholgate@yahoo.com>

RUN apt-get update
RUN apt-get -y upgrade

# Install tools for documenting.
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install python-sphinx python-pip doxygen
RUN DEBIAN_FRONTEND=noninteractive pip install sphinx_rtd_theme breathe

# Install XDebug
RUN DEBIAN_FRONTEND=noninteractive pecl install xdebug
COPY xdebug.ini /etc/php5/mods-available/xdebug.ini
RUN ln -s ../../mods-available/xdebug.ini /etc/php5/fpm/conf.d/20-xdebug.ini && \
    ln -s ../../mods-available/xdebug.ini /etc/php5/cli/conf.d/20-xdebug.ini && \
    mkdir /tmp/xdebug && \
    chown www-data:www-data /tmp/xdebug && \
    mkdir /var/log/xdebug && \
    chown www-data:www-data /var/log/xdebug

# Install XHProf
RUN DEBIAN_FRONTEND=noninteractive pecl install -f xhprof
COPY xhprof.ini /etc/php5/mods-available/xhprof.ini
RUN ln -s ../../mods-available/xhprof.ini /etc/php5/fpm/conf.d/20-xhprof.ini
COPY xhprof.conf /etc/apache2/conf.d/xhprof.conf
RUN mkdir /tmp/xhprof && \
    chown www-data:www-data /tmp/xhprof

# Install JRE (needed for some testing tools like sitespeed.io) and libs for PhantomJS.
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install default-jre libfreetype6 libfontconfig

# Front-end dev tools
RUN npm install -g bower

# Turn on PHP error reporting
RUN sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php5/fpm/php.ini && \
    sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php5/cli/php.ini  && \
    sed -ri 's/^error_reporting\s*=.*$/error_reporting = -1/g' /etc/php5/fpm/php.ini && \
    sed -ri 's/^error_reporting\s*=.*$/error_reporting = -1/g' /etc/php5/cli/php.ini && \
    sed -ri 's/^display_startup_errors\s*=\s*Off/display_startup_errors = On/g' /etc/php5/fpm/php.ini && \
    sed -ri 's/^display_startup_errors\s*=\s*Off/display_startup_errors = On/g' /etc/php5/cli/php.ini && \
    sed -ri 's/^track_errors\s*=\s*Off/track_errors = On/g' /etc/php5/fpm/php.ini && \
    sed -ri 's/^track_errors\s*=\s*Off/track_errors = On/g' /etc/php5/cli/php.ini && \
    sed -ri 's/^;xmlrpc_errors\s*=\s*0/xmlrpc_errors = 1/g' /etc/php5/fpm/php.ini && \
    sed -ri 's/^;xmlrpc_errors\s*=\s*0/xmlrpc_errors = 1/g' /etc/php5/cli/php.ini

# Symlink log files.
RUN ln -s /var/log/xdebug/xdebug.log /var/www/log/

# Grant ubuntu user access to sudo with no password.
RUN apt-get -y install sudo && \
    echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    usermod -a -G sudo ubuntu

# Clean-up installation.
RUN DEBIAN_FRONTEND=noninteractive apt-get autoclean && apt-get autoremove

RUN /etc/init.d/apache2 restart

# Expose additional ports for test tools.
EXPOSE 8080 9876 9000

CMD ["/usr/local/bin/run"]
