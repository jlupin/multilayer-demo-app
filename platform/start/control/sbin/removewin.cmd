@ECHO OFF

SET LOG_LEVEL_CMD=%1
CD /d %~dp0
SET CURRENT_PATH=%~dp0

REM Checking whitespaces in JLUPIN_HOME directory
SET CURRENT_PATH_NOWHITE=%CURRENT_PATH: =%

IF NOT "%CURRENT_PATH%" == "%CURRENT_PATH_NOWHITE%" (
	GOTO error_dir
)
SET JLUPIN_HOME=%CURRENT_PATH%..\..\..

REM Checking initial configuration
SET CONFIG_SETENV=%JLUPIN_HOME%\start\configuration\setenv
IF NOT exist "%CONFIG_SETENV%" (
  ECHO %CONFIG_SETENV% does not exist. Check the environment and run again.
	GOTO quit
)

SET SERVICE_NAME="JLupinPlatformService"

FOR /f "delims=" %%x in ('findstr /v "^#" %CONFIG_SETENV%') do (SET "%%x")

IF %JAVA_OPTS% == "" (
	GOTO error_conf
)

%JLUPIN_HOME%\start\control\bin\JLupinPlatformService.exe -remove -serviceName %SERVICE_NAME%

GOTO quit

:error_conf
ECHO ERROR: Configuration error, examine setenv configuration file against bugs and check script usage (start.cmd [DEBUG|INFO|WARN|ERROR]). Aborting.
GOTO quit

:error_dir
ECHO ERROR: Environment error, home directory for JLupin cannot contain whitespaces. Aborting.
GOTO quit

:quit
