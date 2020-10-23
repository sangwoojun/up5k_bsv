import FIFO::*;
import BRAM::*;
import BRAMFIFO::*;

import QuantizedMath::*;
import DSPArith::*;

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

	rule returnSpramData ( dataInCnt >= 16 && dataInCnt < 32 );
		dataInCnt <= dataInCnt + 1;
		let ra = dataInCnt-16;
		Bit#(2) ramidx = truncate(ra); 
		Bit#(14) subaddr = truncate(ra>>2);
		spramReadIdxQ.enq(ramidx);
	endrule
	rule relaySpramData;
		spramReadIdxQ.deq;
		let idx = spramReadIdxQ.first;
		let d <- spram[idx].resp;

		bramQ.enq(truncate(d));
	endrule


	method ActionValue#(Bit#(8)) uartOut;
		bramQ.deq;
		return bramQ.first;
	endmethod

	
	method Action uartIn(Bit#(8) data);
		Bit#(2) ramidx = truncate(dataInCnt);
		Bit#(14) subaddr = truncate(dataInCnt>>2);
		
		if ( dataInCnt + 1 < 16 ) begin
			dataInCnt <= dataInCnt + 1;
			spram[ramidx].req(subaddr, {0,,data}, True, 4'b1111);
		end
	endmethod
	
	method Bit#(3) rgbOut;
		return 0;
	endmethod
endmodule
