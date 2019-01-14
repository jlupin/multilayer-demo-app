@echo off
TITLE JLupin Platform Console
COLOR 0B
MODE CON: COLS=160 LINES=1500


REM Setting current path
CD /d %~dp0
SET CURRENT_PATH=%~dp0
REM Checking whitespaces in JLUPIN_HOME directory
SET CURRENT_PATH_NOWHITE=%CURRENT_PATH: =%
IF NOT "%CURRENT_PATH%" == "%CURRENT_PATH_NOWHITE%" (
	GOTO error_dir
)

REM Temp file
SET TEMP_FILE=%CURRENT_PATH%control\temp\control_cmd.tmp

REM Checking initial configuration
SET CONFIG_SETENV=%CURRENT_PATH%control\configuration\setenv
IF NOT EXIST "%CONFIG_SETENV%" (
    ECHO %CONFIG_SETENV% does not exist. Check the environment and run again.
	GOTO quit
)

REM Setting CONTROL_CONFIGURATION_FILE
SET CONTROL_CONFIGURATION_FILE="%CURRENT_PATH%control\configuration\control.yml"
REM Setting HISTORY_FILE_PATH
SET CONTROL_HISTORY_FILE="%CURRENT_PATH%control\data\control.history"

REM Set variables
FOR /f "delims=" %%x in ('findstr /v "^#" %CONFIG_SETENV%') do (SET "%%x")

IF EXIST "%JAVA_HOME%" (
    SET JAVA_HOME=%JAVA_HOME:"=%
)

REM Set JAVA home
IF NOT EXIST "%JAVA_HOME%" (
    ECHO JAVA_HOME variable is not set. set this variable and run again
    GOTO quit
) ELSE (
    SET CONTROL_JAVA_HOME=%JAVA_HOME%
)

IF NOT EXIST "%CONTROL_JAVA_HOME%\bin\java.exe" (
    ECHO JAVA_HOME variable is not properly set. Set this variable and run again
	GOTO quit
)

IF EXIST "%CONTROL_JAVA_HOME%\bin\java.exe" SET JLUPIN_JAVA_EXE=%CONTROL_JAVA_HOME%\bin\java.exe

SET JAVA_OPTS=-Dcontrol.working.directory="%CURRENT_PATH%." ^
              -Dcontrol.configuration.file="%CONTROL_CONFIGURATION_FILE%" ^
              -Dcontrol.history.file="%CONTROL_HISTORY_FILE%"

REM Check if JAVA 9 and customize command
%JLUPIN_JAVA_EXE% -version 2> %TEMP_FILE%
FOR /f "delims=" %%x in ('FINDSTR /C:"Java(TM) SE Runtime Environment (build 9" %TEMP_FILE%') do (SET JAVA9=%%x)
IF NOT "%JAVA9%" == "" (
	SET JAVA_OPTS=%JAVA_OPTS% --add-modules java.xml.bind
)
DEL /F /Q %TEMP_FILE%

SET ARGS=
:loop
IF "%1"=="" GOTO continue
SET ARGS=%ARGS% %1
SHIFT
GOTO Loop
:continue

"%JLUPIN_JAVA_EXE%" %JAVA_OPTS% -cp "%CURRENT_PATH%control\lib\*" com.jlupin.console.runner.impl.ControlConsoleRunner %ARGS%
GOTO quit

:error_dir
ECHO ERROR: Environment error, home directory for JLupin cannot contain whitespaces. Aborting.
GOTO quit

:quit