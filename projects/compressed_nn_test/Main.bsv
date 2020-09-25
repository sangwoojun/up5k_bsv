import FIFO::*;
import BRAM::*;
import BRAMFIFO::*;

//import PredictiveMaintenance::*;
import Spram::*;
import QuantizedMath::*;

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

	Reg#(Bit#(8)) dataInCnt <- mkReg(0);
	LSTMArithIfc ar <- mkLSTMArith;

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
	

	
	method ActionValue#(Bit#(8)) uartOut;
		outQ.deq;
		return pack(outQ.first);
	endmethod
	
	//Method transfers data to predictiveMaintenance to be processed as weights until all weights have been processed, then subsequent data is transferred to be processed as input
	method Action uartIn(Bit#(8) data) ;
		if ( dataInCnt == 0 ) begin
			dataInCnt <= 1;
			inQ1.enq(unpack(data));
		end else if ( dataInCnt == 1 ) begin
			dataInCnt <= 2;
			inQ2.enq(unpack(data));
		end else begin
			dataInCnt <= 3;
			inQ3.enq(unpack(data));
		end
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
