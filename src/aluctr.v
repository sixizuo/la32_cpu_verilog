`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/23 11:37:40
// Design Name: 
// Module Name: aluctr
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


module aluctr(opcode,ALUOp,ctr);
input [3:0] opcode;
input [1:0] ALUOp;
output reg [2:0] ctr;
always @(opcode,ALUOp)
casex({ALUOp,opcode})
6'b00xxxx: ctr = 3'b000;//ld.w,st.w
6'b01xxxx: ctr = 3'b001;//b,beq
6'b100000: ctr = 3'b000;//add.w
6'b100010: ctr = 3'b001;//sub.w
6'b101001: ctr = 3'b010;//and
6'b101010: ctr = 3'b011;//or
6'b100100: ctr = 3'b100;//slt
default: ctr = 3'b001;//b,beq
endcase
endmodule
