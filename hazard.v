`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/29 17:56:52
// Design Name: 
// Module Name: hazard
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


module hazard(
		//fetch stage
		output wire stallF,
		//decode stage
		input wire [4:0] rsD,rtD,
		input wire branchD,
		output wire forwardaD,forwardbD,
		output wire stallD,
		//execute stage
		input wire [4:0] rsE,rtE,writeregE,
		input wire regwriteE,memtoregE,
		output reg [1:0] forwardaE,forwardbE,
		output wire flushE,
		//mem stage
		input wire [4:0] writeregM,
		input wire regwriteM,memtoregM,
		//write back stage
		input wire [4:0] writeregW,
		input wire regwriteW
		);

//data hazard
always @(*) begin
    if((rsE != 0) && (rsE == writeregM) && regwriteM)     
        forwardaE <= 10;
	else if ((rsE != 0) && (rsE == writeregW) && regwriteW) 
        forwardaE <= 01;
	else forwardaE <= 00;
end
always @(*) begin
    if((rtE != 0) && (rtE == writeregM) && regwriteM)     
        forwardbE <= 10;
	else if ((rtE != 0) && (rtE == writeregW) && regwriteW) 
        forwardbE <= 01;
	else forwardbE <= 00;
end

//stop
    wire lwstall,branchstall;
    assign lwstall = ((rsD == rtE) || (rtD == rtE)) && memtoregE;
	//assign stallF = stallD = flushE = lwstall;
	
//forward logic
    assign forwardaD = (rsD !=0) && (rsD == writeregM) && regwriteM;
	assign forwardbD = (rtD !=0) && (rtD == writeregM) && regwriteM;
	
//stalling logic
    assign branchstall = branchD && ((regwriteE && 
                   (writeregE == rsD || writeregE == rtD))||
                   (memtoregM && (writeregM == rsD || writeregM == rtD)));
	assign flushE = lwstall || branchstall;
    assign stallF = lwstall || branchstall;
    assign stallD = lwstall || branchstall;


endmodule