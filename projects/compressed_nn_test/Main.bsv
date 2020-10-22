import FIFO::*;
import BRAM::*;
import BRAMFIFO::*;

import LSTMCell::*;
import QuantizedMath::*;
import DSPArith::*;

interface MainIfc;
	method Action uartIn(Bit#(8) data);
	method ActionValue#(Bit#(8)) uartOut;
	method Bit#(3) rgbOut;
endinterface



module mkMain(MainIfc);
	Clock curclk <- exposeCurrentClock;

	LSTMCell8bIfc lstmcell <- mkLSTMCell8b;

	/*
	SpramManagerIfc spram <- mkSpramManager;


	Reg#(Bit#(17)) weightAddr <- mkReg(0);
	Reg#(Bit#(8)) weightWriteBuffer <- mkReg(0);

	rule relayWeightD ( weightAddr >= 1024 && weightAddr < 2048 );
		spram.read(truncate(weightAddr&17'b1111111111));
		weightAddr <= weightAddr + 1;
	endrule
	FIFO#(Bit#(8)) outQ <- mkFIFO;
	Reg#(Maybe#(Bit#(8))) outD <- mkReg(tagged Invalid);
	rule serializeSpramOut ( !isValid(outD) );
		let v <- spram.resp;
		outD <= tagged Valid (truncate(v));
		outQ.enq(truncate(v>>8));
	endrule
	rule serializeSpramOut2 ( isValid(outD) );
		outQ.enq(fromMaybe(?,outD));
	endrule
	*/



	method ActionValue#(Bit#(8)) uartOut;
		let v <- lstmcell.getResult;
		return v;
	endmethod

	
	method Action uartIn(Bit#(8) data);
		lstmcell.cmd(data);
	endmethod
	
	method Bit#(3) rgbOut;
		return 0;
	endmethod
endmodule
