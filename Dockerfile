FROM andrewholgate/drupal-php55:latest
MAINTAINER Andrew Holgate <andrewholgate@yahoo.com>

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

# Install tools for documenting.
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install python-sphinx python-pip doxygen && \
    DEBIAN_FRONTEND=noninteractive pip install sphinx_rtd_theme breathe

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

# Install Node 4.2.1
RUN cd /opt && \
  wget https://nodejs.org/dist/v4.2.1/node-v4.2.1-linux-x64.tar.gz && \
  tar -xzf node-v4.2.1-linux-x64.tar.gz && \
  mv node-v4.2.1-linux-x64 node && \
  cd /usr/local/bin && \
  ln -s /opt/node/bin/* . && \
  rm -f /opt/node-v4.2.1-linux-x64.tar.gz

USER ubuntu
RUN echo 'export PATH="$PATH:$HOME/.npm-packages/bin"' >> ~/.bashrc && \
    npm config set prefix '~/.npm-packages'
USER root

# Setup for Wraith
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install imagemagick && \
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    \curl -sSL https://get.rvm.io | bash -s stable --ruby && \
    /bin/bash -l -c "source /usr/local/rvm/scripts/rvm" && \
    /bin/bash -l -c "rvm default" && \
    /bin/bash -l -c "rvm rubygems current" && \
    /bin/bash -l -c "gem install wraith"

# Front-end tools
RUN npm install -g phantomjs

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
