# About

Dockerised Drupal 6 & 7 development environment using PHP 5.5 on Ubuntu 14.04. This image is the development companion to the [docker-drupal-php55](https://github.com/andrewholgate/docker-drupal-php55) project.

# Included Tools

## Debugging Tools

- [XDebug](http://www.xdebug.org/) - PHP debugging and profiling.
- [XHProf](http://pecl.php.net/package/xhprof) - function-level hierarchical profiler.

## Front-end Tools

- [Bower](http://bower.io/) - front-end package management.
- [Wraith](https://github.com/BBC-News/wraith) - for visual regression testing.
- [PhantomJS](http://phantomjs.org/) - for smoke tests.

## PHP Documentation Tools

- [DoxyGen](http://www.doxygen.org) - generate documentation from annotated PHP code. It is used to generate XML which is then interpreted by Sphinx.
- [Sphinx](http://sphinx-doc.org/) - generate beautiful [Read The Docs](http://docs.readthedocs.org/en/latest/) format using [Breathe](https://breathe.readthedocs.org/) as a bridge to DoxyGen XML output.

# Other
- Java Runtime Environment (JRE) - project dev tools like [sitespeed.io](http://www.sitespeed.io/) need this.

# Installation

## Create Presistant Database data-only container

```bash
# Build database image based off MySQL 5.5
sudo docker run -d --name mysql-drupal-php55-dev mysql:5.5 --entrypoint /bin/echo MySQL data-only container for Drupal Dev MySQL
```

## Build Drupal Base Image

```bash
# Clone Drupal base docker repository
git clone https://github.com/andrewholgate/docker-drupal-php55.git
# Build docker image
cd docker-drupal-php55
sudo docker build --rm=true --tag="drupal-php55" . | tee ./build.log
```

## Build Project Development Image

```bash
# Clone Drupal development docker repository
git clone https://github.com/andrewholgate/docker-drupal-php55-dev.git
cd docker-drupal-php55-dev

# Build docker image
sudo docker build --rm=true --tag="drupal-php55-dev" . | tee ./build.log
```

## Build Project using Docker Compose

```bash
# Customise docker-compose.yml configurations for environment.
cp docker-compose.yml.dist docker-compose.yml
vim docker-compose.yml

# Build docker containers using Docker Composer.
sudo docker-compose build
sudo docker-compose up -d
```

## Host Access

From the host server, add the web container IP address to the hosts file.

```bash
# Add IP address to hosts file.
sudo bash -c "echo $(sudo docker inspect -f '{{ .NetworkSettings.IPAddress }}' \
dockerdrupalphp55dev_drupalphp55devweb_1) \
drupalphp55dev.example.com \
>> /etc/hosts"
```

## Logging into Web Front-end

```bash
# Using the container name of the web frontend.
sudo docker exec -it dockerdrupalphp55dev_drupalphp55devweb_1 su - ubuntu
```
