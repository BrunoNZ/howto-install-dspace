#!/bin/bash

if [[ $# != 2 ]]; then
	echo -e ""
	echo -e "Parametros errados! Utilze:"
	echo -e "${0} <USERNAME> <DATABASE>"
	echo -e "Ex.: ${0} dspace_xyz12 dspace_xyz12"
	echo -e ""
	exit 1
fi

username=${1}
dbname=${2}

createdb -h localhost -U postgres -O ${username} -E UNICODE ${dbname}
psql -h localhost -U postgres ${dbname} -c "CREATE EXTENSION pgcrypto;"
