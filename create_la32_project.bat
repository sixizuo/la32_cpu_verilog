@echo off
chcp 65001 > nul
REM ========================================================================
REM  create_la32_project.bat
REM  Double-click to rebuild the Vivado project by running
REM  create_la32_project.tcl in batch mode.
REM  Keep this file in the same folder as:  src\  sim\  coe\  cpu_sim_behav.wcfg
REM  (This file is intentionally ASCII-only: cmd.exe cannot reliably parse a
REM   batch file that contains multi-byte characters.)
REM ========================================================================

setlocal
cd /d "%~dp0"

REM ---- Locate vivado: first from PATH, then from the default install dir.
REM ---- If both fail, edit VIVADO_BIN below manually.
set "VIVADO_BIN="
where vivado >nul 2>&1 && set "VIVADO_BIN=vivado"
if not defined VIVADO_BIN if exist "C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat" set "VIVADO_BIN=C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat"

if not defined VIVADO_BIN (
    echo.
    echo [ERROR] vivado not found. Please edit this file and set VIVADO_BIN
    echo         to the full path of your vivado.bat .
    echo.
    pause
    exit /b 1
)

echo.
echo ==========================================================
echo   Rebuilding Vivado project: LA32_Simple_Instr_Set
echo   Working dir : %CD%
echo   Vivado      : %VIVADO_BIN%
echo ==========================================================
echo.

call "%VIVADO_BIN%" -mode batch -source create_la32_project.tcl -nojournal -log create_project.log

echo.
echo ==========================================================
echo   Done. Full log: create_project.log
echo   Open  LA32_Simple_Instr_Set.xpr  with Vivado, then:
echo     Simulation -^> Run Simulation -^> Run Behavioral Simulation
echo ==========================================================
echo.
pause
endlocal
