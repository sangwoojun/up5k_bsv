import FIFO::*;
import BRAM::*;
import BRAMFIFO::*;

//import PredictiveMaintenance::*;
import Spram::*;
import QuantizedMath::*;
import DSPArith::*;

interface MainIfc;
	method Action uartIn(Bit#(8) data);
	method ActionValue#(Bit#(8)) uartOut;
	method Bit#(3) rgbOut;
endinterface



module mkMain(MainIfc);
	Clock curclk <- exposeCurrentClock;

	FIFO#(Int#(8)) inQ1 <- mkFIFO;
	FIFO#(Int#(8)) inQ2 <- mkFIFO;
	FIFO#(Int#(8)) inQ3 <- mkFIFO;
	FIFO#(Int#(8)) midQ1 <- mkFIFO;
	FIFO#(Int#(8)) midQ2 <- mkFIFO;
	FIFO#(Int#(8)) outQ <- mkFIFO;
	FIFO#(Int#(16)) midQW <- mkFIFO;

	Reg#(Bit#(8)) dataInCnt <- mkReg(0);
	//QuantizedMathIfc ar <- mkQuantizedMath;
	IntMult16x16Ifc dsp_mult <- mkIntMult16x16;
	rule tryMult;
		inQ1.deq;
		inQ2.deq;
		let qm <- dsp_mult.calc(zeroExtend(inQ1.first), zeroExtend(inQ2.first));
		midQW.enq(truncate(qm));
		//outQ.enq(inQ1.first);
	endrule
	Reg#(Int#(16)) calcout <- mkReg(0);
	rule relayout;
		if ( calcout > 0 ) begin
			Int#(8) nnn = unpack(extend(pack(calcout)[3:0]));
			outQ.enq(48+nnn);
			calcout <= (calcout>>4);
		end else begin
			calcout <= midQW.first;
			midQW.deq;
			outQ.enq(32);
		end
	endrule

/*
	rule tryMult;
		inQ1.deq;
		inQ2.deq;
		let qm <- ar.quantizedMult(inQ1.first, inQ2.first);
		midQ1.enq(qm);
	endrule
	rule tryAdd;
		midQ1.deq;
		inQ3.deq;
		midQ2.enq(ar.quantizedAdd(midQ1.first, inQ3.first));
	endrule
	rule trySig;
		midQ2.deq;
		let sr <- ar.hardSigmoid(midQ2.first);
		outQ.enq(sr);
	endrule
	*/
	


	Reg#(Bit#(16)) val <- mkReg(0);
	
	method ActionValue#(Bit#(8)) uartOut;
		outQ.deq;
		return pack(outQ.first);
	endmethod
	
	//Method transfers data to predictiveMaintenance to be processed as weights until all weights have been processed, then subsequent data is transferred to be processed as input
	method Action uartIn(Bit#(8) data) ;
		if ( data >= 48 && data <= 57 ) begin // '0' ~ '9'
			let v = ((val<<4) | (zeroExtend(data)-48));
			if ( v < 16'h1000 ) begin
				val <= v;
			end else begin
				val <= 0;
				inQ1.enq(unpack(truncate(v)));
				inQ2.enq(unpack(truncate(v>>8)));
			end
			outQ.enq(unpack(data));
		end else if ( data == 13 || data == 10 || data == 32 ) outQ.enq(unpack(data));
		/*
		if ( dataInCnt == 0 ) begin
			//dataInCnt <= 1;
			//inQ1.enq(unpack(data));
			inQ1.enq(unpack(data&8'b1111));
		end else if ( dataInCnt == 1 ) begin
			dataInCnt <= 0;
			//inQ2.enq(unpack(data));
			inQ2.enq(unpack(data&8'b1111));
		end else begin
			dataInCnt <= 3;
			inQ3.enq(unpack(data));
		end
		*/
	endmethod
	
	method Bit#(3) rgbOut;
		//0 when idle
		//1 when receiving weights
		//2 when input is being received
		//3 when LSTM1 is running
		//4 when LSMT2 is running
		//5 when Dense is running
		//6 when PredictiveMaintenance is done.
		
		return 0;
	endmethod
endmodule
