import FIFO::*;
import FIFOF::*;
import BRAM::*;
import BRAMFIFO::*;
import Vector::*;
import Spram::*;

//import QuantizedMath::*;
//import DSPArith::*;

interface MainIfc;
	method Action uartIn(Bit#(8) data);
	method ActionValue#(Bit#(8)) uartOut;
	method Bit#(3) rgbOut;
endinterface



module mkMain(MainIfc);
	Clock curclk <- exposeCurrentClock;

	Reg#(Bit#(16)) dataInCnt <- mkReg(0);
	Vector#(4,Spram256KAIfc) spram <- replicateM(mkSpram256KA);
	FIFO#(Bit#(2)) spramReadIdxQ <- mkFIFO;

	FIFO#(Bit#(8)) bramQ <- mkSizedBRAMFIFO(256); 

	rule returnSpramData(dataInCnt[0] == 1);// ( dataInCnt >= 16 && dataInCnt < 32 );
		dataInCnt <= dataInCnt + 1;
		let ra = dataInCnt>>1;
		Bit#(2) ramidx = truncate(ra); 
		Bit#(14) subaddr = truncate(ra>>2);
		spram[ramidx].req(subaddr, ?, False, 4'b1111);
		spramReadIdxQ.enq(ramidx);
	endrule
	rule relaySpramData;
		spramReadIdxQ.deq;
		let idx = spramReadIdxQ.first;
		let d <- spram[idx].resp;

		//bramQ.enq(truncate(d));
		bramQ.enq(truncate(d)+45);
	endrule

	//FIFOF#(Bit#(8)) mirrorQ <- mkFIFOF;
	FIFO#(Bit#(8)) inQ <- mkFIFO;
	rule writeSpram(dataInCnt[0] == 0);// ( dataInCnt < 16 );
		inQ.deq;
		let data = inQ.first;

		Bit#(2) ramidx = truncate(dataInCnt>>1);
		Bit#(14) subaddr = truncate(dataInCnt>>3);
		
		dataInCnt <= dataInCnt + 1;
		spram[ramidx].req(subaddr, {data,data}, True, 4'b1111);
		//bramQ.enq(data);
	endrule

	method ActionValue#(Bit#(8)) uartOut;
		bramQ.deq;
		return bramQ.first;
	endmethod

	
	method Action uartIn(Bit#(8) data);
		inQ.enq(data);
	endmethod
	
	method Bit#(3) rgbOut;
		return 3'b111;
	endmethod
endmodule
