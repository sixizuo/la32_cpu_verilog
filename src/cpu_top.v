`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/23 14:32:48
// Design Name: 
// Module Name: cpu_top
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


module cpu_top(clk,reset_n);
input clk,reset_n;
wire [31:0] seq_pc,beq_pc,b_pc,PC,next_pc,beq_offset,b_offset,beq_offset_imm,
            b_offset_imm,beq_seq_pc;
wire [31:0] instr;
wire b,beq,srcI12,srcRd,mem2reg,memwr,regwr,zero,beq_ok;
wire [2:0] alu_ctr;
wire rom_cs_n,ram_cs_n;
assign rom_cs_n = (PC[31:8]===24'h1c0000)?0:1;//限定指令存储器地址高位
wire [31:0] rd_data_in,rd_data_out,rj_data,rk_data,alu_res,mem_data_out,alu_src_2;
wire [31:0] alu_src_2_pre,alu_src_2_imm;
assign beq_ok=beq&zero;
adder u_seq_pc(PC,32'd4,seq_pc);//顺序执行下一条指令地址
adder u_beq_pc(PC,beq_offset,beq_pc);//条件跳转目的地址
adder u_b_pc(PC,b_offset,b_pc);//无条件跳转目标地址
mux u_beq_seq(seq_pc,beq_pc,beq_seq_pc,beq_ok);//顺序以及条件跳转地址复用
mux u_b(beq_seq_pc,b_pc,next_pc,b);//下一条指令地址复用
GR_PC u_pc(reset_n,clk,next_pc,PC);//PC寄存器
ROM u_instr_rom(PC[7:2],instr,rom_cs_n);//指令存储器，限定地址范围
GR_REG_File u_reg_file(~clk,rd_data_in,rd_data_out,instr[4:0],instr[9:5],instr[14:10],
                    rj_data,rk_data,regwr,reset_n);//通用寄存器堆
mux u_imm_rj_data(rk_data,alu_src_2_imm,alu_src_2_pre,srcI12);//3R指令与2RI12指令数据源复用
mux u_alu_src2(alu_src_2_pre,rd_data_out,alu_src_2,srcRd);//条件跳转指令数据源复用
SignExtend u_imm_12(instr[21:10],alu_src_2_imm);//si12符号扩展
    defparam u_imm_12.W=12;
SignExtend u_imm_16(instr[25:10],beq_offset_imm);//si16符号扩展
    defparam u_imm_16.W=16;
SignExtend u_imm_26({instr[9:0],instr[25:10]},b_offset_imm);//si26符号扩展
    defparam u_imm_26.W=26;
ShiftLeft_2b u_b_offset(b_offset_imm,b_offset);//si16左移2位
ShiftLeft_2b u_beq_offset(beq_offset_imm,beq_offset);//si26左移两位
ALU u_alu(rj_data,alu_src_2,alu_res,alu_ctr,zero);//ALU
assign ram_cs_n = (alu_res[31:8]===24'h100100)?0:1;//限定数据存储器地址高位
RAM u_data_ram(~clk,rd_data_out,mem_data_out,alu_res[7:2],memwr,ram_cs_n,reset_n);//数据存储器
mux u_rd_data_in(alu_res,mem_data_out,rd_data_in,mem2reg);//写入寄存器堆数据复用
controller u_controller(instr[31:15],alu_ctr,regwr,memwr,b,beq,mem2reg,srcI12,srcRd);//控制器
endmodule
