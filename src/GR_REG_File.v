`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/23 09:52:33
// Design Name: 
// Module Name: GR_REG_File
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


module GR_REG_File(clk,rd_data_in,rd_data_out,rd_addr,rj_addr,rk_addr,
                    rj_data,rk_data,wr,reset_n);
input clk,wr,reset_n;
input [31:0] rd_data_in;
input [4:0] rd_addr,rj_addr,rk_addr;
output [31:0] rd_data_out,rj_data,rk_data;
reg [31:0] GR_data [31:0];//32个通用寄存器堆
assign rd_data_out = GR_data[rd_addr];
assign rj_data = GR_data[rj_addr];
assign rk_data = GR_data[rk_addr];
integer i;
always @(posedge clk,negedge reset_n)
begin
if(~reset_n)
    for(i=0;i<32;i=i+1)
        GR_data[i]<=0;//复位时各个寄存器值为0
 else if(wr)
    GR_data[rd_addr] <= (rd_addr==5'd0)?32'd0:rd_data_in;//0号寄存器只能写入0
end
endmodule
