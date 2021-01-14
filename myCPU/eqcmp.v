`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/29 18:01:54
// Design Name: 
// Module Name: eqcmp
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
module eqcmp(
	input wire [31:0] a,b,
	input wire [5:0]op,
	input wire [4:0]rt,
	output reg y
    );
	always@(*) begin
		case(op)
			`EXE_BEQ:y <=  (a == b) ? 1 : 0;
			`EXE_BNE:y <=  (a == b) ? 0 : 1;
			`EXE_BGTZ:y <= (a[31] == 0 && a != 32'b0) ? 1: 0;
			`EXE_BLEZ:y <= (a[31] == 1 || a == 32'b0) ? 1: 0;
			6'b00_0001:case(rt)
							`EXE_BLTZ:y <= (a[31] == 1) ? 1: 0;
							`EXE_BLTZAL:y <= (a[31] == 1) ? 1: 0;
							`EXE_BGEZ:y <= (a[31] == 0) ? 1: 0;
							`EXE_BGEZAL:y <= (a[31] == 0) ? 1: 0;
							default:y <= 0;
						 endcase
			default:y<=0;
		endcase
	end
endmodule
