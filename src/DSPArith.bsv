interface SbMac16ImportIfc;
endinterface

interface Mult16x16ImportIfc;
	method Action put(Bit#(16) a, Bit#(16) b);
	method Bit#(32) get;
endinterface

interface Mult16x16Ifc;
	method ActionValue#(Bit#(32)) calc (Bit#(16) a, Bit#(16) b);
endinterface

import "BVI" SB_MAC16 =
module mkMult16x16Import#(Clock clk, Reset rst) (Mult16x16ImportIfc);

	input_clock (CLK) = clk;
	default_clock clk;
	default_reset no_reset;
	
	method put(A, B) enable((*inhigh*)en1) ;
	method O get;

	port CE = 1'b1;

	port C = 16'b0;
	port CHOLD = 1'b0;
	port D = 16'b0;
	port DHOLD = 1'b0;

	port AHOLD = 1'b0;
	port BHOLD = 1'b0;

	port IRSTTOP = 1'b0;
	port ORSTTOP = 1'b0;
	port OLOADTOP = 1'b0;
	port ADDSUBTOP = 1'b0;
	port OHOLDTOP = 1'b0;

	port IRSTBOT = 1'b0;
	port ORSTBOT = 1'b0;
	port OLOADBOT = 1'b0;
	port ADDSUBBOT = 1'b0;
	port OHOLDBOT = 1'b0;
	port CI = 1'b0;
	port ACCUMCI = 1'b0;
	port SIGNEXTIN = 1'b0;

/*
	parameter A_REG = 0;
	parameter B_REG = 0;
	parameter C_REG = 0;
	parameter D_REG = 0;
	parameter TOP_8x8_MULT_REG = 0;
	parameter BOT_8x8_MULT_REG = 0;
	parameter PIPELINE_16x16_MULT_REG1 = 0;
	*/
	//parameter PIPELINE_16x16_MULT_REG2 = 1; // output registered
	parameter PIPELINE_16x16_MULT_REG2 = 0; // output NOT registered
	parameter TOPOUTPUT_SELECT = 2'b11; // 16x16 multiplier
	parameter BOTOUTPUT_SELECT = 2'b11; // 16x16 multiplier
	parameter A_SIGNED = 2'b0; // unsigned A
	parameter B_SIGNED = 1'b0; // unsigned B

	schedule (
		put
	) SB (
		get
	);
endmodule

module mkMult16x16 (Mult16x16Ifc);
	Clock curclk <- exposeCurrentClock;
	Reset currst <- exposeCurrentReset;

`ifdef BSIM
	method ActionValue#(Bit#(32)) calc (Bit#(16) a, Bit#(16) b);
		return zeroExtend(a) * zeroExtend(b);
	endmethod
`else
	Mult16x16ImportIfc dsp_mult <- mkMult16x16Import(curclk, currst);
	
	method ActionValue#(Bit#(32)) calc (Bit#(16) a, Bit#(16) b);
		dsp_mult.put(a,b);
		return dsp_mult.get;
	endmethod
`endif
endmodule




interface IntMult16x16ImportIfc;
	method Action put(Int#(16) a, Int#(16) b);
	method Int#(32) get;
endinterface

interface IntMult16x16Ifc;
	method ActionValue#(Int#(32)) calc (Int#(16) a, Int#(16) b);
endinterface

import "BVI" SB_MAC16 =
module mkIntMult16x16Import#(Clock clk, Reset rst) (IntMult16x16ImportIfc);

	input_clock (CLK) = clk;
	default_clock clk;
	default_reset no_reset;
	
	method put(A, B) enable((*inhigh*)en1) ;
	method O get;

	port CE = 1'b1;

	port C = 16'b0;
	port CHOLD = 1'b0;
	port D = 16'b0;
	port DHOLD = 1'b0;

	port AHOLD = 1'b0;
	port BHOLD = 1'b0;

	port IRSTTOP = 1'b0;
	port ORSTTOP = 1'b0;
	port OLOADTOP = 1'b0;
	port ADDSUBTOP = 1'b0;
	port OHOLDTOP = 1'b0;

	port IRSTBOT = 1'b0;
	port ORSTBOT = 1'b0;
	port OLOADBOT = 1'b0;
	port ADDSUBBOT = 1'b0;
	port OHOLDBOT = 1'b0;
	port CI = 1'b0;
	port ACCUMCI = 1'b0;
	port SIGNEXTIN = 1'b0;

/*
	parameter A_REG = 0;
	parameter B_REG = 0;
	parameter C_REG = 0;
	parameter D_REG = 0;
	parameter TOP_8x8_MULT_REG = 0;
	parameter BOT_8x8_MULT_REG = 0;
	parameter PIPELINE_16x16_MULT_REG1 = 0;
	*/
	//parameter PIPELINE_16x16_MULT_REG2 = 1; // output registered
	parameter PIPELINE_16x16_MULT_REG2 = 0; // output NOT registered
	parameter TOPOUTPUT_SELECT = 2'b11; // 16x16 multiplier
	parameter BOTOUTPUT_SELECT = 2'b11; // 16x16 multiplier
	parameter A_SIGNED = 2'b1; // signed A
	parameter B_SIGNED = 1'b1; // signed B

	schedule (
		put
	) SB (
		get
	);
endmodule

module mkIntMult16x16 (IntMult16x16Ifc);
	Clock curclk <- exposeCurrentClock;
	Reset currst <- exposeCurrentReset;

`ifdef BSIM
	method ActionValue#(Int#(32)) calc (Int#(16) a, Int#(16) b);
		return zeroExtend(a) * zeroExtend(b);
	endmethod
`else
	IntMult16x16ImportIfc dsp_mult <- mkIntMult16x16Import(curclk, currst);
	
	method ActionValue#(Int#(32)) calc (Int#(16) a, Int#(16) b);
		dsp_mult.put(a,b);
		return dsp_mult.get;
	endmethod
`endif
endmodule

