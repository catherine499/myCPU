`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/29 17:58:35
// Design Name: 
// Module Name: flopenr
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

module flopenr #(parameter WIDTH=8)(
	input wire clk,rst,ena,
	input wire[WIDTH-1:0] d,
	output reg [WIDTH-1:0] q
);
	initial begin
		q<=32'h0;
	end
	always @(posedge clk,posedge rst) begin
		if(rst) begin
			q<=32'h0;
		end else begin
			if(ena) begin
				q<=d;
			end
		end
	end
endmodule 