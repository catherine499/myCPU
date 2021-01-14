`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/29 18:02:52
// Design Name: 
// Module Name: alu
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

module alu(
	input wire [31:0] a, b,  
	input wire [7:0] alucontrol,  
	input wire [4:0] sa,  //��λָ�� sll��srl��sra��
	output reg[31:0] y,
	output reg overflow,   //���
	input wire [63:0] alu_hilo_in, //hilo_reg��ԭʼֵ
	output reg [63:0] alu_hilo_out, //hilo_reg����ֵ
	input clk,rst,annul_i,  //�����ź�
	output wire ready_o,
	input [`RegBus] cp0_data_o_in  //��Ȩָ�����cp0ʹ��
    );
    wire [63:0] result_o;
    wire start_i;

	//---------------�˷�
    wire [31:0] mult_a,mult_b;
    wire [63:0] hilo_temp;

    //�ж��з��ų˷��ı�����������������Ǹ�����ȡ����
    assign mult_a = ( (alucontrol == `EXE_MULT_OP) && (a[31] == 1'b1) )? ( ~a + 1 ): a ; 
    assign mult_b = ( (alucontrol == `EXE_MULT_OP) && (b[31] == 1'b1) )? ( ~b + 1 ): b ; 
    //�Գ˷��������������������з��ų˷�mult��һ��һ����ˣ���Ҫ����õ��ͷ������ͬ����ˡ��޷��ų˷�������Ҫ����
    assign hilo_temp = ( (alucontrol == `EXE_MULT_OP) && (a[31] ^ b[31] == 1'b1) )?  ~(mult_a * mult_b) + 1 : mult_a * mult_b ; 



	//������ʼ�ź�
    assign start_i=(alucontrol == `EXE_DIV_OP && ready_o == 1'b0)?1'b1:
				   (alucontrol == `EXE_DIV_OP && ready_o == 1'b1)?1'b0:
				   (alucontrol == `EXE_DIVU_OP && ready_o == 1'b0)?1'b1:
				   (alucontrol == `EXE_DIVU_OP && ready_o == 1'b1)?1'b0:
			       1'b0;
    // ������
    div div(.clk(clk),.rst(rst),.alucontrol(alucontrol),.opdata1_i(a),.opdata2_i(b),.annul_i(annul_i),.result_o(result_o),.ready_o(ready_o),.start_i(start_i));

	//
	always @(*) begin
		
		case(alucontrol)
			//�߼�����ָ��
			`EXE_AND_OP:   y <= a & b;  //and
			`EXE_OR_OP:     y <= a | b;  //or
			`EXE_XOR_OP:    y <= a ^ b;  //xor
			`EXE_NOR_OP: 	y <= ~(a | b); //nor
			`EXE_ANDI_OP:	y <= a & b;  //andi
			`EXE_XORI_OP: 	y <= a ^ b;  //xori
			`EXE_LUI_OP:    y <={b[15:0],16'b0}; //lui
			`EXE_ORI_OP: 	y <= a | b;  //ori
			//��λָ��
			`EXE_SLL_OP: 	y <= b << sa; //sll
			`EXE_SRL_OP: 	y <= b >> sa; //srl
			`EXE_SRA_OP: 	y <= ({32{b[31]}} << (6'd32-{1'b0,sa}))|b>>sa; //sra
			`EXE_SLLV_OP: 	y <= b << a[4:0]; //sllv
			`EXE_SRLV_OP: 	y <= b >> a[4:0]; //srlv
			`EXE_SRAV_OP: 	y <= ({32{b[31]}} << (6'd32-{1'b0,a[4:0]}))|b>>a[4:0]; //srav
			//�����ƶ�ָ��
			`EXE_MFHI_OP:   y <= alu_hilo_in[63:32];  //��hi�Ĵ�����ֵд�뵽�Ĵ���rd��
			`EXE_MFLO_OP:   y <= alu_hilo_in[31:0];   //��lo�Ĵ�����ֵд�뵽�Ĵ���rd��
			`EXE_MTHI_OP:   alu_hilo_out <= {a,32'b0}; //��rs�Ĵ�����ֵд�뵽�Ĵ���hi��
			`EXE_MTLO_OP:   alu_hilo_out <= {32'b0,a}; //��rs�Ĵ�����ֵд�뵽�Ĵ���lo�� 
			//��������ָ��
		    `EXE_ADD_OP: y <= a+b;//add
            `EXE_ADDU_OP: y <= a+b;//addu
            `EXE_SUB_OP :   y <= a - b; //sub
            `EXE_SUBU_OP: y <= a-b;//subu
			`EXE_SLT_OP, `EXE_SLTI_OP : //slt, slti
			        y <= ($signed(a)<$signed(b))? 1 : 0;  //�ο� CSDN
//				 begin 
//               if(a[31:31] == 0 & b[31:31] == 1)    
//                   y <= 32'b0;    //a+,b-,  a>b
            
//               else if(a[31:31] == 1 & b[31:31] == 0)   
//                   y <= 32'b1;//a-,b+  a<b
            
//               else if(a[31:31] == 0 & b[31:31] == 0)  
//                   begin   //a,b+
//                       if(a[30:0] < b[30:0])    
//                           y <= 32'b1;
//                       else    
//                           y <= 32'b0;
//                   end
            
//               else if(a[31:31] == 1 & b[31:31] == 1)
//                  begin      //a,b-
//                       if(a[30:0] < b[30:0])
//                           y <= 32'b0;
//                       else
//                           y <= 32'b1;
//                   end
//               end
			`EXE_SLTU_OP,`EXE_SLTIU_OP :  //sltu, sltiu
			
               begin
                   if( a < b )
                        y <= 32'b1;
                    else
                         y <= 32'b0;
               end
            `EXE_MULT_OP: alu_hilo_out <= hilo_temp;//mult
            `EXE_MULTU_OP: alu_hilo_out <= hilo_temp;//multu
			`EXE_DIV_OP: alu_hilo_out <=result_o; //div 
			`EXE_DIVU_OP:  alu_hilo_out <=result_o; //div
			`EXE_ADDI_OP:  y<=a+b; //addi
			`EXE_ADDIU_OP: y<=a+b; //addiu
			//��֧��תָ��  ��ʹ��alu
			//�ô�ָ��
           `EXE_LB_OP: y<=a+b;//lb
           `EXE_LBU_OP: y<=a+b;//lbu
           `EXE_LH_OP:  y<=a+b;//lh
           `EXE_LHU_OP: y<=a+b;//lhu
           `EXE_LW_OP :y<=a+b; //lw
           `EXE_SB_OP: y<=a+b;//sb
           `EXE_SH_OP: y<=a+b;//sh
           `EXE_SW_OP : y <= a + b; //sw
			//��Ȩָ��
			`EXE_MFC0_OP: y<=cp0_data_o_in;         //mfc0 ��ȡcp0
			`EXE_MTC0_OP: y<=b;                     //mtc0  д��cp0


			8'b00000001: 
				begin
					if(a[31]==1)  //a<0
						y <= -a ;

					else 
						y <= a;

				end

             default: y<=32'b0;
		endcase
	end
	
//	    always @(*) begin
//		case (alucontrol)
//			`EXE_ADD_OP : overflow <= a[31] & b[31] & ~y[31] | ~a[31] & ~b[31] & y[31];
//			`EXE_SUB_OP : overflow <= ((a[31]&&~b[31])&&~y[31])||((~a[31]&&b[31])&&y[31]);
//			`EXE_ADDU_OP: overflow <= 0;
//			`EXE_SUBU_OP: overflow <= 0;
//			default: overflow <= 0;
//        endcase
//	end
	always @(*) begin                                                                                             //�ο� CSDN
		case (alucontrol)
			`EXE_ADD_OP,`EXE_ADDI_OP: overflow <= a[31] & b[31] & ~y[31] | ~a[31] & ~b[31] & y[31];
			`EXE_SUB_OP: overflow <= ((a[31]&&!b[31])&&!y[31])||((!a[31]&&b[31])&&y[31]);
            default: overflow <= 0;
        endcase
	end
    
endmodule