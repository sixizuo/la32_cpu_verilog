@echo off
chcp 65001 > nul
echo ========================================
echo    Verilog 一键仿真脚本
echo ========================================

REM 调用编译脚本
call compile.bat
if %ERRORLEVEL% neq 0 exit /b 1

echo.
echo ========================================
echo    开始仿真
echo ========================================

REM 调用仿真脚本
call run.bat