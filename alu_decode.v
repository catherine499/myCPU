`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/29 16:00:52
// Design Name: 
// Module Name: aludec
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


//���������ָ���ǰ��λop ��ĩ��λ funct�ֶε�ֵ���ж�ָ������ͣ����alucontrol�Ŀ����ź�����
//��Ȩָ�� mtc0��mfc0��eret��Ҫ����25��21λ�жϣ������ݲ�����    
    
module alu_decode(
   input wire [5:0] op,
   input wire[5:0] funct,
   output reg [7:0] alucontrol
    );
    always @(*) begin
        case(op)     
                   
        //�߼�����ָ��
        `EXE_ANDI	 : alucontrol = `EXE_ANDI_OP; //andi
        `EXE_XORI	 : alucontrol <= `EXE_XORI_OP; //xori
        `EXE_LUI	 : alucontrol <= `EXE_LUI_OP;  //lui
        `EXE_ORI	 : alucontrol <= `EXE_ORI_OP; //ori
         
        //��������ָ��
        `EXE_ADDI    : alucontrol <= `EXE_ADDI_OP; //addi
        `EXE_ADDIU    : alucontrol <=  `EXE_ADDIU_OP;//addiu 
        `EXE_SLTI   : alucontrol <= `EXE_SLTI_OP;  //slti
        `EXE_SLTIU   : alucontrol <= `EXE_SLTIU_OP; //sltiu
         
         //��֧��תָ��
        `EXE_J      :  alucontrol <= `EXE_J_OP; //j
        `EXE_JAL    :  alucontrol <= `EXE_JAL_OP; //jal
        `EXE_BEQ    :  alucontrol <= `EXE_BEQ_OP; //beq
        `EXE_BGTZ   :  alucontrol <= `EXE_BGTZ_OP;//bgtz
        `EXE_BLEZ   :  alucontrol <= `EXE_BLEZ_OP;//blez
        `EXE_BNE    :  alucontrol <= `EXE_BNE_OP; //bne
//        `EXE_BLTZ   :  alucontrol <= `EXE_BLTZ_OP;//bltz   �⼸���Ǹ���20��16�жϣ���ʱ���ܼӣ���Ȼ��ƥ�����
//        `EXE_BLTZAL :  alucontrol <= `EXE_BLTZAL_OP;//bltzal
//        `EXE_BGEZ   :  alucontrol <= `EXE_BGEZ_OP; //bgez
//        `EXE_BGEZAL :  alucontrol <= `EXE_BGEZAL_OP;//bgezal
       
        //�ô�ָ��
        `EXE_LB  : alucontrol <= `EXE_LB_OP;    //lb
        `EXE_LBU  : alucontrol <= `EXE_LBU_OP;  //lbu
        `EXE_LH  : alucontrol <= `EXE_LH_OP;  //lh
        `EXE_LHU  : alucontrol <= `EXE_LHU_OP;  //lhu
        `EXE_LW  : alucontrol <=  `EXE_LW_OP;   //lw
        `EXE_SB  : alucontrol <= `EXE_SB_OP;  //sb
        `EXE_SH  : alucontrol <=  `EXE_SH_OP; //sh
        `EXE_SW  : alucontrol <= `EXE_SW_OP;  //sw
        
        
        //R��ָ�op�ֶζ���ȫ0�������funct�ֶ��ж�
        `EXE_NOP :  
         begin
            begin
            case(funct)
                //�߼�����ָ��
                `EXE_AND : alucontrol <= `EXE_AND_OP;//and
                `EXE_OR  : alucontrol <= `EXE_OR_OP; //or
                `EXE_XOR : alucontrol <= `EXE_XOR_OP; //xor
                `EXE_NOR : alucontrol <= `EXE_NOR_OP; //nor
                
                //��λָ��
                `EXE_SLL : alucontrol <= `EXE_SLL_OP; //sll
                `EXE_SRL : alucontrol <= `EXE_SRL_OP; //srl
                `EXE_SRA : alucontrol <= `EXE_SRA_OP;//sra
                `EXE_SLLV: alucontrol <= `EXE_SLLV_OP; //sllv
                `EXE_SRLV: alucontrol <= `EXE_SRLV_OP; //srlv
                `EXE_SRAV: alucontrol <= `EXE_SRAV_OP; //srav
                
                //�����ƶ�ָ��
                `EXE_MFHI : alucontrol <=  `EXE_MFHI_OP; //mfhi 
                `EXE_MFLO : alucontrol <= `EXE_MFLO_OP; //mflo
                `EXE_MTHI : alucontrol <=  `EXE_MTHI_OP; //mthi
                `EXE_MTLO : alucontrol <=  `EXE_MTLO_OP; //mtlo
                        
                //��������ָ��     
                `EXE_ADD  : alucontrol <= `EXE_ADD_OP; //add
                `EXE_ADDU : alucontrol <= `EXE_ADDU_OP; //addu
                `EXE_SUB  : alucontrol <= `EXE_SUB_OP; //sub
                `EXE_SUBU : alucontrol <=  `EXE_SUBU_OP; //subu
                `EXE_SLT  : alucontrol <= `EXE_SLT_OP; //slt
                `EXE_SLTU : alucontrol <= `EXE_SLTU_OP; //sltu
                `EXE_MULT : alucontrol <= `EXE_MULT_OP; //mult
                `EXE_MULTU: alucontrol <= `EXE_MULTU_OP;//multu
                `EXE_DIV  : alucontrol <= `EXE_DIV_OP;//div
                `EXE_DIVU : alucontrol <= `EXE_DIVU_OP; //divu
                
                //��֧��תָ��
                `EXE_JR   : alucontrol <= `EXE_JR_OP;//jr
                `EXE_JALR : alucontrol <= `EXE_JALR_OP; //jalr
                
                //����ָ��
                `EXE_SYSCALL  : alucontrol <= `EXE_SYSCALL_OP;//break
                `EXE_BREAK    : alucontrol <= `EXE_BREAK_OP; //syscall
           
            endcase
         end    
        end
        endcase    
    end
    
    
//    always@(*)   //debug��ʱ������ã��ڿ���̨��ӡ�������Ϣ
//         $display("in aludecode  %b %b %b",op,funct,alucontrol);
    
endmodule
