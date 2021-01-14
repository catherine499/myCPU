`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/04 09:43:21
// Design Name: 
// Module Name: sel_read
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

module pc #(parameter WIDTH=8)(
	input wire clk,rst,ena,clr,
	input wire[WIDTH-1:0] t,
	input wire[WIDTH-1:0] d,
	output reg [WIDTH-1:0] q
);
	initial begin
		q<=32'hbfc00000;  //地址初始化
	end
	always @(posedge clk,posedge rst) begin
		if(rst) begin
		    q<=32'hbfc00000;
		end else if(clr) begin
            q <= t;
        end else if(ena) begin
			q <= d;
		end
	end
endmodule
