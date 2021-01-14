`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/29 17:45:14
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



module controller(
	input wire clk,rst,
	//decode stage
	input wire  [31:0] instrD,
	output wire pcsrcD,branchD,
	input equalD,//zero & branch = pcsrc
	output jumpD,
	
	//execute stage
	input wire flushE,flushM,flushW,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,	
	output wire[7:0] alucontrolE,

	//mem stage
	output wire memtoregM,memwriteM,
				regwriteM,
	//write back stage
	output wire memtoregW,regwriteW,
    //div stall
    input wire stallE,stallM,stallW,
    //jal
    output wire jalD,jalE,
    //jr
    output wire jrD,
    //jalr need jr|jal 's controll
    output wire jrE,
    //rtD for branch
    input [4:0] rtD,
    //excpet
    output wire cp0_weD,
	output wire cp0_to_regE,
	output wire invalidD
    );
    wire[5:0] opD,functD;
    assign opD=instrD[31:26];
	assign functD=instrD[5:0];
	
	//decode stage
	wire[1:0] aluopD;
	wire memtoregD,memwriteD,alusrcD,
		regdstD,regwriteD,cp0_to_regD;
	wire[7:0] alucontrolD;

	//execute stage
	wire memwriteE;

	main_decode maindeoc(
		.instr(instrD),
		.branchD(branchD),
		.jumpD(jumpD),
		.regdstD(regdstD),
		.alusrcD(alusrcD),
		.memwriteD(memwriteD),
		.memtoregD(memtoregD),
		.regwriteD(regwriteD),
		.jalD(jalD),
		.jrD(jrD),
		.cp0_weD(cp0_weD),
		.cp0_to_regD(cp0_to_regD),
		.invalidD(invalidD)
		);

//	alu_decode ad(.funct(functD),.aluop(aluopD),.alucontrol(alucontrolD));
    alu_decode aludeoc(.instr(instrD),.alucontrol(alucontrolD));
    
	assign pcsrcD = branchD & equalD;

	//pipeline registers
	flopenrc #(17) regE(
		clk,rst,~stallE,flushE,
		{cp0_to_regD,jrD,jalD,memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD},
		{cp0_to_regE,jrE,jalE,memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE}
		);
	flopenrc #(3) regM(
		clk,rst,~stallM,flushM,
		{memtoregE,memwriteE,regwriteE},
		{memtoregM,memwriteM,regwriteM}
		);
	flopenrc #(2) regW(
		clk,rst,~stallW,flushW,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);
endmodule



