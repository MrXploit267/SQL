#!/bin/bash
set -eou pipefail
IFS=$'\n\t'

# --funcs--

log() {
	echo "[DATA] $* "
}

err() {
	echo "[ERROR] $*" >&2
}

checkCommand() {
	command -v "$1" >/dev/null 2>&1 || {
		err "cmd '$1' not found."
		exit 1
	}
}

#---validate env---

checkCommand mysql_install_db
checkCommand systemctl

if [[ $EUID -ne 0 ]]; then
	err "run as root or with sudo"
	exit 1
fi
#install mysldb, setup user 
mysqlinstall() {
	log "Initializing mariadb data directory......"
	sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

	log "enabling mariadb service...."
	sudo systemctl enable mariadb.service
	sudo systemctl start mariadb.service

	log "running secure install"
	mysql_secure_installation
	
}

#----run----

mysqlinstall
log "install successfull!"



