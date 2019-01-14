#!/bin/bash

## Start & Init Scripts for JLupin Platform
# Version: 1.5.0.1


##### FUNCTIONS #####
function Exit()
{
	ExitParam1=$1

	[ "${ExitParam1}x" != "" ] && echo $ExitParam1

	exit 1
}

function Header()
{
	echo "========================================================================="
	echo ""
	echo "  JLUPIN PLATFORM (log level: ${LOG_LEVEL})"
	echo ""
	echo "  JAVA_HOME: ${JAVA_HOME}"
	echo ""
	echo "  JAVA_OPTS: $JAVA_OPTS"
	echo ""
	echo "  JLUPIN_HOME: ${JLUPIN_HOME}"
	echo ""
	echo "  CLASSPATH_START: ${CLASSPATH_START}"
	echo ""
	echo "  JLUPIN_CLASSPATH: $JLUPIN_CLASSPATH"
	echo ""
	echo "  JAVA VERSION"
	"$JLUPIN_JAVA_EXE" -version
	echo ""
	echo "========================================================================="
	echo ""
	echo ${JLUPIN_EXE}
	echo ""
}


##### SANITY CHECKS & SETUP BEFOR SERVER START #####

LOG_LEVEL_CMD="$1"

# Setting JLUPIN_HOME 
REL_START_DIR=`dirname $0`
cd ${REL_START_DIR}
CURRENT_DIR=`pwd`
cd ..
JLUPIN_HOME=`pwd`
cd ${CURRENT_DIR}

# Default settings
JAVA_OPTS="-Dhttps.protocols=TLSv1.0,TLSv1.1,TLSv1.2 -Xms128M -Xmx256M"
LOG_LEVEL="INFO"
DEBUG_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n"
DEBUG_PORT=12998
JMX_PORT=9010
JMX_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"

# Checking version
VERSION_FILE=${JLUPIN_HOME}/VERSION

[ ! -e ${VERSION_FILE} ] && Exit "ERROR: Environment error, cannot determine the version of JLupin. Aborting."
VERSION=`cat ${VERSION_FILE}`

# Import setting from setenv
SETENV=${JLUPIN_HOME}/start/configuration/setenv

[ -e ${SETENV} ] && source ${SETENV}

[ "${LOG_LEVEL_CMD}x" != "x" ] && LOG_LEVEL=${LOG_LEVEL_CMD}


if [ "${LOG_LEVEL}x" != "" ]
then
	case $LOG_LEVEL in
		"ERROR");;
		"WARN");;
		"INFO");;
		"DEBUG");;
		*) Exit "ERROR: Configuration error, examine setenv configuration file against bugs and check sccript usage (start.sh [DEBUG|INFO|WARN|ERROR]). Aborting.";;
	esac
fi

[ "${JAVA_OPTS}x" = "x" ] && Exit "ERROR: Configuration error, examine setenv configuration file against bugs. Aborting."

if [ "$LOG_LEVEL" = "DEBUG" ]
then
	DEBUG_OPTS_FINAL="${DEBUG_OPTS},address=${DEBUG_PORT}"
else
	DEBUG_OPTS_FINAL=""
fi


# Setting JAVA_HOME
if [ "${JAVA_HOME}x" = "x" ];
then
	# Trying to find JAVA_HOME
	if [ "`which java 2>/dev/null | grep -v 'alias java'`x" = "x" ];
	then
		echo "ERROR: I haven't found JAVA in the path"
		echo "INFO: If you have installed JDK in your system, please set JAVA_HOME properly (directory where JDK has been installed) or add JAVA bin directory to you PATH"
		echo "INFO: If you haven't installed JDK in your system yet, please visit http://www.oracle.com/technetwork/java/javase/downloads/index.html and follow the given instructions"
		Exit
	else
		[ `which java 2>/dev/null | wc -l` -gt 1 ] && echo "ERROR: Something confusing has happend, too many JAVA exec in your PATH. Please set one JAVA environment in your PATH and try again" && Exit
	
		JAVA_PATH=`which java 2>/dev/null | grep -v 'alias java'`

		if [ `echo ${JAVA_PATH} | grep -Ec "^~"` -gt 0 ];
		then
			JAVA_FULL_PATH="${HOME}`echo ${JAVA_PATH} | sed s/"~"/""/g | sed s/"\/bin\/java"/""/g`" 
		else
			JAVA_FULL_PATH="`echo ${JAVA_PATH} | sed s/"\/bin\/java"/""/g`"
		fi

		JAVA_HOME=${JAVA_FULL_PATH}
	fi	

	if [ "${JAVA_HOME}x" = "x" ]
	then
		JAVA_HOME="/"
		JLUPIN_JAVA_EXE="${JAVA_HOME}bin/java"
	else
		JLUPIN_JAVA_EXE="${JAVA_HOME}/bin/java"
	fi
else
	if [ "${JAVA_HOME}" = "/" ]
	then
		JLUPIN_JAVA_EXE="/bin/java"
	else
		JLUPIN_JAVA_EXE="${JAVA_HOME}/bin/java"
	fi
fi


export JAVA_HOME


# Checking JAVA
if [ ! -x "$JLUPIN_JAVA_EXE" ];
then
	Exit "ERROR: JAVA exec does not exist or is not executable: $JLUPIN_JAVA_EXE"
fi

# Checking JAVA version
JAVA9=`$JLUPIN_JAVA_EXE -version 2>&1 | grep -c 'java version "9.'` 
[ $JAVA9 -eq 1 ] && JAVA_OPTS="${JAVA_OPTS} --add-modules java.xml.bind"

# Server out logs
JLUPIN_SERVER_OUT="${JLUPIN_HOME}/${SERVER_OUT}"
JLUPIN_SERVER_OUT_DIR=`dirname ${JLUPIN_SERVER_OUT}`

if [ ! -e ${JLUPIN_SERVER_OUT_DIR} ]
then
        mkdir -p ${JLUPIN_SERVER_OUT_DIR}
        [ $? -ne 0 ] && Exit "Cannot create SERVER_OUT directory (${JLUPIN_SERVER_OUT_DIR}). Aborting"
fi

# JMX Configuration
if [ "${JMX_ENABLED}x" = "yesx" ]
then
	JMX_OPTS_FINAL="-Dcom.sun.management.jmxremote.port=${JMX_PORT} ${JMX_OPTS}"
fi

# Classpath 
JLUPIN_CLASSPATH="${JLUPIN_HOME}/start/lib/*:${JLUPIN_HOME}/start/lib/ext/*"

# Exec line
JLUPIN_EXE="${JLUPIN_JAVA_EXE} ${JAVA_OPTS} ${JMX_OPTS_FINAL} ${DEBUG_OPTS_FINAL} -classpath ${JLUPIN_CLASSPATH} com.jlupin.starter.main.init.JLupinMainServerInitializer serverStart main.yml consoleCommandModeOff startApplicationParallelModeOff main_server $LOG_LEVEL"

##### STARTING JLUPIN PLATFORM #####
Header >>${JLUPIN_SERVER_OUT} 2>&1
nohup ${JLUPIN_EXE} >>${JLUPIN_SERVER_OUT} 2>&1 &
retVal=$?

echo "The start of JLupin Platform has been initialized, see logs for details: ${JLUPIN_HOME}/logs/server/main/start/server.out"

exit $?
