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

module alu(a,b,alucontrol,y,overflow,zero);
input [31:0]a,b;
input [7:0]alucontrol;
output reg [31:0]y;
output reg overflow;
output reg zero;

    always@(*)
    begin
        zero <=(y==32'b0)?1:0;
    end
    
    
    
    always@(*)
    begin
        case(alucontrol)
            //逻辑运算指令
            `EXE_AND_OP : y <= a&b;//and
            `EXE_OR_OP : y <= a|b; //or            
            `EXE_XOR_OP: y <= a^b;//xor
            `EXE_NOR_OP: y <= ~(a|b);//nor
            `EXE_ANDI_OP: y <=a&b; //andi
            `EXE_XORI_OP: y <= a^b; //xori
            `EXE_LUI_OP : y <= { b[15:0],16'b0 }; //lui
            `EXE_ORI_OP: y <= a|b;//ori 
        

            
            `EXE_LW_OP :y<=a+b; //lw
            `EXE_SW_OP : y <= a + b; //sw
            `EXE_ADD_OP:y<=a+b;//add
            `EXE_ADDI_OP :   y <= a + b; //addi
            `EXE_SUB_OP :   y <= a - b; //sub 
        
             `EXE_BEQ_OP : y <= a-b; //beq
             `EXE_J_OP: y <= a + b;//j
        
             `EXE_SLT_OP:  y<= a<b; //slt
       endcase
    end

    always @(*) begin
		case (alucontrol)
			`EXE_ADD_OP : overflow <= a[31] & b[31] & ~y[31] | ~a[31] & ~b[31] & y[31];
			`EXE_SUB_OP : overflow <= ((a[31]&&~b[31])&&~y[31])||((~a[31]&&b[31])&&y[31]);
			`EXE_ADDU_OP: overflow <= 0;
			`EXE_SUBU_OP: overflow <= 0;
			default: overflow <= 0;
        endcase
	end
        
//    always@(*)  //debug的时候可以用，在控制台打印出相关信息
//        $display("in alu %b:%d %d %d",alucontrol,a,b,y);
    
    
    
    
endmodule

