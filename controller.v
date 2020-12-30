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
	input wire[5:0] opD,functD,
	input wire equalD,
	input wire flushE,
	output wire memtoregW,regwriteW,
	output wire pcsrcD,branchD,
	output wire jumpD,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,	
	output wire[7:0] alucontrolE,
	output wire memtoregM,memwriteM,regwriteM
    );
	
	//decode stage
//	wire[1:0] aluopD;
	wire memtoregD,memwriteD,alusrcD,regdstD,regwriteD;
	wire[7:0] alucontrolD;

	//execute stage
	wire memwriteE,memen;

//	main_decode main_dec(opD,aluopD,jumpD,regwriteD,regdstD,alusrcD,branchD,memwriteD,memtoregD,memen);
	main_decode main_dec(opD,functD,jumpD,regwriteD,regdstD,alusrcD,branchD,memwriteD,memtoregD,memen);
	alu_decode aludec(opD,functD,alucontrolD);

	assign pcsrcD = branchD && equalD;

	//pipeline registers
	floprc #(13) regE(
		clk,
		rst,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE}
		);
	flopr #(3) regM(
		clk,rst,
		{memtoregE,memwriteE,regwriteE},
		{memtoregM,memwriteM,regwriteM}
		);
	flopr #(2) regW(
		clk,rst,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);
endmodule

