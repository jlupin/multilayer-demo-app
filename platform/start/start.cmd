@ECHO OFF

TITLE JLupin Platform EE
COLOR 0B
MODE CON: COLS=160 LINES=1500

SET LOG_LEVEL_CMD=%1
CD /d %~dp0
SET CURRENT_PATH=%~dp0

REM Checking whitespaces in JLUPIN_HOME directory
SET CURRENT_PATH_NOWHITE=%CURRENT_PATH: =%

IF NOT "%CURRENT_PATH%" == "%CURRENT_PATH_NOWHITE%" (
	GOTO error_dir
)
SET JLUPIN_HOME=%CURRENT_PATH%..\

REM Temp file
SET TEMP_FILE=%CURRENT_PATH%temp\start_cmd.tmp

REM Checking VERSION file
SET VERSION_FILE=%CURRENT_PATH%..\VERSION

IF NOT exist "%VERSION_FILE%" (
	ECHO %VERSION_FILE% does not exist. Check the environment and run again.
	GOTO error_version
)

FOR /f "delims=" %%x in (%VERSION_FILE%) do (SET VERSION=%%x)

IF "%VERSION%" == "" (
	GOTO error_version
)

REM Checking initial configuration
SET CONFIG_SETENV=%CURRENT_PATH%configuration\setenv
IF NOT exist "%CONFIG_SETENV%" (
  ECHO %CONFIG_SETENV% does not exist. Check the environment and run again.
	GOTO quit
)


SET LOG_LEVEL="INFO"
SET JAVA_OPTS="-Dhttps.protocols=TLSv1.0,TLSv1.1,TLSv1.2 -Xms128M -Xmx256M"
SET DEBUG_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n"
SET DEBUG_PORT=12998
SET JMX_PORT=9010
SET JMX_OPTS="-Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"


FOR /f "delims=" %%x in ('findstr /v "^#" %CONFIG_SETENV%') do (SET "%%x")

IF %JAVA_OPTS% == "" (
	GOTO error_conf
)

IF NOT "%LOG_LEVEL_CMD%" == "" (
	SET LOG_LEVEL=%LOG_LEVEL_CMD%
)

IF %LOG_LEVEL% == "" (
	GOTO error_conf
)

IF %JMX_ENABLED% == "" (
	SET JMX_ENABLED=no
)


SET JAVA_OPTS=%JAVA_OPTS:"=%
SET LOG_LEVEL=%LOG_LEVEL:"=%
SET DEBUG_OPTS=%DEBUG_OPTS:"=%
SET DEBUG_PORT=%DEBUG_PORT:"=%
SET JMX_PORT=%JMX_PORT:"=%
SET JMX_OPTS=%JMX_OPTS:"=%

IF %JMX_ENABLED% == yes (
	SET JMX_OPTS_FINAL=-Dcom.sun.management.jmxremote.port=%JMX_PORT% %JMX_OPTS%
)


IF NOT "%LOG_LEVEL%" == "ERROR" (
	IF NOT "%LOG_LEVEL%" == "WARN" (
		IF NOT "%LOG_LEVEL%" == "INFO" (
			IF NOT "%LOG_LEVEL%" == "DEBUG" (
				GOTO error_conf
			)
		)
	)
)

SET DEBUG_OPTS_FINAL=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=%DEBUG_PORT%


IF NOT "%LOG_LEVEL%" == "DEBUG" (
	SET DEBUG_OPTS_FINAL=
)

IF exist "%JAVA_HOME%" (
	SET JAVA_HOME=%JAVA_HOME:"=%
)

IF NOT exist "%JAVA_HOME%" (
  ECHO JAVA_HOME variable is not set. Set this variable and run again.
	GOTO quit
)

IF NOT exist "%JAVA_HOME%\bin\java.exe" (
	ECHO JAVA_HOME variable is not properly set. Set this variable and run again.
	GOTO quit
)

IF exist "%JAVA_HOME%\bin\java.exe" SET JLUPIN_JAVA_EXE="%JAVA_HOME%\bin\java.exe"

%JLUPIN_JAVA_EXE% -version 2> %TEMP_FILE%

FOR /f "delims=" %%x in ('FINDSTR /C:"Java(TM) SE Runtime Environment (build 9" %TEMP_FILE%') do (SET JAVA9=%%x)

IF NOT "%JAVA9%" == "" (
	SET JAVA_OPTS=%JAVA_OPTS% --add-modules java.xml.bind
)

DEL /F /Q %TEMP_FILE%

SET JLUPIN_CLASSPATH=%CURRENT_PATH%lib\*;%CURRENT_PATH%lib\ext\*

SET JLUPIN_EXE=%JLUPIN_JAVA_EXE% %JAVA_OPTS% %DEBUG_OPTS_FINAL% %JMX_OPTS_FINAL% -cp %JLUPIN_CLASSPATH% com.jlupin.starter.main.init.JLupinMainServerInitializer serverStart main.yml consoleCommandModeOn startApplicationParallelModeOff main_server %LOG_LEVEL%

REM Starting
ECHO '
ECHO '========================================================================='
ECHO '
ECHO JLUPIN PLATFORM
ECHO '
ECHO JAVA_HOME directory is %JAVA_HOME%
ECHO '
ECHO JAVA_OPTS: %JAVA_OPTS%
ECHO '
ECHO CURRENT_PATH: %CURRENT_PATH%
ECHO '
ECHO JLUPIN_CLASSPATH: %JLUPIN_CLASSPATH%
ECHO '
ECHO JVM INFO:
%JLUPIN_JAVA_EXE% -version
ECHO '
ECHO JLUPIN_EXE: %JLUPIN_EXE%
ECHO '
ECHO '========================================================================='
ECHO '


%JLUPIN_EXE%
GOTO quit

:error_conf
ECHO ERROR: Configuration error, examine setenv configuration file against bugs and check script usage (start.cmd [DEBUG|INFO|WARN|ERROR]). Aborting.
GOTO quit

:error_version
ECHO ERROR: Environment error, cannot determine the version of JLupin. Aborting.
GOTO quit

:error_dir
ECHO ERROR: Environment error, home directory for JLupin cannot contain whitespaces. Aborting.
GOTO quit

:quit
