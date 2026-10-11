`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/23 15:53:07
// Design Name: 
// Module Name: cpu_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cpu_sim();
reg clk,reset_n;
cpu_top u_cpu(clk,reset_n);//实例化顶层模块
//初始化指令存储器
initial 
 $readmemh ("../../../../coe/loongarch1_mine.txt", u_cpu.u_instr_rom.instructions, 0, 10);
//设置时钟
always
    begin
    #5 clk=0;
    #5 clk=1;
    end
//设置复位信号
initial
    begin
    reset_n=0;
    #12 reset_n=1;
    u_cpu.u_reg_file.GR_data[14]=32'h10010000;
    u_cpu.u_reg_file.GR_data[15]=32'h10008000;
    u_cpu.u_data_ram.data[0]=32'h5555aaaa;
    # 120 $finish;//仿真时间设置为100个时间单位
    end

//输出部分信号到控制台
initial begin
$monitor("PC=%x Instr=%x $a0=%x $a1=%x $a2=%x \n \
	    $a3=%x $a4=%x $a5=%x DataRAM[0]=%x DataRAM[1]=%x\n",
    u_cpu.PC,u_cpu.instr,u_cpu.u_reg_file.GR_data[4],
    u_cpu.u_reg_file.GR_data[5],u_cpu.u_reg_file.GR_data[6],
    u_cpu.u_reg_file.GR_data[7],u_cpu.u_reg_file.GR_data[8],
    u_cpu.u_reg_file.GR_data[9], u_cpu.u_data_ram.data[0],
    u_cpu.u_data_ram.data[1]);
end
 
endmodule
