import FIFO::*;
import BRAM::*;
import Vector::*;
import Processor::*;
import MemorySystem::*;

interface MainIfc;
	method Action uartIn(Bit#(8) data);
	method ActionValue#(Bit#(8)) uartOut;
	method Bit#(3) rgbOut;
endinterface

module mkMain(MainIfc);
	FIFO#(Bit#(8)) relayUart <- mkFIFO;
	ProcessorIfc proc <- mkProcessor;
	BRAM2Port#(Bit#(8),Bit#(16)) mem <- mkBRAM2Server(defaultValue);
	rule rpReq;
		let r <- proc.memReq;
		let na = (r.addr>>2);
		if ( r.write ) begin
			mem.portA.request.put(BRAMRequest{write:True,responseOnWrite:?,address:truncate(na),datain:truncate(r.data)});
		end else begin
			mem.portA.request.put(BRAMRequest{write:False,responseOnWrite:?,address:truncate(na),datain:?});
		end
	endrule
	rule rpResp;
		let d <- mem.portA.response.get;
		proc.memResp(zeroExtend(d));
		relayUart.enq(truncate(d));
	endrule



	method Action uartIn(Bit#(8) data);
		//relayUart.enq(data);
		mem.portB.request.put(BRAMRequest{write:True,responseOnWrite:False,address:truncate(data),datain:zeroExtend(data)});
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
