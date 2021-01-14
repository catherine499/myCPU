`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/29 16:58:41
// Design Name: 
// Module Name: mips
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


module mips(
	input wire clk,resetn,
	input wire[5:0] int,
	output wire inst_sram_en,
	output wire[3:0] inst_sram_wen,
	output wire[31:0] inst_sram_addr,
	inst_sram_wdata, 
	input wire[31:0] inst_sram_rdata,
	output wire data_sram_en,
	output wire[3:0] data_sram_wen,
	output wire[31:0] data_sram_addr,data_sram_wdata,
	input wire[31:0] data_sram_rdata,
	output wire[31:0] debug_wb_pc,
	output wire[3:0] debug_wb_rf_wen,
	output wire[4:0] debug_wb_rf_wnum,
	output wire[31:0] debug_wb_rf_wdata
    );
	
	wire [31:0] instrD;
	wire jrD,jalD;
	wire [4:0] rtD;
	wire cp0_weD;
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregW,invalidD,
			regwriteE,regwriteM,regwriteW,jalE,jrE,cp0_to_regE;
	wire [7:0] alucontrolE;
	wire flushE,equalD,flushM,flushW;
	wire stallE,stallM,stallW;
	wire memwriteM, memtoregM;
    wire branchD,jumpD;
	assign inst_sram_en = 1'b1;
	assign inst_sram_wen = 4'b0;
	assign inst_sram_wdata = 32'b0;
	assign data_sram_en = memwriteM | memtoregM;
	assign debug_wb_rf_wen = {4{regwriteW}};

	controller c(
		.clk(clk),
		.rst(resetn),
		//decode stage
		.instrD(instrD),
		.pcsrcD(pcsrcD),
		.branchD(branchD),
		.equalD(equalD),
		.jumpD(jumpD),
		
		//execute stage
		.flushE(flushE),
		.flushM(flushM),
		.flushW(flushW),            //flush M W for except flush
		.memtoregE(memtoregE),
		.alusrcE(alusrcE),
		.regdstE(regdstE),
		.regwriteE(regwriteE),	
		.alucontrolE(alucontrolE),

		//mem stage
		.memtoregM(memtoregM),
		.memwriteM(memwriteM),
		.regwriteM(regwriteM),
		//write back stage
		.memtoregW(memtoregW),
		.regwriteW(regwriteW),
		//DIV STALL
		.stallE(stallE),
		.stallM(stallM),
		.stallW(stallW),
		//jal
		.jalD(jalD),
		.jalE(jalE),
		//jr
		.jrD(jrD),
		//jalr
		.jrE(jrE),
		//rtD
		.rtD(rtD),
		//except
		.cp0_weD(cp0_weD),
		.cp0_to_regE(cp0_to_regE),
		.invalidD(invalidD)
		);
		wire [31:0] data_sram_addr_tmp;
	datapath dp(
		.clk(clk),
		.rst(resetn),
		//fetch stage
		.pcF(inst_sram_addr),
		.instrF(inst_sram_rdata),
		//decode stage
		.pcsrcD(pcsrcD),
		.branchD(branchD),
		.jumpD(jumpD),
		.equalD(equalD),
		// use instrD to replace opD,functD __LH
		.instrD(instrD),
		//execute stage
		.memtoregE(memtoregE),
		.alusrcE(alusrcE),
		.regdstE(regdstE),
		.regwriteE(regwriteE),
		.alucontrolE(alucontrolE),
		.flushE(flushE),
		.flushM(flushM),
		.flushW(flushW),    //flush M W for except flush
		//mem stage
		.memtoregM(memtoregM),
		.regwriteM(regwriteM),
		.aluoutM(data_sram_addr_tmp),
		.writedataM(data_sram_wdata),
		.temp_readdataM(data_sram_rdata),
		//writeback stage
		.memtoregW(memtoregW),
		.regwriteW(regwriteW),
		//DIV
		.stallE(stallE),
		.stallM(stallM),
		.stallW(stallW),
		//jal
		.jalD(jalD),
		.jalE(jalE),
		//jr
		.jrD(jrD),
		//jalr
		.jrE(jrE),
		//rtD for branch
		.rtD(rtD),
		// memory instructions
		.sel(data_sram_wen),
		// test
		.pcW(debug_wb_pc),
		.writeregW(debug_wb_rf_wnum),
		.resultW(debug_wb_rf_wdata),
		//except
		.cp0_wD(cp0_weD),
		.cp0_to_regE(cp0_to_regE),
		.invalidD(invalidD)
	    );
	assign data_sram_addr = (data_sram_addr_tmp[31] == 1)? {3'b000, data_sram_addr_tmp[28:0]} : data_sram_addr_tmp;
	
endmodule
