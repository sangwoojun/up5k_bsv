import DSPArith::*;
import FIFO::*;
	
Integer invscale = 42;
Int#(16) zeropoint = 0;
Int#(8) onepoint = 102; //1.0f

function Int#(8) quantizedAddInternal(Int#(8) x, Int#(8) y);
	Int#(16) sx = signExtend(x) - signExtend(zeropoint);
	Int#(16) sy = signExtend(y) - signExtend(zeropoint);
	let dx = sx>>1;
	let dy = sy>>1;
	let s = dx + dy;
	let s2 = s<<1;
	return truncate(s2 + zeropoint);
endfunction

interface QuantizedMathIfc;
	method ActionValue#(Int#(8)) quantizedMult(Int#(8) x, Int#(8) y);
	method Int#(8) quantizedAdd(Int#(8) x, Int#(8) y);
	method ActionValue#(Int#(8)) hardSigmoid(Int#(8) d);
endinterface

module mkQuantizedMath (QuantizedMathIfc);
	IntMult16x16Ifc dsp_mult <- mkIntMult16x16;
	IntMult16x16Ifc dsp_mult_sig <- mkIntMult16x16;

	
	method ActionValue#(Int#(8)) quantizedMult(Int#(8) x, Int#(8) y);
		Int#(16) sx = signExtend(x);
		Int#(16) sy = signExtend(y);
		let p = sx * sy;
		//let s = p >> 7;// / invscale;
		//let s = p  / invscale;
		Int#(32) s <- dsp_mult.calc(p, fromInteger(65536/invscale));
		Int#(16) st = truncate(s>>16);
		return truncate(st + zeropoint);
	endmethod
	method Int#(8) quantizedAdd(Int#(8) x, Int#(8) y);
		return quantizedAddInternal(x,y);
	endmethod
	method ActionValue#(Int#(8)) hardSigmoid(Int#(8) d);
		Int#(8) lowerlimit = -1;//-2.5f
		Int#(8) upperlimit = 1;//2.5f
		Int#(8) alpha = 20; //0.2f
		Int#(8) offset = 51;//0.5f
		let multr <- dsp_mult_sig.calc(zeroExtend(alpha), zeroExtend(d));

		if (d <= lowerlimit) return truncate(zeropoint);
		else if (d >= upperlimit) return onepoint;
		else return quantizedAddInternal(truncate(multr), offset);
	endmethod
endmodule


/*
function Int#(8) quantizedMult(Int#(8) x, Int#(8) y);
	Int#(16) sx = signExtend(x);
	Int#(16) sy = signExtend(y);
	let p = sx * sy;
	//let s = p >> 7;// / invscale;
	//let s = p  / invscale;
	Int#(32) s = (zeroExtend(p) * fromInteger(65536/invscale));
	Int#(16) st = truncate(s>>16);
	//Int#(16) st = p>>5;
	return truncate(st + zeropoint);
endfunction

function Int#(8) quantizedAdd(Int#(8) x, Int#(8) y);

	Int#(16) sx = signExtend(x);// - signExtend(zeropoint);
	Int#(16) sy = signExtend(y);// - signExtend(zeropoint);
	let dx = sx>>1;
	let dy = sy>>1;
	let s = dx + dy;
	let s2 = s<<1;
	return truncate(s2);// + zeropoint);
endfunction

function Int#(8) hardSigmoid(Int#(8) d);

	Int#(8) lowerlimit = -1;//-2.5f
	Int#(8) upperlimit = 1;//2.5f
	Int#(8) alpha = 20; //0.2f
	Int#(8) offset = 51;//0.5f
	if (d <= lowerlimit) return truncate(zeropoint);
	else if (d >= upperlimit) return onepoint;
	else return quantizedAdd(quantizedMult(alpha, d), offset);
endfunction	
*/
