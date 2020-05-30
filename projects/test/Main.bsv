import FIFO::*;
import BRAM::*;
import BRAMFIFO::*;

import Spram::*;

interface MainIfc;
	method Action uartIn(Bit#(8) data);
	method ActionValue#(Bit#(8)) uartOut;
	method Bit#(3) rgbOut;
endinterface

module mkMain(MainIfc);
	Clock curclk <- exposeCurrentClock;

	Spram256KAIfc ram <- mkSpram256KA;
	FIFO#(Bit#(8)) relayUart <- mkFIFO;
	rule ttt;
		let d <- ram.resp;
		relayUart.enq(truncate(d));
	endrule
	method Action uartIn(Bit#(8) data);
		relayUart.enq(data);
		if ( data[0] == 1 ) ram.req(zeroExtend(data), zeroExtend(data), True, 4'b1111);
		else ram.req(zeroExtend(data), ?, False, ?);
		$write( "uartIn %d\n", data );
	endmethod
	method ActionValue#(Bit#(8)) uartOut;
		relayUart.deq;
		let d = relayUart.first;
		$write( "uartOut %d\n", d );
		return d;
	endmethod
	method Bit#(3) rgbOut;
		return 0;
	endmethod
endmodule
