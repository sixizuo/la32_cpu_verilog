`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/23 14:17:43
// Design Name: 
// Module Name: SignExtend
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


module SignExtend(in,out);
parameter W = 12;//定义参数，实例化时可修改
input [W-1:0] in;
output [31:0] out;
assign out = {{(32-W){in[W-1]}},in};//扩展符号位
endmodule
