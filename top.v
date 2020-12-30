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

//����ģ��

module top(
	input wire clk,rst,//ʱ�ӡ���λ�ź�
	output wire[31:0] writedata,dataadr,//Ҫд������� д��ĵ�ַ
	output wire memwrite, //���ݴ洢����дʹ���ź�
	output wire[31:0] pc,
	output wire[31:0]instr,
	output wire [31:0]readdata//pc ��ָ�������������
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
	.dina(writedata),	 // Ҫд��洢���е�����
	.douta(readdata)	 // �Ӵ洢���ж���������
);
	
endmodule
