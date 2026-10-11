`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/23 14:08:02
// Design Name: 
// Module Name: controller
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


module controller(opcode,alu_ctr,regwr,memwr,b,beq,mem2reg,srcI12,srcRd);
input [16:0] opcode;
output [2:0] alu_ctr;
output regwr,memwr,b,beq,mem2reg,srcI12,srcRd;
wire [1:0] ALUOp;
mainctr u_main(opcode[16:11],b,beq,mem2reg,srcI12,srcRd,ALUOp);
wrctr u_wr(opcode[9],ALUOp,regwr,memwr);
aluctr u_alu_ctr(opcode[3:0],ALUOp,alu_ctr);
endmodule
