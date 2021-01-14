`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/29 17:45:35
// Design Name: 
// Module Name: datapath
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

module datapath(
	input wire clk,rst,
	//F阶段
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//D阶段
	input wire pcsrcD,branchD,
	input wire jumpD,
	output wire equalD,
	output wire[31:0] instrD,
	//E阶段
	input wire memtoregE,
	input wire alusrcE,regdstE,
	input wire regwriteE,
	input wire[7:0] alucontrolE,
	//flush信号
	output wire flushE,flushM,flushW, 
	//M阶段
	input wire memtoregM,
	input wire regwriteM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] temp_readdataM,
	//W阶段
	input wire memtoregW,
	input wire regwriteW,
	//stall信号
	output wire stallE,stallM,stallW,
	//jal
	input jalD,jalE,
	//jr 
	input jrD,
	//jalr 需要使用 jrE
	input jrE,
	//rtd branch
	output wire [4:0] rtD,
	// 访存指令控制信号->选择字节
	output wire[3:0] sel,
	// 连接sram test 的信号
	output wire[31:0] pcW,
	output wire[4:0] writeregW,
	output wire[31:0] resultW,
	//异常处理信号
	input wire cp0_wD,
	input wire cp0_to_regE,
	input wire invalidD
    );
    
    
	
	//F阶段
	wire stallF,flushF;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD;
	wire [31:0] pcnextFDtmp;//pcnextFD	
	//D阶段	
	wire [5:0] opD,functD;
	wire [31:0] pcplus4D;
	wire [1:0]forwardaD,forwardbD;
	wire [4:0] rsD,rdD;
	wire flushD,stallD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;

	//E阶段
	wire [1:0] forwardaE,forwardbE,forward_hiloE;
	wire[5:0] opE;
	wire [4:0] rsE,rtE,rdE;
	wire [4:0] writeregE;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE;
	wire [31:0] resultM;

	//M阶段
	wire [4:0] writeregM;
	wire[5:0] opM;

	//W阶段
	wire [31:0] aluoutW,readdataW;
	wire [31:0] pcD, pcE, pcM;

//----------------------------------------------cp0--------------------------------------------------------------

    wire cp0_wE,cp0_wM;  
	wire delayD,delayE,delayM;
	wire whether_delay_instrM;     //instrM weather is delay 
	assign delayD=branchD | jrD | jalD | jumpD; 

	wire[`RegBus] excepttypeM;                                               //fixed in exception as output 
	wire[`RegBus] bad_addrM;                                                 //fixed in mem_controll as bad address output  
	
	wire [`RegBus] epc_o;                                                   // reback pc
	wire [`RegBus] data_o;                                                  // fixed as a alu input to mfc0
	
	wire [`RegBus] count_o,compare_o,config_o,prid_o,badvaddr,timer_int_o;  // useless
	wire [`RegBus] status_o,cause_o;                                        //  unknow and useless,just as a input in exception and nothing hanppend
	
	//mfc0 data forward
	wire [31:0] cp0data2E;
	wire forwardcp0E;
	wire [31:0] cp0dataE;
	assign cp0dataE = data_o;
	mux2 #(32) forwardcp0mux(cp0dataE,aluoutM,forwardcp0E,cp0data2E);
	
	//cp0 need varible
	wire [7:0] exceptF,exceptD,exceptE,exceptM;
	wire overflow;
	assign exceptF = (pcF[1:0] == 2'b00) ? 8'b00000000 : 8'b10000000;//the addr error
	wire syscallD,breakD,eretD;
	assign syscallD = (opD == 6'b000000 && functD == 6'b001100);
	assign breakD = (opD == 6'b000000 && functD == 6'b001101);
	assign eretD = (instrD == 32'b01000010000000000000000000011000);
	wire adelM,adesM;                                                              // data memery excep
	wire [31:0] newpcM;

	wire flush_except;
	assign flush_except = (excepttypeM != 32'b0);
	assign flushF=flush_except;
	// | (jumpD & ~jalD);   
	//jumpD and lwE result flushD ，but jalD with jumpD=1  shouldnot be flushDed 
	//also need to consider jalr rs  and   all branch
	assign flushD=(pcsrcD & ~jalD & ~stallD & !branchD) | flush_except; 
	assign flushM=flush_except;
	wire flushpcM;
	assign flushpcM=flush_except&(excepttypeM != 32'b1); 
	assign flushW=flush_except;                                                             

	flopenrc #(8)  exceptFD(clk,rst,~stallD,flushD,exceptF,exceptD);  //except for  cp0  _lh
	//++++  cp0_we  ,  delay   for except +++++++
	flopenrc #(1) cp0_wDE(clk,rst,~stallE,flushE,cp0_wD,cp0_wE);
	flopenr #(1)delayDE(clk,rst,~stallE,delayD,delayE);
	flopenrc #(8)  exceptDE(clk,rst,~stallE,flushE,  {exceptD[7],syscallD,breakD,eretD,invalidD,exceptD[2:0]},exceptE);
	//++++cp0_we for except +++++++

	//++++cp0_we,delay,rdM for except +++++++
	wire [4:0] rdM;
	flopenrc #(1) cp0_wEM(clk,rst,~stallM,flushM,cp0_wE,cp0_wM);//
	flopenr #(1) delayEM(clk,rst,~stallM,delayE,delayM);
	flopenrc #(5) rdEM(clk,rst,~stallM,flushM,rdE,rdM);
	flopenrc #(8)  exceptEM(clk,rst,~stallM,flushM,{exceptE[7:3],overflow,exceptE[1:0]},exceptM);  //todo: no flush

	flopenr #(1) delayMW(clk,rst,~stallW,delayM,whether_delay_instrM);
	
	//---------------------------------------------p0_we for except---------------------------------------------



	//PC 选择
	adder pcadd1(pcF,32'b100,pcplus4F);//pc+4
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD); //branch地址选择
	mux2 #(32) pcjumpmux(pcnextbrFD, 
		{pcplus4D[31:28],instrD[25:0],2'b00},  //jump跳转地址计算与选择：立即数左移两位后与pc高四位拼接
		jumpD,pcnextFDtmp);
    mux2 #(32) pcjrmux(pcnextFDtmp,srca2D,jrD,pcnextFD);//jr地址选择：对R型跳转指令（jr  jalr）使用寄存器堆
	pc #(32) pcreg(clk,rst,~stallF,flushF,newpcM,pcnextFD,pcF);	
	//pc传递
	flopenrc #(32) pcFD(clk,rst,~stallD,flushD,pcF,pcD); 	
	flopenrc #(32) pcDE(clk,rst,~stallE,flushE,pcD,pcE);
	flopenrc #(32) pcEM(clk,rst,~stallM,flushpcM,pcE,pcM);
	flopenrc #(32) pcMW(clk,rst,~stallW,flushW,pcM,pcW);

	flopenrc #(32) pcplus4FD(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);// pc+4


	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];

	flopenrc #(5) rsDE(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5) rtDE(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5) rdDE(clk,rst,~stallE,flushE,rdD,rdE);	
	assign opD = instrD[31:26];
	flopenrc #(6) opDE(clk,rst,~stallE,flushE,opD,opE);
	flopenrc #(6) opEM(clk,rst,~stallM,flushM,opE,opM);
	
	//--------------------sa-------------------sll srl sra使用
	wire [4:0] saD;
	assign saD = instrD[10:6];
	wire [4:0] saE;
	flopenrc #(5) saDE(clk,rst,~stallE,flushE,saD,saE);
	//--------------------sa--------------------


	//寄存器堆
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);
	//数据前推
	mux4 #(32) forwardamux(srcaD,aluoutE,resultM,resultW,forwardaD,srca2D);
	mux4 #(32) forwardbmux(srcbD,aluoutE,resultM,resultW,forwardbD,srcb2D);	

	//判断branch指令的数字比较结果  采用延迟分支的方法解决控制冒险
	eqcmp comp(srca2D,srcb2D,opD,rtD,equalD);

	flopenrc #(32) srca2DE(clk,rst,~stallE,flushE,srca2D,srcaE);
	flopenrc #(32) srcb2DE(clk,rst,~stallE,flushE,srcb2D,srcbE);
	//ALU数据来源的数据冒险处理
	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);// ALU A端处理，rd1E(00),resultW(01)，aluoutM(10)
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);// ALU B端处理，rd1E(00),resultW(01)，aluoutM(10)
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);//B端多选

	flopenrc #(32) instrFD(clk,rst,~stallD,flushD,instrF,instrD); //instr

	//符号扩展：指令andi  xori lui ori 需要无符号扩展，只有他们的29：28位为11
	sign_extend se(instrD[15:0],instrD[29:28],signimmD); 
	//立即数左移两位
	sl2 immsh(signimmD,signimmshD);  
	adder pcadd2(pcplus4D,signimmshD,pcbranchD); //计算branch地址
	flopenrc #(32) signimmDE(clk,rst,~stallE,flushE,signimmD,signimmE); //向后传递



	//选择写入的寄存器是31号寄存器（al型指令）还是rd字段寄存器	
    wire [4:0] reg31=5'b11111;
	wire [4:0] writeregEtmp,writeregEtmp2;// writeregE
	mux2 #(5) wrmux(rtE,rdE,regdstE,writeregEtmp);
	mux2 #(5) wrmux2(writeregEtmp,reg31,jalE,writeregEtmp2);  //jal 选择31号寄存器
	assign writeregE=(jalE & jrE)? (rdE==5'b00000 ? reg31 : rdE) : writeregEtmp2;   //jalr rd=00000 -> rd=31
	flopenrc #(5) writeregEM(clk,rst,~stallM,flushM,writeregE,writeregM);
	flopenrc #(5) writeregMW(clk,rst,~stallW,flushW,writeregM,writeregW);	

//------------------------------------访存控制-----------------------------
	wire[31:0] temp_writedataM;
	flopenrc #(32) writedataEM(clk,rst,~stallM,flushM,srcb2E,temp_writedataM);
	wire[31:0] readdataM;
	mem_controller memc(
		.op(opM),
		.address(aluoutM),
		.write_data_in(temp_writedataM), 
		.write_data_out(writedataM), 
		.read_data_in(temp_readdataM), 
		.read_data_out(readdataM), 
		.sel(sel),
		.bad_addr(bad_addrM),
		.adelM(adelM),
		.adesM(adesM),
		.pc(pcM)
		);
	mux2 #(32) resultmux(aluoutM,readdataM,memtoregM,resultM);
	flopenrc #(32) readdataMW(clk,rst,~stallW,flushW,readdataM,readdataW);
	flopenrc #(32) resultMW(clk,rst,~stallW,flushW,resultM,resultW);	
	// mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);


	//除法信号
    wire annul_i,stallDivE,ready_o;
    assign stallDivE=(~ready_o) & (alucontrolE==`EXE_DIV_OP | alucontrolE==`EXE_DIVU_OP);
    assign annul_i=0;

	//------------------------------hilo-----------------------------
	wire [7:0] alucontrolM;
	wire [63:0] alu_hilo_oM;
	wire [63:0] alu_hilo_oE;
	flopenrc #(8) alucontrolEM(clk,rst,~stallM,flushM,alucontrolE,alucontrolM);
	flopenrc #(64) alu_hilo_oEM(clk,rst,~stallM,flushM,alu_hilo_oE,alu_hilo_oM);
	wire [7:0] alucontrolW;
	wire [63:0] alu_hilo_oW;
	flopenrc #(8) alucontrolMW(clk,rst,~stallW,flushW,alucontrolM,alucontrolW);
	flopenrc #(64) alu_hilo_oMW(clk,rst,~stallW,flushW,alu_hilo_oM,alu_hilo_oW);

    wire [31:0] hi_o;
    wire [31:0] lo_o;
    hilo_reg hilo(
    .clk(~clk),
    .rst(rst),
    .alucontrol(alucontrolW),
    .hi(alu_hilo_oW[63:32]),
    .lo(alu_hilo_oW[31:0]),
    .hi_o(hi_o),.lo_o(lo_o)
    );

	//hilo_reg需要数据前推，否则独立测试数据移动指令时就会读错数据
	//--------------------------forword hilo--------------------------
	wire [63:0] alu_hilo_iE;
	wire [63:0] hilo_o64={{hi_o,lo_o}};
	mux3 #(64) forwardhiloemux(hilo_o64,alu_hilo_oM,alu_hilo_oW,forward_hiloE,alu_hilo_iE);
	

	//-----------------------jal pcplus8-------------------
	wire [31:0] pcplus8E;
	flopenrc #(32) pcplus8DE(clk,rst,~stallE,flushE,pcplus4D +32'b100,pcplus8E);//pc+8    
	wire [31:0] aluoutEtmp;//as alu aluoutE
    mux2 #(32) aluPC8Emux(aluoutEtmp,pcplus8E,jalE,aluoutE);
	flopenrc #(32) aluoutEM(clk,rst,~stallM,flushM,aluoutE,aluoutM);
	flopenrc #(32) aluoutMW(clk,rst,~stallW,flushW,aluoutM,aluoutW);


	//--------------------------alu------------------------

	alu alu(
		.a(srca2E),
		.b(srcb3E),
		.alucontrol(alucontrolE),
		.sa(saE),
		.y(aluoutEtmp),
		.overflow(overflow),
		.alu_hilo_in(alu_hilo_iE),
		.alu_hilo_out(alu_hilo_oE),
		.clk(clk),
		.rst(rst),
		.annul_i(annul_i),
		.ready_o(ready_o),
		.cp0_data_o_in(cp0data2E));

	//--------------------------alu------------------------


	
	//---------------------------------------------- hazard ----------------------------------------------------
	hazard h(
		//fetch stage
		.stallF(stallF),
		//decode stage
		.rsD(rsD),
		.rtD(rtD),
		.branchD(branchD),
		.forwardaD(forwardaD),
		.forwardbD(forwardbD),
		.stallD(stallD),//ok
		//execute stage
		.rsE(rsE),
		.rtE(rtE),
		.writeregE(writeregE),
		.regwriteE(regwriteE),
		.memtoregE(memtoregE),
		.forwardaE(forwardaE),
		.forwardbE(forwardbE),
		.flushE(flushE),
		//mem stage
		.writeregM(writeregM),
		.regwriteM(regwriteM),
		.memtoregM(memtoregM),
		//write back stage
		.writeregW(writeregW),
		.regwriteW(regwriteW),
		//hilo
		.alucontrolE(alucontrolE),
		.alucontrolM(alucontrolM),
		.alucontrolW(alucontrolW),
		.forward_hiloE(forward_hiloE),
		//div
		.stall_divE(stallDivE),
		.stallE(stallE),
		.stallM(stallM),
		.stallW(stallW),
		//cp0 forward
		.rdE(rdE),
		.rdM(rdM),
		.cp0weM(cp0_wM),
		.forwardcp0E(forwardcp0E),
		//cp0 util
		.excepttypeM(excepttypeM),
		.cp0_epcM(epc_o),
		.newpcM(newpcM),
		.cp0_to_regE(cp0_to_regE)
		);

	//---------------------------------------cp0-------------------------------------
	exception exp(
		.rst(rst),
		.except(exceptM),
		.adel(adelM),
		.ades(adesM),
		.cp0_status(status_o),
		.cp0_cause(cause_o),
		.excepttype(excepttypeM)
		);
	cp0_reg cp0(.clk(~clk),.rst(rst),
	           .we_i(cp0_wM),
	           .waddr_i(rdM),.raddr_i(rdE),
	           .data_i(aluoutM),.int_i(6'b000000),
	           .excepttype_i(excepttypeM),                         //todo:        unfixed
	           .current_inst_addr_i(pcM),
	           .is_in_delayslot_i(whether_delay_instrM),
	           .bad_addr_i(bad_addrM),                              //todo:        unfixed
	           .data_o(data_o),
	           .count_o(count_o),
	           .compare_o(compare_o),
	           .status_o(status_o),
	           .cause_o(cause_o),
		       .epc_o(epc_o),
		       .config_o(config_o),
		       .prid_o(prid_o),
		       .badvaddr(badvaddr),
		       .timer_int_o(timer_int_o));                           
	
endmodule


