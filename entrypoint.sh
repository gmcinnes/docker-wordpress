#!/bin/bash

# terminate on errors
set -e

# If there is some public key in keys folder
# then it copies its contain in authorized_keys file
if [ "$(ls -A /git-server/keys/)" ]; then
  cd /git-server
  cat /git-server/keys/*.pub > .ssh/authorized_keys
  chown -R git:git .ssh
  chmod 700 .ssh
  chmod -R 600 .ssh/*
fi

if [ ! -d /git-server/repos/project ]; then
  cd /git-server/repos
  mkdir -p project
  cd project
  git init --bare
  cp /usr/src/post-receive hooks
  chmod 755 hooks/post-receive
fi

# Checking permissions and fixing SGID bit in repos folder
# More info: https://github.com/jkarlosb/git-server-docker/issues/1
if [ "$(ls -A /git-server/repos/)" ]; then
  cd /git-server/repos
  chown -R git:git .
  chmod -R ug+rwX .
  find . -type d -exec chmod g+s '{}' +
fi

chown -R nobody.nobody /var/www

# Check if volume is empty
# if [ ! "$(ls -A "/var/www/wp-content" 2>/dev/null)" ]; then
#     echo 'Setting up wp-content volume'
#     # Copy wp-content from Wordpress src to volume
#     cp -r /usr/src/wordpress/wp-content /var/www/
#     chown -R nobody.nobody /var/www
#
#     # Generate secrets
#     curl -f https://api.wordpress.org/secret-key/1.1/salt/ >> /usr/src/wordpress/wp-secrets.php
# fi
exec "$@"
