#!/bin/bash

envDir=`dirname $0`
source ${envDir}/env "$0"

${nginxBin} -p ${prefix} -s quit

