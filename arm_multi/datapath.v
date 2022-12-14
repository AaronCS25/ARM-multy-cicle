`include "flopenr.v"
`include "flopr.v"
`include "mux3.v"
`include "mux2.v"
`include "regfile.v"
`include "extend.v"
`include "alu.v"

// ADD CODE BELOW
// Complete the datapath module below for Lab 11.
// You do not need to complete this module for Lab 10.
// The datapath unit is a structural SystemVerilog module. That is,
// it is composed of instances of its sub-modules. For example,
// the instruction register is instantiated as a 32-bit flopenr.
// The other submodules are likewise instantiated. 
module datapath (
	clk,
	reset,
	Adr,
	WriteData,
	ReadData,
	Instr,
	ALUFlags,
	PCWrite,
	RegWrite,
	IRWrite,
	AdrSrc,
	RegSrc,
	ALUSrcA,
	ALUSrcB,
	ResultSrc,
	ImmSrc,
	ALUControl
);
	input wire clk;
	input wire reset;
	output wire [31:0] Adr;
	output wire [31:0] WriteData;
	input wire [31:0] ReadData;
	output wire [31:0] Instr;
	output wire [3:0] ALUFlags;
	input wire PCWrite;
	input wire RegWrite;
	input wire IRWrite;
	input wire AdrSrc;
	input wire [1:0] RegSrc;
	input wire [1:0] ALUSrcA;
	input wire [1:0] ALUSrcB;
	input wire [1:0] ResultSrc;
	input wire [1:0] ImmSrc;
	input wire [1:0] ALUControl;
	wire [31:0] PCNext;
	wire [31:0] PC;
	wire [31:0] ExtImm;
	wire [31:0] SrcA;
	wire [31:0] SrcB;
	wire [31:0] Result;
	wire [31:0] Data;
	wire [31:0] RD1;
	wire [31:0] RD2;
	wire [31:0] A;
	wire [31:0] ALUResult;
	wire [31:0] ALUOut;
	wire [3:0] RA1;
	wire [3:0] RA2;

	// Your datapath hardware goes below. Instantiate each of the 
	// submodules that you need. Remember that you can reuse hardware
	// from previous labs. Be sure to give your instantiated modules 
	// applicable names such as pcreg (PC register), adrmux 
	// (Address Mux), etc. so that your code is easier to understand.

	flopenr #(32) pcreg(
		.clk(clk),
		.reset(reset),
		.d(PCNext),
		.q(PC)
	);
	mux2 #(32) pcmux(
		.d0(PC),
		.d1(Result),
		.s(AdrSrc),
		.y(Adr)
	);
	flopenr #(32) rdreg1(
		.clk(clk),
		.reset(reset),
		.d(ReadData),
		.q(Instr)
	);
	flopr #(32) rdreg2(
		.clk(clk),
		.reset(reset),
		.d(ReadData),
		.q(Data)
	);
	mux2 #(4) ra1mux(
		.d0(Instr[19:16]),
		.d1(2'b1110),
		.s(RegSrc[0]),
		.y(RA1)
	);
	mux2 #(4) ra2mux(
		.d0(Instr[3:0]),
		.d1(Instr[15:12]),
		.s(RegSrc[1]),
		.y(RA2)
	);
	regfile rf(
		.clk(clk),
		.we3(RegWrite),
		.ra1(RA1),
		.ra2(RA2),
		.wa3(Instr[15:12]),
		.wd3(Result),
		.r15(Result),
		.rd1(RD1),
		.rd2(RD2)
	);
	flopr #(32) rd1reg(
		.clk(clk),
		.reset(reset),
		.d(RD1),
		.q(A)
	);
	flopr #(32) rd2reg(
		.clk(clk),
		.reset(reset),
		.d(RD2),
		.q(WriteData)
	);
	extend ext(
		.Instr(Instr[23:0]),
		.ImmSrc(ImmSrc),
		.ExtImm(ExtImm)
	);
	mux3 rd1mux(
		.d0(A),
		.d1(PC),
		.d2(ALUOut),
		.s(ALUSrcA),
		.y(SrcA)
	);
	mux3 rd2mux(
		.d0(WriteData),
		.d1(ExtImm),
		.d2(2'b0000000000000000000000000000100),
		.s(ALUSrcB),
		.y(SrcB)
	);
	alu alu(
		.a(SrcA),
		.b(SrcB),
		.ALUControl(ALUControl),
		.Result(ALUResult),
		.ALUFlags(ALUFlags)
	);
	flopr #(32) aluflopr(
		.clk(clk),
		.reset(reset),
		.d(ALUResult),
		.q(ALUOut)
	);
	mux3 alumux(
		.d0(ALUOut),
		.d1(Data),
		.d2(ALUResult),
		.s(ResultSrc),
		.y(Result)
	);
endmodule