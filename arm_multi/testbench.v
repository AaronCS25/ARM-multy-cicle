`timescale 1ns/1ns

module controller_tb;
	reg clk;
	reg reset;
	reg [31:12] Instr;
	reg [3:0] ALUFlags;
	wire PCWrite;
	wire MemWrite;
	wire RegWrite;
	wire IRWrite;
	wire AdrSrc;
	wire [1:0] RegSrc;
	wire [1:0] ALUSrcA;
	wire [1:0] ALUSrcB;
	wire [1:0] ResultSrc;
	wire [1:0] ImmSrc;
	wire [1:0] ALUControl;
	
	reg [31:0] RAM [63:0];
	reg [31:0] i;

	controller control_unit(
		.clk(clk),
		.reset(reset),
		.Instr(Instr),
		.PCWrite(PCWrite),
		.AdrSrc(AdrSrc),
		.MemWrite(MemWrite),
		.IRWrite(IRWrite),
		.ALUFlags(ALUFlags),	
		.ResultSrc(ResultSrc),
		.ALUControl(ALUControl),
		.ALUSrcA(ALUSrcA),
		.ALUSrcB(ALUSrcB),
		.ImmSrc(ImmSrc),
		.RegWrite(RegWrite),
		.RegSrc(RegSrc)
	);
	
	initial begin
		clk <= 0;
		#(1);
		clk <= 1;
		#(1);
	end

	initial begin
		$readmemh("memfile.asm",RAM);
		i = 0;
		ALUFlags = 4'b0100;
		reset = 1; #2; reset = 0;
	end

	always @(posedge clk)
		if (~reset & IRWrite) begin
			if (RAM[i] === 0)
				$finish;
			Instr = RAM[i][31:12];
			i = i + 1;
		end

    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars;
    end
endmodule