`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/23 09:44:05
// Design Name: 
// Module Name: RAM
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


module RAM(clk,data_in,data_out,addr,wr,cs_n,reset_n);
input clk,wr,cs_n,reset_n;
input [31:0] data_in;
input [5:0] addr;
output [31:0] data_out;
reg [31:0] data [63:0];
assign data_out = ~cs_n?data[addr]:32'hzzzzzzzz;//选中时输出相应地址子数据
integer i;
always @(posedge clk,negedge reset_n)
begin
if(~reset_n)
    for(i=0;i<64;i=i+1)
        data[i]<=0;//复位时各个存储字值为0
 else if(wr&~cs_n)
    data[addr] <= data_in;//选中且写信号有效，写入数据
end
endmodule
