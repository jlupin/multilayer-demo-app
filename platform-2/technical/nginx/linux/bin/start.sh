#!/bin/bash

envDir=`dirname $0`
source ${envDir}/env "$0"

[ ! -x  ../../../logs/technical/nginx ] && mkdir -p ../../../logs/technical/nginx

${nginxBin} -p ${prefix} -c ${nginxConf}

