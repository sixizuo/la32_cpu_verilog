# ============================================================================
#  create_la32_project.tcl
#  ---------------------------------------------------------------------------
#  用途：在「只拿到 src / sim / coe 三个子目录 + cpu_sim_behav.wcfg」的情况下，
#        一键重建 LA32_Simple_Instr_Set 这个 Vivado 工程，并把行为仿真用的
#        波形配置文件（wavecfg）自动挂载到工程中。
#
#  目录约定（本脚本所在目录 = SRC_ROOT）：
#     <SRC_ROOT>/
#        |-- src/                     14 个 RTL 源文件（设计顶层 cpu_top）
#        |-- sim/                     cpu_sim.v 仿真顶层（其余 *.bat 会被自动忽略）
#        |-- coe/                     指令存储器初始化文件（loongarch1_mine.txt 等）
#        |-- cpu_sim_behav.wcfg       仿真波形配置文件
#        `-- create_la32_project.tcl  <-- 本脚本
#
#  用法：
#     (1) 命令行（推荐）—— 双击同目录下的 create_la32_project.bat，
#         或先 cd 到 <SRC_ROOT> 再执行：
#           vivado -mode batch -source create_la32_project.tcl
#     (2) Vivado GUI —— 打开 Tcl Console，执行：
#           cd <SRC_ROOT>
#           source create_la32_project.tcl
#
#  重要说明（工程目录位置不能乱放）：
#     sim/cpu_sim.v 中用的是相对路径
#         $readmemh("../../../../coe/loongarch1_mine.txt", ...)
#     XSim 的仿真工作目录固定为
#         <工程根>/<工程名>.sim/sim_1/behav/xsim
#     向上退 4 级正好回到 <工程根>，所以 coe/ 必须位于工程根目录下。
#     默认把工程建在 SRC_ROOT（也就是 src/sim/coe 的同级），路径天然成立；
#     若把 PROJ_DIR 指到别处，脚本会自动把 coe/ 复制过去。
#
#  已实测（Vivado 2025.2, Windows）：
#     * 生成的 .xpr 与参考工程一致：part/顶层/文件集/仿真设置/波形配置均相同
#     * 行为仿真脚本中会带上  -view .../cpu_sim_behav.wcfg
#     * 仿真能编译全部 14 个 RTL 文件 + cpu_sim.v，并成功 build snapshot
# ============================================================================

proc msg  {m} { puts "\[LA32\] $m" }
proc warn {m} { puts "\[LA32\]\[WARN \] $m" }
proc err  {m} { puts "\[LA32\]\[ERROR\] $m" }

# ---------------------------------------------------------------------------
# 1. 可配置参数
# ---------------------------------------------------------------------------
set PROJ_NAME   "LA32_Simple_Instr_Set"   ;# 工程名，决定 .xpr/.sim/.cache 的名字
set PART        "xc7a200tfbg484-1"        ;# 目标器件，与原工程一致
set TOP_MODULE  "cpu_top"                 ;# 综合（设计）顶层
set SIM_TOP     "cpu_sim"                 ;# 仿真顶层（testbench）
set SIM_RUNTIME "1000ns"                  ;# 行为仿真运行时长
set RUN_SIM     0                         ;# 置 1 = 建完工程立刻跑一次行为仿真

# ---------------------------------------------------------------------------
# 2. 定位源文件根目录（含 src / sim / coe 的目录）
# ---------------------------------------------------------------------------
set SRC_ROOT ""
catch {
    set _d [file normalize [file dirname [info script]]]
    if {[file isdirectory [file join $_d src]]} { set SRC_ROOT $_d }
}
if {$SRC_ROOT eq "" && [file isdirectory [file join [pwd] src]]} {
    set SRC_ROOT [file normalize [pwd]]
}
if {$SRC_ROOT eq ""} {
    err "找不到 src/ 目录。请把本脚本放在与 src、sim、coe 同级的目录下再运行。"
    error "SRC_ROOT not found"
}
set PROJ_DIR $SRC_ROOT
msg "源文件根目录 : $SRC_ROOT"
msg "工程存放目录 : $PROJ_DIR"

# ---------------------------------------------------------------------------
# 3. 前置检查：三个子目录 + 波形文件
# ---------------------------------------------------------------------------
foreach d {src sim coe} {
    if {![file isdirectory [file join $SRC_ROOT $d]]} {
        err "缺少目录: [file join $SRC_ROOT $d]"
        error "missing directory: $d"
    }
}

# --- 设计源文件（src/*.v / *.sv / *.vh，不递归子目录） ---
set DESIGN_SRCS [lsort [glob -nocomplain -directory [file join $SRC_ROOT src] -type f *.v *.sv *.vh]]
if {[llength $DESIGN_SRCS] == 0} {
    err "src/ 下没有找到 HDL 源文件。"
    error "no design source found"
}

# --- 仿真源文件（sim/*.v，自动跳过 compile.bat / run.bat 等） ---
set SIM_SRCS [lsort [glob -nocomplain -directory [file join $SRC_ROOT sim] -type f *.v *.sv]]
if {[llength $SIM_SRCS] == 0} {
    err "sim/ 下没有找到仿真源文件。"
    error "no simulation source found"
}

# --- 波形配置文件：优先 <SRC_ROOT>/cpu_sim_behav.wcfg，其次 sim/ 下，最后取任意 *.wcfg ---
set WCFG_FILE ""
foreach c [list [file join $SRC_ROOT cpu_sim_behav.wcfg] \
                [file join $SRC_ROOT sim cpu_sim_behav.wcfg]] {
    if {[file exists $c]} { set WCFG_FILE [file normalize $c] ; break }
}
if {$WCFG_FILE eq ""} {
    set _any [lsort [concat [glob -nocomplain -directory $SRC_ROOT *.wcfg] \
                             [glob -nocomplain -directory [file join $SRC_ROOT sim] *.wcfg]]]
    if {[llength $_any] > 0} { set WCFG_FILE [lindex $_any 0] }
}
if {$WCFG_FILE eq ""} {
    warn "没有找到 *.wcfg 波形配置文件，工程将不挂载仿真波形。"
} else {
    msg "波形配置文件 : $WCFG_FILE"
}

# ---------------------------------------------------------------------------
# 4. 创建工程
# ---------------------------------------------------------------------------
# 若已打开同名工程，先关掉，保证脚本可重复执行
set _cur [current_project -quiet]
if {[string length $_cur] != 0} {
    if {[get_property NAME $_cur] eq $PROJ_NAME} {
        msg "关闭已打开的工程 $PROJ_NAME ..."
        close_project
    } else {
        err "当前已打开工程 [get_property NAME $_cur]，请先执行 close_project 再运行本脚本。"
        error "another project is open"
    }
}

msg "创建工程 $PROJ_NAME (part = $PART) ..."
create_project -force $PROJ_NAME $PROJ_DIR -part $PART

set_property target_language  Verilog        [current_project]
set_property target_simulator XSim           [current_project]
set_property default_lib      xil_defaultlib [current_project]

# 关键：改用「手动编译顺序」模式。
# Vivado 默认的自动层次更新模式依赖 GUI 的层次解析，在 -mode batch 下解析不出来，
# 会导致仿真时文件清单为空（compile.bat 里连 xvlog 都没有，报
# "Cannot find design unit xil_defaultlib.cpu_sim"）。改成手动模式后编译顺序按
# 文件加入顺序生成，稳定可靠；综合、仿真、GUI 使用都不受影响。
set_property source_mgmt_mode None [current_project]

# 与参考工程一致的仿真显示设置（波形数据按 hex 显示、时间单位 ns）
catch { set_property XSIM.RADIX              hex   [current_project] }
catch { set_property XSIM.TIME_UNIT          ns    [current_project] }
catch { set_property XSIM.ARRAY_DISPLAY_LIMIT 1024 [current_project] }
catch { set_property XSIM.TRACE_LIMIT         65536 [current_project] }

# 工程目录与源目录不一致时，把 coe/ 复制到工程根，保证 $readmemh 相对路径可用
if {[file normalize $PROJ_DIR] ne [file normalize $SRC_ROOT]} {
    set _dst [file join $PROJ_DIR coe]
    if {![file isdirectory $_dst]} {
        msg "工程目录与源目录不同，复制 coe/ 到工程根 ..."
        file copy [file join $SRC_ROOT coe] $_dst
    }
}

# ---------------------------------------------------------------------------
# 5. 设计源文件 -> sources_1
# ---------------------------------------------------------------------------
add_files -fileset sources_1 -norecurse $DESIGN_SRCS

# ---------------------------------------------------------------------------
# 6. 仿真源文件 + 波形配置 -> sim_1
# ---------------------------------------------------------------------------
if {[llength [get_filesets -quiet sim_1]] == 0} {
    create_fileset -simset sim_1
}

add_files -fileset sim_1 -norecurse $SIM_SRCS

# 关键：把 wavecfg 加入 sim_1 文件集。
# 只要 .wcfg 是 sim_1 里的波形配置文件，Vivado 生成仿真脚本时会自动带上
#    xsim <snapshot> -tclbatch cpu_sim.tcl -view <工程根>/cpu_sim_behav.wcfg
# 打开仿真时波形窗口就按这个文件里配置好的 14 个信号显示，无需手工再添加。
if {$WCFG_FILE ne ""} {
    add_files -fileset sim_1 -norecurse $WCFG_FILE
}

# ---------------------------------------------------------------------------
# 7. 生成编译顺序（必须！否则 batch 下仿真会找不到文件），再指定顶层
# ---------------------------------------------------------------------------
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

set_property top $TOP_MODULE [get_filesets sources_1]
set_property top $SIM_TOP    [get_filesets sim_1]
catch { set_property -name {xsim.simulate.runtime} -value $SIM_RUNTIME -objects [get_filesets sim_1] }

# 说明：batch 模式下 update_compile_order 会打印
#   CRITICAL WARNING: [filemgmt 20-730] Could not find a top module in the fileset xxx
# 这是 Vivado 在没有 GUI 时无法校验层次结构导致的（参考工程在 batch 下同样如此），
# 不影响结果 —— 工程里保存的 TopModule 仍是上面显式设定的 cpu_top / cpu_sim。

# ---------------------------------------------------------------------------
# 8. 收尾：校验报告 + 可选立刻仿真
# ---------------------------------------------------------------------------
puts ""
msg "================ 工程创建完成 ================"
msg "工程文件   : [get_property DIRECTORY [current_project]]/[get_property NAME [current_project]].xpr"
msg "器件       : [get_property PART [current_project]]"
msg "设计文件集 : sources_1   top = [get_property top [get_filesets sources_1]]   ([llength [get_files -of_objects [get_filesets sources_1]]] 个文件)"
msg "仿真文件集 : sim_1       top = [get_property top [get_filesets sim_1]]   ([llength [get_files -of_objects [get_filesets sim_1]]] 个文件)"
if {$WCFG_FILE ne ""} { msg "波形配置   : $WCFG_FILE" }

# 仿真实际工作目录：<工程根>/<工程名>.sim/sim_1/behav/xsim
set _rundir [file join $PROJ_DIR "$PROJ_NAME.sim" sim_1 behav xsim]

# --- 校验 cpu_sim.v 里的 $readmemh 相对路径能否解析到真实文件 ---
set _tb ""
foreach f $SIM_SRCS { if {[file tail $f] eq "cpu_sim.v"} { set _tb $f } }
if {$_tb ne ""} {
    set _fh [open $_tb r]
    set _txt [read $_fh]
    close $_fh
    set _refs [regexp -all -inline {readmem[hb][ \t]*\([ \t]*"([^"]+)"} $_txt]
    if {[llength $_refs] == 0} {
        msg "内存初始化 : cpu_sim.v 中未发现 \$readmemh/\$readmemb 调用"
    } else {
        msg "内存初始化路径校验（相对仿真工作目录 $_rundir）："
        foreach {_full _p} $_refs {
            set _rp [file normalize [file join $_rundir $_p]]
            if {[file exists $_rp]} {
                msg "  \[OK  \] $_p  ->  $_rp"
            } else {
                warn "  \[MISS\] $_p  ->  $_rp  文件不存在！仿真时该存储器会被初始化成 x。"
            }
        }
    }
}

puts ""
if {$RUN_SIM} {
    msg "开始行为仿真（首次会编译 XSim 仿真库，请耐心等待）..."
    if {[catch { launch_simulation -mode behavioral } _e]} {
        err "启动仿真失败：$_e"
        msg "提示：若日志里能看到 'Built simulation snapshot cpu_sim_behav'，说明设计本身没问题，"
        msg "      只是批处理方式启动仿真时命令行环境的兼容问题；请直接用 GUI 打开工程跑仿真。"
    } else {
        catch { run all }
        msg "仿真结束，波形数据目录：$_rundir"
    }
} else {
    msg "下一步：打开工程 -> Flow Navigator -> Simulation -> Run Simulation -> Run Behavioral Simulation"
    msg "命令行启动 GUI：vivado \"$PROJ_DIR/$PROJ_NAME.xpr\""
}
