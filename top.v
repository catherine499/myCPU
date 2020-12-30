`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/29 16:57:27
// Design Name: 
// Module Name: top
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

//顶层模块

module top(
	input wire clk,rst,//时钟、复位信号
	output wire[31:0] writedata,dataadr,//要写入的数据 写入的地址
	output wire memwrite, //数据存储器的写使能信号
	output wire[31:0] pc,
	output wire[31:0]instr,
	output wire [31:0]readdata//pc 、指令、读出来的数据
    );


	mips mips(clk,rst,readdata,instr,memwrite,dataadr,writedata,pc);
	inst_ram instr_mem(
	.clka(~clk),
	.ena(1'b1),      // input wire ena
	.wea(4'b0000),      // input wire [3 : 0] wea
	.addra(pc),
	.dina(32'b0),    // input wire [31 : 0] dina
	.douta(instr)
);

    data_ram data_mem(
	.clka(clk),
	.ena(1'b1),
	.wea({4{memwrite}}),
	.addra(dataadr),
	.dina(writedata),	 // 要写入存储器中的数据
	.douta(readdata)	 // 从存储器中读出的数据
);
	
endmodule
