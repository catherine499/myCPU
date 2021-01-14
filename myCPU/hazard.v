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

`include "defines.vh"
module hazard(
		//f阶段
		output stallF,
		//D阶段
		input [4:0] rsD,rtD,
		input branchD,
		output wire [1:0] forwardaD,forwardbD,
		output stallD,//ok
		//E阶段
		input [4:0] rsE,rtE,
		input [4:0] writeregE,
		input regwriteE,
		input memtoregE,
		output [1:0] forwardaE,forwardbE,
		output flushE,
		//M阶段
		input [4:0] writeregM,
		input regwriteM,
		input memtoregM,
		//w阶段
		input [4:0] writeregW,
		input regwriteW,
		//hilo
		input [7:0] alucontrolE,
		input [7:0] alucontrolM,
		input [7:0] alucontrolW,
		output [2:0] forward_hiloE,
		//div
		input stall_divE,
		output stallE,stallM,stallW,
		//cp0 forward
		input [4:0] rdE,rdM,
		input cp0weM,
		output forwardcp0E,
		//cp0 util
		input [31:0] excepttypeM,
		input wire [31:0] cp0_epcM,
	    output reg [31:0] newpcM,
		input wire cp0_to_regE
    );

    wire flush_except;//异常刷新信号
    assign flush_except = (excepttypeM != 32'b0);
    
    //cp0前推
    assign forwardcp0E = ((rdE!=0)&(rdE == rdM)&(cp0weM))?1'b1:1'b0;
	//数据前推
	assign forwardaE= (rsE!=0 & rsE==writeregM & regwriteM)? 2'b10:
					  (rsE!=0 & rsE==writeregW & regwriteW)? 2'b01: 2'b00;
	assign forwardbE= (rtE!=0 & rtE==writeregM & regwriteM)? 2'b10:
					  (rtE!=0 & rtE==writeregW & regwriteW)? 2'b01: 2'b00;
	wire lwstall,cp0_to_reg_stall;
	assign lwstall = ((rsD==rtE | rtD==rtE) & memtoregE);
	assign cp0_to_reg_stall = ((rsD==rtE | rtD==rtE) & cp0_to_regE);
	
	// assign forwardaD = (rsD!=0 & rsD==writeregM & regwriteM);
	// assign forwardbD = rsD!=0 & rtD==writeregM & regwriteM;
	
	assign forwardaD =	(rsD==0)? 2'b00:
						(rsD == writeregE & regwriteE)?2'b01:
						(rsD == writeregM & regwriteM)?2'b10:
						(rsD == writeregW & regwriteW)?2'b11:2'b00;
	assign forwardbD =	(rtD==0)?2'b00:
						(rtD == writeregE & regwriteE)?2'b01:
						(rtD == writeregM & regwriteM)?2'b10:
						(rtD == writeregW & regwriteW)?2'b11:2'b00;
	
	wire branchstall;
	assign branchstall= (branchD & regwriteE & (writeregE==rsD | writeregE==rtD)) | (branchD & memtoregM & (writeregM==rsD | writeregM==rtD));
	assign flushE=(lwstall | branchstall |cp0_to_reg_stall) | flush_except;
	
	assign stallF=(lwstall | branchstall |cp0_to_reg_stall| stall_divE);
	assign stallD=(lwstall | branchstall |cp0_to_reg_stall| stall_divE);
	assign stallE=stall_divE;
	assign stallM=0;
	assign stallW=0;
	
	//hilo是否存在冒险  mt mf mul div
	wire hiEM,loEM;
	assign hiEM= (alucontrolE==`EXE_MFHI_OP)&( (alucontrolM==`EXE_MTHI_OP) | ((alucontrolM == `EXE_MULT_OP) |  (alucontrolM == `EXE_MULTU_OP) |  (alucontrolM == `EXE_DIV_OP) |  (alucontrolM == `EXE_DIVU_OP)) );
	assign loEM= (alucontrolE==`EXE_MFLO_OP)&( (alucontrolM==`EXE_MTLO_OP) | ((alucontrolM == `EXE_MULT_OP) |  (alucontrolM == `EXE_MULTU_OP) |  (alucontrolM == `EXE_DIV_OP) |  (alucontrolM == `EXE_DIVU_OP)) );
	                                                                                  
	wire hiEW,loEW;
	assign hiEW= (alucontrolE==`EXE_MFHI_OP)&( (alucontrolW==`EXE_MTHI_OP) | ((alucontrolW == `EXE_MULT_OP) |  (alucontrolW == `EXE_MULTU_OP) |  (alucontrolW == `EXE_DIV_OP) |  (alucontrolW == `EXE_DIVU_OP)) );
	assign loEW= (alucontrolE==`EXE_MFLO_OP)&( (alucontrolW==`EXE_MTLO_OP) | ((alucontrolW == `EXE_MULT_OP) |  (alucontrolW == `EXE_MULTU_OP) |  (alucontrolW == `EXE_DIV_OP) |  (alucontrolW == `EXE_DIVU_OP)) );
	//hilo数据前推
	assign forward_hiloE=( hiEM |  loEM ) ? 2'b01:
	                     ( hiEW |  loEW ) ? 2'b10: 2'b00;
	
	
	//CP0 ->bfc00380
  	always @(*) begin
		if(excepttypeM != 32'b0) begin
			/* code */
			case (excepttypeM)
				32'h00000001:begin 
					newpcM <= 32'hBFC00380;
				end
				32'h00000004:begin 
					newpcM <= 32'hBFC00380;

				end
				32'h00000005:begin 
					newpcM <= 32'hBFC00380;

				end
				32'h00000008:begin 
					newpcM <= 32'hBFC00380;
					// new_pc <= 32'h00000040;
				end
				32'h00000009:begin 
					newpcM <= 32'hBFC00380;

				end
				32'h0000000a:begin 
					newpcM <= 32'hBFC00380;

				end
				32'h0000000c:begin 
					newpcM <= 32'hBFC00380;

				end
				32'h0000000d:begin 
					newpcM <= 32'hBFC00380;

				end
				32'h0000000e:begin 
					newpcM <= cp0_epcM;
				end
				default : /* default */;
			endcase
		end
	end
	
endmodule
