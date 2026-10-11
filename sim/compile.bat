@echo off
chcp 65001 > nul
echo ========================================
echo     Verilog 编译脚本
echo ========================================

REM 设置路径
SET SRC_PATH=..\src
SET OUTPUT_PATH=..\build

REM 检查输出目录是否存在
if not exist "%OUTPUT_PATH%" mkdir "%OUTPUT_PATH%"

echo.
echo 正在编译文件...
echo.

REM 编译命令
REM -o 指定输出文件
REM -s 指定顶层模块
REM -I 包含目录
REM -g2012 支持SystemVerilog特性
REM -Wall display all warning signals

iverilog ^
  -o "%OUTPUT_PATH%\sim.vvp" ^
  -s cpu_sim ^
  -I "%SRC_PATH%" ^
  -g2012 ^
  -Wall ^
  -DSIMULATION ^
  "%SRC_PATH%\cpu_top.v" ^
  "%SRC_PATH%\adder.v" ^
  "%SRC_PATH%\ALU.v" ^
  "%SRC_PATH%\aluctr.v" ^
  "%SRC_PATH%\controller.v" ^
  "%SRC_PATH%\mainctr.v" ^
  "%SRC_PATH%\mux.v" ^
  "%SRC_PATH%\RAM.v" ^
  "%SRC_PATH%\PC.v" ^
  "%SRC_PATH%\ROM.v" ^
  "%SRC_PATH%\ShiftLeft_2b.v" ^
  "%SRC_PATH%\SignExtend.v" ^
  "%SRC_PATH%\GR_REG_File.v" ^
  "%SRC_PATH%\wrctr.v" ^
  "cpu_sim.v"

REM 检查编译结果
if %ERRORLEVEL% equ 0 (
    echo.
    echo [✓] 编译成功！输出文件: %OUTPUT_PATH%\sim.vvp
) else (
    echo.
    echo [✗] 编译失败！
    pause
    exit /b 1
)

echo.
echo 按任意键继续...
pause > nul