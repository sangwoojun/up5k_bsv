import FIFO::*;
import BRAM::*;
import BRAMFIFO::*;

import Spram::*;
import SimpleFloat::*;

interface MainIfc;
	method Action uartIn(Bit#(8) data);
	method ActionValue#(Bit#(8)) uartOut;
	method Bit#(3) rgbOut;
endinterface

module mkMain(MainIfc);
	Clock curclk <- exposeCurrentClock;

	Spram256KAIfc ram <- mkSpram256KA;
	FloatTwoOp floatMultiplier <- mkFloatMult;
	FloatTwoOp floatAdder <- mkFloatAdd;
	FIFO#(Bit#(8)) relayUartInQ <- mkFIFO;
	FIFO#(Bit#(8)) relayUartOutQ <- mkFIFO;
	
	FIFO#(Bit#(32)) floatingQ <- mkFIFO;
	Reg#(Bit#(32)) inputBuffer <- mkReg(0);
	Reg#(Bit#(2)) inputBufferCnt <- mkReg(0);
	Reg#(Bit#(32)) outputBuffer <- mkReg(0);
	Reg#(Bit#(2)) outputBufferCnt <- mkReg(0);

	rule ttt;

		let d <- ram.resp;
		relayUartInQ.enq(truncate(d));

	endrule
	// rule temporary;
	//
	// 	relayUartInQ.deq;
	// 	let d = relayUartInQ.first;
	// 	relayUartOutQ.enq(d);
	//
	// endrule
	rule readFloat;

		relayUartInQ.deq;
		let data = relayUartInQ.first;
		Bit#(32) nv = (inputBuffer>>8)|(zeroExtend(data)<<24);
		inputBuffer <= nv;
		if ( inputBufferCnt == 3 ) begin
			inputBufferCnt <= 0;
			floatMultiplier.put(unpack(nv), unpack(nv));
			// floatingQ.enq(unpack(nv));
		end else begin
			inputBufferCnt <= inputBufferCnt + 1;
		end

	endrule
	rule writeFloat;
		
		if ( outputBufferCnt > 0 ) begin
			outputBufferCnt <= outputBufferCnt - 1;
			Bit#(8) tmp = truncate(outputBuffer);
			outputBuffer <= (outputBuffer>>8);
			relayUartOutQ.enq(tmp);
		end else begin
			// floatingQ.deq;
			// let r = floatingQ.first;
			let r <- floatMultiplier.get;
			Bit#(8) tmp = truncate(pack(r));
			outputBuffer <= (pack(r)>>8);
			outputBufferCnt <= 3;
			relayUartOutQ.enq(tmp);
		end

	endrule
	method Action uartIn(Bit#(8) data);
		// $write( "urart in\n");
		relayUartInQ.enq(data);
		// if ( data[0] == 1 ) ram.req(zeroExtend(data), zeroExtend(data), True, 4'b1111);
		// else ram.req(zeroExtend(data), ?, False, ?);
		// $write( "uartIn %d\n", data);

	endmethod
	method ActionValue#(Bit#(8)) uartOut;
		// $write( "urart out\n");
		relayUartOutQ.deq;
		let d = relayUartOutQ.first;
		// $write( "uartOut %d\n", d );
		return d;

	endmethod
	method Bit#(3) rgbOut;

		return 0;

	endmethod
endmodule
