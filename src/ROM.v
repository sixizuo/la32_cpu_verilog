`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/23 09:28:21
// Design Name: 
// Module Name: ROM
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


module ROM(addr,instr,cs_n);
input [5:0] addr;
output [31:0] instr;
input cs_n;
reg [31:0] instructions [63:0];//寄存器方式实现的存储器
assign  instr = cs_n?32'hzzzzzzzz:instructions[addr];//选中时输出对应指令，否则高阻
endmodule
