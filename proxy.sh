#!/bin/bash

#
# Arguments: set or unset
#

_self="${0##*/}"

## or in usage() ##
usage(){
    echo "/.$_self [set|unset]"
}

number_of_arg=$#

if [ $number_of_arg -lt 1 ] 
then
	usage
	exit 1
fi

PROXY=http://172.29.38.124:8080
DOCKER_CONFIG_FILE=~/.docker/config.json

if [ $1 == "set" ] 
then
	# Set environment proxy
	echo "Set proxy to the environment"
	export http_proxy=${PROXY}
	export https_proxy=${PROXY}
	export no_proxy=localhost,127.0.0.1,localaddress,.localdomain.com

	# Set git proxy
	if command -v git &> /dev/null
	then
		echo "Set proxy to git"
		git config --global http.proxy ${PROXY}
		git config --global https.proxy ${PROXY}
	fi

	

	# Set npm proxy
	if command -v npm &> /dev/null
	then
		echo "Set proxy to npm"
		npm config set proxy ${PROXY}
		npm config set https-proxy ${PROXY}
	fi

	
	# Set proxy to docker
	if command -v docker &> /dev/null
	then
		echo "Set proxy to docker. "
		if [ -f "${DOCKER_CONFIG_FILE}" ]; then
			q=`jq . ${DOCKER_CONFIG_FILE}`
			echo $q | jq ". += {\"proxies\":{\"default\":{\"httpProxy\":\"${PROXY}\",\"httpsProxy\":\"${PROXY}\",\"noProxy\":\"localhost,localaddress,.localdomain.com,127.0.0.0/8\"}}}" > ${DOCKER_CONFIG_FILE}
		else
			touch ${DOCKER_CONFIG_FILE}
			jq -n "{\"proxies\":{\"default\":{\"httpProxy\":\"${PROXY}\",\"httpsProxy\":\"${PROXY}\",\"noProxy\":\"localhost,localaddress,.localdomain.com,127.0.0.0/8\"}}}" > ${DOCKER_CONFIG_FILE}
		fi
	fi


elif [ $1 == "unset" ] 
then
	# Unset environment proxy
	echo "Unset proxy from environment"
	export http_proxy=""
	export https_proxy=""
	export no_proxy=""


	# Unset git proxy
	if command -v git &> /dev/null
	then
		echo "Unset proxy from git"
		git config --global --unset https.proxy
		git config --global --unset http.proxy
	fi

	

	# Unset npm proxy
	if command -v npm &> /dev/null
	then
		echo "Unset proxy from npm"
		npm config delete proxy
		npm config delete https-proxy
	fi
	

	# Unset docker proxy
	if command -v docker &> /dev/null
	then
		# Unset proxy from docker
		echo "Unset proxy from docker"
		echo $(cat ${DOCKER_CONFIG_FILE} | jq 'del(.proxies)') > ${DOCKER_CONFIG_FILE}
	fi
	
	
else
	usage
fi

 

