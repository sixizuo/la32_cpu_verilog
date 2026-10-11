`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/23 11:16:05
// Design Name: 
// Module Name: ALU
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


module ALU(src1,src2,res,ctr,zero);
input signed [31:0] src1,src2;//符号数输入
input [2:0] ctr;
output reg signed [31:0] res;//符号数输出
output zero;
assign zero = (res==32'd0)?1'b1:1'b0;
always@(ctr,src1,src2)
    case(ctr)
    3'b000: res = src1+src2;
    3'b001: res = src1-src2;
    3'b010: res = src1&src2;
    3'b011: res = src1|src2;
    3'b100: res = (src1<src2)?32'd1:32'd0;
    default: res = 32'd0;
    endcase 
endmodule
