`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/23 09:04:30
// Design Name: 
// Module Name: PC
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


module GR_PC(reset_n,clk,next_pc,PC);
    input reset_n,clk;
    input [31:0] next_pc;
    output reg [31:0] PC;
    always @(posedge clk,negedge reset_n)
    begin
    if(~reset_n)
        PC<=32'h1c000000; //复位PC值
     else PC<=next_pc;
    end
endmodule
