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
module main_decode(
  	input wire[31:0] instr,
	output wire branchD,
	output wire jumpD,
	output wire regdstD,
	output wire alusrcD,
	output wire memwriteD,
	output wire memtoregD,
	output wire regwriteD,
	output wire jalD,
	output wire jrD,
	output wire cp0_weD,
	output wire cp0_to_regD,
	output reg invalidD
    );

    wire[5:0] op, funct;
	wire [4:0] rt;
	assign op = instr[31:26];
	assign funct = instr[5:0];
	assign rt = instr[20:16];
	//????
	reg [6:0] sigs;
	assign {regwriteD,memtoregD,memwriteD,alusrcD,regdstD,jumpD,branchD}=sigs;
	//??????????
	reg [1:0] jumps;
	assign {jrD,jalD}=jumps;
	//cp0????
	reg [1:0] cp0s;
	assign {cp0_to_regD,cp0_weD}=cp0s;

	always@(*)
		begin
			case(op)
		    `EXE_JAL: jumps <= 2'b01;
			`EXE_NOP:
				case(funct)
					`EXE_JR:  jumps <= 2'b10;
					`EXE_JALR: jumps <=2'b11;
					default :jumps <= 2'b00;
				endcase
			`EXE_REGIMM_INST:
				case(rt)
			         `EXE_BGEZ: jumps <= 2'b00;
			         `EXE_BLTZ:jumps <= 2'b00;
			         `EXE_BGEZAL:jumps <= 2'b01;
			         `EXE_BLTZAL:jumps <= 2'b01;
			         default:jumps <= 2'b00;
			    endcase
            default:jumps <= 2'b00;
			endcase
		end
	
	always@(*) begin
	    invalidD=0;
	    sigs[6:0] = 7'b000_0000;
	    cp0s[0] <= (instr[31:26] == 6'b010000 && instr[25:21]== 5'b00100)? 1'b1 : 1'b0;
		cp0s[1] <= (instr[31:26] == 6'b010000 && instr[25:21]== 5'b00000)? 1'b1 : 1'b0;
		case(op)
		      //??????
			`EXE_LUI: sigs[6:0] <= 7'b100_1000; //lui
			`EXE_ANDI: sigs[6:0] <= 7'b100_1000; //andi
			`EXE_XORI: sigs[6:0] <= 7'b100_1000; //xori
			`EXE_ORI: sigs[6:0] <= 7'b100_1000; //ori
			//??????
			`EXE_ADDI:sigs[6:0] <= 7'b100_1000;  //addi
			`EXE_ADDIU:sigs[6:0] <= 7'b100_1000;  //addiu
			`EXE_SLTI:sigs[6:0] <= 7'b100_1000;  //slti
			`EXE_SLTIU: sigs[6:0] <= 7'b100_1000;      //sltu                
			//??????
			`EXE_J:  sigs[6:0] <= 7'b000_0010;     // simple jump
			`EXE_JAL: sigs[6:0] <= 7'b100_0010;     //  jal
			`EXE_BEQ: sigs[6:0] <= 7'b000_0001;    //beq
			`EXE_BGTZ: sigs[6:0] <= 7'b000_0001;   //bgtz
			`EXE_BLEZ: sigs[6:0] <= 7'b000_0001;   //bltz
			`EXE_BNE: sigs[6:0] <= 7'b000_0001;    //bne
			`EXE_NOP: //R??? op=6'b000000
				case(funct)
					//??????
					`EXE_AND: sigs[6:0] <= 7'b100_0100; //and
					`EXE_OR: sigs[6:0] <= 7'b100_0100; //or
					`EXE_XOR: sigs[6:0] <= 7'b100_0100; //xor
					`EXE_NOR: sigs[6:0] <= 7'b100_0100; //nor
					//????
					`EXE_SLL: sigs[6:0] <= 7'b100_0100; //sll
					`EXE_SRL: sigs[6:0] <= 7'b100_0100; //srl
					`EXE_SRA: sigs[6:0] <= 7'b100_0100; //sra 
					`EXE_SLLV: sigs[6:0] <= 7'b100_0100; //sllv
					`EXE_SRLV: sigs[6:0] <= 7'b100_0100; //srlv
					`EXE_SRAV: sigs[6:0] <= 7'b100_0100; //srav
					//??????
					`EXE_MFHI: sigs[6:0] <= 7'b100_0100;    //mfhi
					`EXE_MFLO: sigs[6:0] <= 7'b100_0100;     //mflo
					`EXE_MTHI: sigs[6:0] <= 7'b000_0000;   //mthi
					`EXE_MTLO: sigs[6:0] <= 7'b000_0000;   //mtlo
					//??????                           
					`EXE_ADD: sigs[6:0] <= 7'b100_0100;  //add
					`EXE_ADDU: sigs[6:0] <= 7'b100_0100; //addu
					`EXE_SUB: sigs[6:0] <= 7'b100_0100;  //sub
					`EXE_SUBU: sigs[6:0] <= 7'b100_0100;  //subu
					`EXE_SLT: sigs[6:0] <= 7'b100_0100;  //slt
					`EXE_SLTU: sigs[6:0] <= 7'b100_0100;  //sltu
					`EXE_MULT: sigs[6:0] <= 7'b000_0000;  //mult
					`EXE_MULTU: sigs[6:0] <= 7'b000_0000;  //multu
					`EXE_DIV: sigs[6:0] <= 7'b000_0000;  //div
					`EXE_DIVU: sigs[6:0] <= 7'b000_0000;   //divu
					//??????
					`EXE_JR: sigs[6:0] <= 7'b000_0000;     //   jr
			        `EXE_JALR: sigs[6:0] <= 7'b100_0010;   //jalr
					default: invalidD=1;
				endcase
			
			`EXE_REGIMM_INST: //op=6'b000001
			    case(rt)   //bgez  bltz  bgzal  bltzal
			         `EXE_BGEZ: sigs[6:0] <= 7'b000_0001;
			         `EXE_BLTZ:	sigs[6:0] <= 7'b000_0001;
			         `EXE_BGEZAL: sigs[6:0] <= 7'b100_0001;
			         `EXE_BLTZAL:  sigs[6:0] <= 7'b100_0001;
			         default:invalidD=1;
			    endcase
			//????
			`EXE_LB: sigs[6:0] <= 7'b110_1000; //lb
			`EXE_LBU: sigs[6:0] <= 7'b110_1000; //lbu
		    `EXE_LH: sigs[6:0] <= 7'b110_1000; //lh
		    `EXE_LHU: sigs[6:0] <= 7'b110_1000; //lhu
		     `EXE_LW: sigs[6:0] <= 7'b110_1000; //lw
			`EXE_SB: sigs[6:0] <= 7'b001_1000; //sb
			`EXE_SH: sigs[6:0] <= 7'b001_1000; //sh
			 `EXE_SW: sigs[6:0] <= 7'b001_1000; //sw
			
			
			//{regwriteD,memtoregD,memwriteD,alusrcD,regdstD,jumpD,branchD}=sigs;
			
			6'b111111 :begin
            case(funct)
                6'b000000 : sigs[6:0] <= 7'b100_0100;
            endcase
           end 
			
			
			//????
			6'b010000:
			 begin
				case (instr[25:21])
					5'b00000: sigs[6:0] <= 7'b100_0000; //mfc0
					5'b00100: sigs[6:0] <= 7'b000_0000;//mtc0
					default: invalidD=1;
				endcase
				if(instr==`EXE_ERET)//eret
				    begin sigs[6:0] <= 7'b000_0000;
				    		invalidD=1;
				    end
			 end
			default: invalidD=1;
		endcase  
	end  
endmodule

