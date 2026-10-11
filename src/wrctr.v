`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/23 11:44:57
// Design Name: 
// Module Name: wrctr
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


module wrctr(opcode,ALUOp,regwr,memwr);
input opcode;
input [1:0] ALUOp;
output reg regwr,memwr;
always @(opcode,ALUOp)
casex({ALUOp,opcode})
3'b10x: {regwr,memwr} = 2'b10;//3R
3'b000: {regwr,memwr} = 2'b10;//LD.W
3'b001: {regwr,memwr} = 2'b01;//ST.W
3'b01x: {regwr,memwr} = 2'b00;//beq,b
default: {regwr,memwr} = 2'b00;
endcase
endmodule
