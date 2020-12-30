`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/29 17:49:55
// Design Name: 
// Module Name: main_decode
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

`include"defines.vh"
module main_decode(op,functD,jump,regwrite,regdst,alusrc,branch,memwrite,memtoreg,memen);
    input [5:0]op;
    output [5:0]functD;
    output jump,regwrite,regdst,alusrc,branch,memwrite,memtoreg,memen;

    reg [7:0]sigs;
    assign {jump,regwrite,regdst,alusrc,branch,memwrite,memtoreg,memen}=sigs;
    
    initial begin  sigs <= 8'b0000_0000;     end


    always @(*)
    begin
    case(op)
        
        //逻辑运算指令
        `EXE_ANDI_OP: sigs <=  8'b0101_0000; //andi
        `EXE_XORI_OP: sigs <= 8'b0101_0000;//xori
        `EXE_LUI_OP: sigs <=  8'b0101_0000; //lui
        `EXE_ORI_OP: sigs <= 8'b0101_0000;//ori
        
        //算数运算指令   
        `EXE_ADDI: sigs <= 8'b0101_0000;  //addi
 
        `EXE_NOP : // op = 000000
            case(functD)
                //逻辑运算指令
                `EXE_AND_OP: sigs <= 8'b0110_0000; //and
                `EXE_OR_OP: sigs <= 8'b0110_0000; //or 
                `EXE_XOR_OP: sigs <= 8'b0110_0000;//xor
                `EXE_NOR_OP: sigs <= 8'b0110_0000; //nor
                `EXE_ADD_OP,`EXE_OR_OP,`EXE_SUB_OP,`EXE_AND_OP,`EXE_SLT_OP: sigs <= 8'b0110_0000;
                
                //算数运算指令
                `EXE_ADD_OP,`EXE_SUB_OP: sigs <= 8'b0110_0000;
                
                default:sigs <= 8'b0110_0000;
            
            endcase
        
        `EXE_J  : sigs <= 8'b1000_0000;
        
        `EXE_BEQ : sigs <= 8'b0000_1000;
        
        
        `EXE_LW : sigs <= 8'b0101_0011;
        
        `EXE_SW: sigs <=8'b0001_0101;
        
        
        
        
        default:
            sigs<=8'b0000_0000;
    endcase
    end 
endmodule


