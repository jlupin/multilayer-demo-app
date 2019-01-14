@echo off

SET BIN_PATH=%~dp0
CD /D %BIN_PATH%..\

nginx.exe -s quit