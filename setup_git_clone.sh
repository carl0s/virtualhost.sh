#!/bin/sh
#================================================================================
SCRIPT_DIR=${PWD}
WEB_DIR=$HOME"/Documents/nois3/web/"
PRIVATEKEY=$HOME"/.ssh/certs/c"


usage()
{
  cat << __EOT
Usage:
  NOTE: Please ensure you have installed Apache, PHP and MySQL through homebrew.

  setup_git_clone [REPO_URi] [folder.dev] [db_name]

__EOT
  exit 1
}

if [ -z $1 ]; then
  usage
else
  ssh-add -K $PRIVATEKEY
  git clone $1 $WEB_DIR$2

  cd $WEB_DIR$2

  git checkout develop

  composer install

  cd $SCRIPT_DIR
  cp ./templates/htaccess.tpl $WEB_DIR$2/web/.htaccess

  rm -rf ./templates/development.tmp.tpl
  cp ./templates/development.tpl ./templates/development.tmp.tpl

  touch $WEB_DIR$2/.env

  echo "DB_NAME="$3 >> $WEB_DIR$2/.env
  # echo "DB_USER="$3 >> $WEB_DIR$2/.env
  # echo "DB_PASSWORD="$3 >> $WEB_DIR$2/.env
  echo "DB_USER=root" >> $WEB_DIR$2/.env
  echo "DB_PASSWORD=" >> $WEB_DIR$2/.env
  echo "DB_HOST=127.0.0.1" >> $WEB_DIR$2/.env
  echo " " >> $WEB_DIR$2/.env
  echo "WP_ENV=development" >> $WEB_DIR$2/.env
  echo "WP_HOME=http://"$2 >> $WEB_DIR$2/.env
  echo "WP_SITEURL=http://"$2"/wp" >> $WEB_DIR$2/.env
  echo " " >> $WEB_DIR$2/.env


  rm -rf ./templates/salt.tmp.tpl
  touch ./templates/salt.tmp.tpl

  curl -s https://api.wordpress.org/secret-key/1.1/salt  | sed -e "s/^define(\'//" -e "s/\',/=\'/" -e "s/ //g" -e "s/\'//" -e "s/);$//" >> ./templates/salt.tmp.tpl
  cat ./templates/salt.tmp.tpl >> $WEB_DIR$2/.env

  virtualhost $2 $WEB_DIR$2
fi
