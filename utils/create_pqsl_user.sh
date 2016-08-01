#!/bin/bash

if [[ $# != 1 ]]; then
	echo -e ""
	echo -e "Parametros errados! Utilze:"
	echo -e "${0} <USERNAME>"
	echo -e "Ex.: ${0} dspace_xyz12"
	echo -e ""
	exit 1
fi

username=${1}
 
createuser -h localhost -U postgres --no-superuser --pwprompt ${username}
