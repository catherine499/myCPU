`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/31 16:39:50
// Design Name: 
// Module Name: hilo_reg
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

`include "defines.vh"
module hilo_reg(
	input wire clk,rst,
	input wire [7:0] alucontrol,
	input wire[31:0] hi,lo,
	output reg[31:0] hi_o,lo_o
    );
	//???hi lo???
	wire double_write;
	assign double_write=  (alucontrol == `EXE_MULT_OP) |  (alucontrol == `EXE_MULTU_OP) |  (alucontrol == `EXE_DIV_OP) |  (alucontrol == `EXE_DIVU_OP); 
	always @(posedge clk) begin
		if(rst) begin
			hi_o <= 0;
			lo_o <= 0;
		end else
		begin
		     if ((alucontrol==`EXE_MTHI_OP) | double_write) begin hi_o <= hi;end
		     if ((alucontrol==`EXE_MTLO_OP) | double_write) begin lo_o <= lo; end
		end
	end
endmodule
