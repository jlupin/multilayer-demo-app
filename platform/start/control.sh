#!/bin/bash

# Setting JLUPIN_HOME
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
REL_START_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
cd ${REL_START_DIR}
CURRENT_DIR=`pwd`

# Import setting from setenv
SETENV=${CURRENT_DIR}/control/configuration/setenv
[ -e ${SETENV} ] && source ${SETENV}

# Setting CONTROL_CONFIGURATION_FILE
if [ "${CONFIGURATION_FILE}x" = "x" ];
then
    CONFIGURATION_FILE="${CURRENT_DIR}/control/configuration/control.yml";
fi

# Setting HISTORY_FILE_PATH
if [ "${HISTORY_FILE}x" = "x" ];
then
    HISTORY_FILE="${CURRENT_DIR}/control/data/control.history";
fi

# JAVA_OPTS
JAVA_OPTS="-Dcontrol.working.directory=\"${CURRENT_DIR}/.\" \
           -Dcontrol.configuration.file=\"${CONFIGURATION_FILE}\" \
           -Dcontrol.history.file=\"${HISTORY_FILE}\""

# Checking JAVA_HOME
if [ "${JAVA_HOME}x" = "x" ];
then
    echo "WARNING: JAVA_HOME variable is not set"

    # Trying to find JAVA_HOME
    if [ "`which java 2>/dev/null | grep -v 'alias java'`x" = "x" ];
    then
        echo "ERROR: I haven't found JAVA in the path"
        echo "INFO: If you have installed JDK in your system, please set JAVA_HOME properly (directory where JDK has been installed) or add JAVA bin directory to you PATH"
        echo "INFO: If you haven't installed JDK in your system yet, please visit http://www.oracle.com/technetwork/java/javase/downloads/index.html and follow the given instructions"
        exit
    else
        [ `which java 2>/dev/null | wc -l` -gt 1 ] && echo "ERROR: Something confusing has happend, too many JAVA exec in your PATH. Please set one JAVA environment in your PATH and try again" && Exit

        JAVA_PATH=`which java 2>/dev/null | grep -v 'alias java'`

        if [ `echo ${JAVA_PATH} | grep -Ec "^~"` -lt 0 ];
        then
            JAVA_FULL_PATH="${HOME}`echo ${JAVA_PATH} | sed s/"~"/""/g | sed s/"\/bin\/java"/""/g`"
        else
            JAVA_FULL_PATH="`echo ${JAVA_PATH} | sed s/"\/bin\/java"/""/g`"
        fi

        echo "INFO: Setting JAVA_HOME: ${JAVA_FULL_PATH}"
        CONTROL_JAVA_HOME=${JAVA_FULL_PATH}
    fi
else
    CONTROL_JAVA_HOME=${JAVA_HOME}
fi

# Checking JAVA exec
JLUPIN_JAVA_EXE="${CONTROL_JAVA_HOME}/bin/java"

if [ ! -x "$JLUPIN_JAVA_EXE" ];
then
	echo "ERROR: JAVA exec does not exist or is not executable: $JLUPIN_JAVA_EXE"
	exit
fi

# Checking JAVA version
JAVA9=`${JLUPIN_JAVA_EXE} -version 2>&1 | grep -c 'java version "9.'`
[ $JAVA9 -eq 1 ] && JAVA_OPTS="${JAVA_OPTS} --add-modules java.xml.bind"

# Get command arguments
ARGS=""
for var in "$@"
do
    ARGS="${ARGS} ${var}"
done

eval "${JLUPIN_JAVA_EXE} ${JAVA_OPTS} -cp \"${CURRENT_DIR}/control/lib/*\" com.jlupin.console.runner.impl.ControlConsoleRunner ${ARGS}"
