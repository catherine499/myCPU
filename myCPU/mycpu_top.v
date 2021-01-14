`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/29 16:57:27
// Design Name: 
// Module Name: top
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

//¶¥²ãÄ£¿é
module  mycpu_top(
	input wire clk,rst,
	output wire[31:0] writedata,dataadr,
	output wire memwrite,
	output wire [39:0]instr_ascii,
	output wire memen, //
	output wire[31:0] pc,
	output wire[31:0]instr,
	//output wire[39:0] instr_ascii,
	output wire [31:0]readdata,//pc 
	output wire stallE,flushE,
	//inst_ram
	input [31:0] inst_sram_rdata,
	output inst_sram_en,
	output [31:0] inst_sram_addr,
	output [3:0] inst_sram_wen,
	output [31:0] inst_sram_wdata,
	//data_ram
	input [31:0] data_sram_rdata,
	output data_sram_en,
	output [31:0] data_sram_addr,
	output [3:0] data_sram_wen,
	output [31:0] data_sram_wdata,
	// debug ports
	output wire [31:0] debug_wb_pc      ,	// pc
	output wire [ 3:0] debug_wb_rf_wen  ,	// regfile write enable
	output wire [ 4:0] debug_wb_rf_wnum ,	// regfile write number
	output wire [31:0] debug_wb_rf_wdata,	// regfile write data
    input wire [5:0] int
    );
    assign inst_sram_en = 1'b1;
    assign inst_sram_wen = 4'b0000;
	assign data_sram_en = 1'b1;
	assign inst_sram_wdata = 32'b0;
   // wire[31:0] pc,instr,readdata;
	wire[3:0] sel;
	wire mem_to_reg;

	//mips mips(clk,rst,pc,instr,memwrite,mem_to_reg,dataadr,writedata,readdata,sel);

//	inst_ram instr_mem(
//	.clka(~clk),
//	.ena(1'b1),      // input wire ena
//	.wea(4'b0000),      // input wire [3 : 0] wea
//	.addra(pc),
//	.dina(32'b0),    // input wire [31 : 0] dina
//	.douta(instr)
//);
//	data_ram dmem(
//    .clka(~clk),
//    .wea(sel),
//    .addra(dataadr),
//    .dina(writedata),
//    .douta(readdata),
//    .ena(memwrite|mem_to_reg));
    mips mips(
	.clk(clk),
	.resetn(~rst),
	.int(int),
	.inst_sram_en(inst_sram_en),
	.inst_sram_wen(inst_sram_wen),
	.inst_sram_addr(inst_sram_addr),
	.inst_sram_wdata(inst_sram_wdata), 
	.inst_sram_rdata(inst_sram_rdata),
	.data_sram_en(data_sram_en),
	.data_sram_wen(data_sram_wen),
	.data_sram_addr(data_sram_addr),
	.data_sram_wdata(data_sram_wdata),
	.data_sram_rdata(data_sram_rdata),
	.debug_wb_pc(debug_wb_pc),
	.debug_wb_rf_wen(debug_wb_rf_wen),
	.debug_wb_rf_wnum(debug_wb_rf_wnum),
	.debug_wb_rf_wdata(debug_wb_rf_wdata)
    );
    
endmodule