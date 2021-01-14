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



//根据输入的指令的前六位op 和末六位 funct字段，判断指令的类型，输出alucontrol的控制信号
//特权指令 mtc0、mfc0、eret要根据instr的25-21位判断，因此最终改为传instr进来   
    
module alu_decode(
//   input wire [5:0] op,
//   input wire[5:0] funct,
//   input wire [4:0]rt,
   input [31:0] instr,
   output reg [7:0] alucontrol
    );
    
   wire [5:0] op;
   wire[5:0] funct;
   wire [4:0]rt;
   assign op=instr[31:26];
   assign funct=instr[5:0];
   assign rt=instr[20:16];
    always @(*) begin
        case(op)     
                   
        //逻辑运算指令
        `EXE_ANDI	 : alucontrol = `EXE_ANDI_OP; //andi
        `EXE_XORI	 : alucontrol <= `EXE_XORI_OP; //xori
        `EXE_LUI	 : alucontrol <= `EXE_LUI_OP;  //lui
        `EXE_ORI	 : alucontrol <= `EXE_ORI_OP; //ori
         
        //算数运算指令
        `EXE_ADDI    : alucontrol <= `EXE_ADDI_OP; //addi
        `EXE_ADDIU    : alucontrol <=  `EXE_ADDIU_OP;//addiu 
        `EXE_SLTI   : alucontrol <= `EXE_SLTI_OP;  //slti
        `EXE_SLTIU   : alucontrol <= `EXE_SLTIU_OP; //sltiu
         
         //分支跳转指令
        `EXE_J      :  alucontrol <= `EXE_J_OP; //j
        `EXE_JAL    :  alucontrol <= `EXE_JAL_OP; //jal
        `EXE_BEQ    :  alucontrol <= `EXE_BEQ_OP; //beq
        `EXE_BGTZ   :  alucontrol <= `EXE_BGTZ_OP;//bgtz
        `EXE_BLEZ   :  alucontrol <= `EXE_BLEZ_OP;//blez
        `EXE_BNE    :  alucontrol <= `EXE_BNE_OP; //bne
        `EXE_REGIMM_INST:
            begin 
            case(rt)
                `EXE_BLTZ   :  alucontrol <= `EXE_BLTZ_OP;//bltz   这几条是根据20??16判断，暂时不能加，不然会匹配出错
                `EXE_BLTZAL :  alucontrol <= `EXE_BLTZAL_OP;//bltzal
                `EXE_BGEZ   :  alucontrol <= `EXE_BGEZ_OP; //bgez
                `EXE_BGEZAL :  alucontrol <= `EXE_BGEZAL_OP;//bgezal
            endcase
            end
       
        //访存指令
        `EXE_LB  : alucontrol <= `EXE_LB_OP;    //lb
        `EXE_LBU  : alucontrol <= `EXE_LBU_OP;  //lbu
        `EXE_LH  : alucontrol <= `EXE_LH_OP;  //lh
        `EXE_LHU  : alucontrol <= `EXE_LHU_OP;  //lhu
        `EXE_LW  : alucontrol <=  `EXE_LW_OP;   //lw
        `EXE_SB  : alucontrol <= `EXE_SB_OP;  //sb
        `EXE_SH  : alucontrol <=  `EXE_SH_OP; //sh
        `EXE_SW  : alucontrol <= `EXE_SW_OP;  //sw
        

        6'b010000:  //特权指令
            if(instr==`EXE_ERET) //eret
                alucontrol <= `EXE_ERET_OP;
            else if(instr[25:21]==5'b00100) //mtc0
                alucontrol <= `EXE_MTC0_OP;
            else if(instr[25:21]==5'b00000) //mfc0
                alucontrol <= `EXE_MFC0_OP;
            
        
        //R型指令，op字段都是??0，需根据funct字段判断
        `EXE_NOP :  
            begin
            case(funct)
                //逻辑运算指令
                `EXE_AND : alucontrol <= `EXE_AND_OP;//and
                `EXE_OR  : alucontrol <= `EXE_OR_OP; //or
                `EXE_XOR : alucontrol <= `EXE_XOR_OP; //xor
                `EXE_NOR : alucontrol <= `EXE_NOR_OP; //nor
                
                //移位指令
                `EXE_SLL : alucontrol <= `EXE_SLL_OP; //sll
                `EXE_SRL : alucontrol <= `EXE_SRL_OP; //srl
                `EXE_SRA : alucontrol <= `EXE_SRA_OP;//sra
                `EXE_SLLV: alucontrol <= `EXE_SLLV_OP; //sllv
                `EXE_SRLV: alucontrol <= `EXE_SRLV_OP; //srlv
                `EXE_SRAV: alucontrol <= `EXE_SRAV_OP; //srav
                
                //数据移动指令
                `EXE_MFHI : alucontrol <=  `EXE_MFHI_OP; //mfhi 
                `EXE_MFLO : alucontrol <= `EXE_MFLO_OP; //mflo
                `EXE_MTHI : alucontrol <=  `EXE_MTHI_OP; //mthi
                `EXE_MTLO : alucontrol <=  `EXE_MTLO_OP; //mtlo
                        
                //算数运算指令     
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
                
                //分支跳转指令
                `EXE_JR   : alucontrol <= `EXE_JR_OP;//jr
                `EXE_JALR : alucontrol <= `EXE_JALR_OP; //jalr
                
                //内陷指令
                `EXE_SYSCALL  : alucontrol <= `EXE_SYSCALL_OP;//break
                `EXE_BREAK    : alucontrol <= `EXE_BREAK_OP; //syscall
           
            endcase
         end    

        6'b111111 :begin
            case(funct)
                6'b000000 : alucontrol <=  8'b00000001 ;
            endcase
           end 


        endcase    
    end
    
endmodule
