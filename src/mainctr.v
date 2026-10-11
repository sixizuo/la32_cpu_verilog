`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/23 11:23:14
// Design Name: 
// Module Name: mainctr
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


module mainctr(opcode,b,beq,mem2reg,srcI12,srcRd,ALUOp);
input [5:0] opcode;
output reg [1:0] ALUOp;
output reg b,beq,mem2reg,srcI12,srcRd;
always @(opcode)
case(opcode)
    6'b000000:{b,beq,mem2reg,srcI12,srcRd,ALUOp}=7'b0000010;
    6'b001010:{b,beq,mem2reg,srcI12,srcRd,ALUOp}=7'b0011000;
    6'b010110:{b,beq,mem2reg,srcI12,srcRd,ALUOp}=7'b01x0101;
    6'b010100:{b,beq,mem2reg,srcI12,srcRd,ALUOp}=7'b1xxxx01;
    default: {b,beq,mem2reg,srcI12,srcRd,ALUOp}= 7'b00xxx01;
   endcase
endmodule
