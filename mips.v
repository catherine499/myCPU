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

//mipsÄ£¿é
module mips(
	input wire clk,rst,
	input wire[31:0] readdataM, 
	input wire[31:0] instrF, 
	output wire memwriteM,
	output wire[31:0] aluoutM,writedataM,
	output wire[31:0] pcF 
    );
	
	wire [5:0] opD,functD;
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,regwriteE,regwriteM,regwriteW,branchD,jumpD;
	wire [7:0] alucontrolE;
	wire flushE,equalD;

    controller controller(
	.clk(clk),
	.rst(rst),
	.opD(opD),
	.functD(functD),
	.equalD(equalD),
	.flushE(flushE),
	.memtoregW(memtoregW),
	.regwriteW(regwriteW),
	.pcsrcD(pcsrcD),
	.branchD(branchD),
	.jumpD(jumpD),
	.memtoregE(memtoregE),
	.alusrcE(alusrcE),
	.regdstE(regdstE),
	.regwriteE(regwriteE),	
	.alucontrolE(alucontrolE),
	.memtoregM(memtoregM),
	.memwriteM(memwriteM),
	.regwriteM(regwriteM)
    );
 datapath datapath(
	.clk(clk),
	.rst(rst),
	.instrF(instrF),
	.pcsrcD(pcsrcD),
	.branchD(branchD),
	.jumpD(jumpD),
	.memtoregE(memtoregE),
	.alusrcE(alusrcE),
	.regdstE(regdstE),
    .regwriteE(regwriteE),
    .alucontrolE(alucontrolE),
	.memtoregM(memtoregM),
	.regwriteM(regwriteM),
	.readdataM(readdataM),
	.memtoregW(memtoregW),
	.regwriteW(regwriteW),
	.equalD(equalD),
	.opD(opD),
	.functD(functD),
	.pcF(pcF),
	.flushE(flushE),
	.aluoutM(aluoutM),
	.writedataM(writedataM)
    );
endmodule

