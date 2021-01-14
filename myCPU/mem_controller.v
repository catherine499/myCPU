`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/02 21:58:13
// Design Name: 
// Module Name: men_write
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
module mem_controller(
    input wire[5:0] op,
    input wire[31:0] address, //地址
    input wire[31:0] write_data_in, //要写入的数据
    output reg[31:0] write_data_out, //实际写入内存的数据
    input wire[31:0] read_data_in, //从内存读出的数据
    output reg[31:0] read_data_out, //处理后的数据
    output reg[3:0] sel,   //写字节的选择信号
    output reg[31:0] bad_addr, //错误地址
    output reg adelM, adesM, //load or store地址越界标记
    input wire [31:0] pc 
    );

    always @(*) begin
        adelM <= 1'b0;
        adesM <= 1'b0;
        bad_addr <= pc;
        //将数据写入内存
        case (op)
            `EXE_LB, `EXE_LBU: sel <= 4'b0000;
            `EXE_LH, `EXE_LHU: begin
                sel <= 4'b0000;
                case (address[1:0])
					2'b01, 2'b11: begin
                        adelM <= 1'b1;
                        bad_addr <= address;
					end
					default: /* default */;
				endcase
            end
            `EXE_LW: begin
                sel <= 4'b0000;
				if (address[1:0] != 2'b00) begin
					adelM <= 1'b1;
					bad_addr <= address;
				end
            end
            `EXE_SB: begin //存字节
                write_data_out <= {{write_data_in[7:0]}, {write_data_in[7:0]}, {write_data_in[7:0]}, {write_data_in[7:0]}};
                case (address[1:0])
                    2'b00: sel <= 4'b0001;
                    2'b01: sel <= 4'b0010;
                    2'b10: sel <= 4'b0100;
                    2'b11: sel <= 4'b1000;
					default : /* default */;
                endcase
            end
            `EXE_SH: begin //存半字
                write_data_out <= {{write_data_in[15:0]}, {write_data_in[15:0]}};
				case (address[1:0])
					2'b00:sel <= 4'b0011;
					2'b10:sel <= 4'b1100;
					default :begin 
						adesM <= 1'b1;
						bad_addr <= address;
						sel <= 4'b0000;
					end 
				endcase
            end
            `EXE_SW: begin //存字
                write_data_out <= write_data_in;
				if(address[1:0] == 2'b00) begin
					/* code */
					sel <= 4'b1111;
				end else begin 
					adesM <= 1'b1;
					bad_addr <= address;
					sel <= 4'b0000;
				end
            end
            default: sel <= 4'b0000;
        endcase
    end
     always @(*) begin
        // 从内存读数据
        case (op)
            
            `EXE_LB: begin  //读字节 有符号扩展
                case (address[1:0])
                    2'b00: read_data_out <= {{24{read_data_in[7]}}, read_data_in[7:0]};
                    2'b01: read_data_out <= {{24{read_data_in[15]}}, read_data_in[15:8]};
                    2'b10: read_data_out <= {{24{read_data_in[23]}}, read_data_in[23:16]};
                    2'b11: read_data_out <= {{24{read_data_in[31]}}, read_data_in[31:24]};
                    default: /* default */;
                endcase
            end
            `EXE_LBU: begin  //读字节  无符号扩展
                case (address[1:0])
                    2'b00: read_data_out <= {24'b0, read_data_in[7:0]};
                    2'b01: read_data_out <= {24'b0, read_data_in[15:8]};
                    2'b10: read_data_out <= {24'b0, read_data_in[23:16]};
                    2'b11: read_data_out <= {24'b0, read_data_in[31:24]};
                    default: /* default */;
                endcase
            end 
            `EXE_LH: begin  //读半字 有符号扩展  
                case (address[1:0])
                    2'b00: read_data_out <= {{24{read_data_in[15]}}, read_data_in[15:0]};
                    2'b10: read_data_out <= {{24{read_data_in[31]}}, read_data_in[31:16]};
                    default: /* default */;
                endcase
            end 
            `EXE_LHU: begin  //读半字  无符号扩展
                case (address[1:0])
                    2'b00: read_data_out <= {24'b0, read_data_in[15:0]};
                    2'b10: read_data_out <= {24'b0, read_data_in[31:16]};
                    default: /* default */;
                endcase
            end
            `EXE_LW: read_data_out <= read_data_in; //读字
             default: /* default */;
        endcase
    end

endmodule
