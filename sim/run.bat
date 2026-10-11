@echo off
chcp 65001 > nul
echo ========================================
echo     Verilog 仿真脚本
echo ========================================

REM 设置路径
SET OUTPUT_PATH=..\build
SET WAVEFORM=%OUTPUT_PATH%\waveform.vcd


REM 检查编译文件是否存在
if not exist "%OUTPUT_PATH%\sim.vvp" (
    echo 错误: 未找到编译文件 sim.vvp
    echo 请先运行 compile.bat
    pause
    exit /b 1
)

echo.
echo 正在运行仿真...
echo.

REM 运行仿真
vvp "%OUTPUT_PATH%\sim.vvp" -lxt2

if %ERRORLEVEL% equ 0 (
    echo.
    echo [✓] 仿真完成！
    
    REM 检查波形文件
    if exist "%WAVEFORM%" (
        echo 波形文件: %WAVEFORM%
        
        REM 询问是否打开波形
        echo.
        set /p open_wave="是否打开波形查看器？(Y/N): "
        if /i "%open_wave%"=="Y" (
            echo 正在打开GTKWave...
            start "" "gtkwave.exe" "%WAVEFORM%"
        )
    ) else (
        echo 警告: 未生成波形文件
    )
) else (
    echo.
    echo [✗] 仿真失败！
)

echo.
pause