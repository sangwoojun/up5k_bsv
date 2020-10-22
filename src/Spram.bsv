import FIFO::*;
import FIFOF::*;
import RegFile::*;

interface Spram256KAImportIfc;
	method Action address(Bit#(14) address);
	method Action datain(Bit#(16) data);
	method Action maskwrin(Bit#(4) mask);
	method Action wren(Bit#(1) wren);
	method Action chipselect(Bit#(1) sel);
	method Bit#(16) dataout;

	method Action standby(Bit#(1) standby);
	method Action sleep(Bit#(1) sleep);
	method Action poweroff(Bit#(1) poweroff);
endinterface

import "BVI" SB_SPRAM256KA =
module mkSpram256KAImport#(Clock clk)(Spram256KAImportIfc);
	default_clock no_clock;
	default_reset no_reset;

	input_clock (CLOCK) = clk;

	method DATAOUT dataout;
	method address(ADDRESS) enable((*inhigh*) addr_EN) reset_by(no_reset) clocked_by(clk);
	method datain(DATAIN) enable((*inhigh*) datain_EN) reset_by(no_reset) clocked_by(clk);
	method maskwrin(MASKWREN) enable((*inhigh*) maskwrin_EN) reset_by(no_reset) clocked_by(clk);
	method wren(WREN) enable((*inhigh*) wren_EN) reset_by(no_reset) clocked_by(clk);
	method chipselect(CHIPSELECT) enable((*inhigh*) chipselect_EN) reset_by(no_reset) clocked_by(clk);
	
	method standby(STANDBY) enable((*inhigh*) standby_EN) reset_by(no_reset) clocked_by(clk);
	method sleep(SLEEP) enable((*inhigh*) sleep_EN) reset_by(no_reset) clocked_by(clk);
	method poweroff(POWEROFF) enable((*inhigh*) poweroff_EN) reset_by(no_reset) clocked_by(clk);
	schedule (
		dataout, address, datain, maskwrin, wren, chipselect, standby, sleep, poweroff
	) CF (
		dataout, address, datain, maskwrin, wren, chipselect, standby, sleep, poweroff
	);
endmodule

interface Spram256KAIfc;
	method Action req(Bit#(14) addr, Bit#(16) data, Bool write, Bit#(4) mask);
	method ActionValue#(Bit#(16)) resp;
endinterface

module mkSpram256KA(Spram256KAIfc);
	Clock curclk <- exposeCurrentClock;
	FIFOF#(Bit#(16)) outQ <- mkFIFOF;

	Wire#(Tuple4#(Bit#(14), Bit#(16), Bool, Bit#(4))) reqWire <- mkDWire(tuple4(0,0,False,0));
	//FIFOF#(Tuple4#(Bit#(14), Bit#(16), Bool, Bit#(4))) inQ <- mkFIFOF;
	//FIFOF#(Bool) readValidQ <- mkFIFOF;
`ifdef BSIM
	RegFile#(Bit#(14), Bit#(16)) ram <- mkRegFileFull();
	//FIFO#(Tuple4#(Bit#(14), Bit#(16), Bool, Bit#(4))) delayQ <- mkFIFO; 

/*
	rule dodelay;
		delayQ.deq;
		inQ.enq(delayQ.first);
	endrule
	rule procIn;
		inQ.deq;
		let r = inQ.first;
		let addr_ = tpl_1(r);
		Bit#(16) data = tpl_2(r);
		let write = tpl_3(r);
		Bit#(4) mask = tpl_4(r);
		let addr = addr_>>1;
		if ( write ) begin
			
			Bit#(16) curd = ram.sub(addr);
			Bit#(16) wdata = 0;
			for ( Integer i = 0; i < 4; i=i+1 ) begin
				if ( mask[0] == 1 ) begin
					wdata = wdata | (data & 16'hf);
				end else begin
					wdata = wdata | (curd & 16'hf);
				end
				mask = mask>>1;
				curd = curd>>4;
				data = data>>4;
				wdata = {wdata[3:0],wdata[15:4]};
			end
			ram.upd(addr,wdata);
		end else begin
			outQ.enq(ram.sub(addr));
		end
	endrule
	*/
	
	method Action req(Bit#(14) addr_, Bit#(16) data, Bool write, Bit#(4) mask);
		//delayQ.enq(tuple4(addr_,data,write,mask));
		let addr = addr_>>1;
		if ( write ) begin
			
			Bit#(16) curd = ram.sub(addr);
			Bit#(16) wdata = 0;
			for ( Integer i = 0; i < 4; i=i+1 ) begin
				if ( mask[0] == 1 ) begin
					wdata = wdata | (data & 16'hf);
				end else begin
					wdata = wdata | (curd & 16'hf);
				end
				mask = mask>>1;
				curd = curd>>4;
				data = data>>4;
				wdata = {wdata[3:0],wdata[15:4]};
			end
			ram.upd(addr,wdata);
		end else begin
			outQ.enq(ram.sub(addr));
		end
	endmethod

	method ActionValue#(Bit#(16)) resp;
		outQ.deq;
		return outQ.first;
	endmethod
`else

	Spram256KAImportIfc ram <- mkSpram256KAImport(curclk);
	rule ramCmd;
		ram.chipselect(1);
		ram.standby(0);
		ram.sleep(0);
		ram.poweroff(1); //active low

		let r = reqWire;
		let addr = tpl_1(r);
		let data = tpl_2(r);
		let write = tpl_3(r);
		let mask = tpl_4(r);
		ram.address(addr>>1);
		ram.datain(data);
		ram.maskwrin(mask);
		ram.wren(pack(write));

		if ( write && outQ.notFull ) begin
			outQ.enq(ram.dataout);
		end
	endrule

	/*
	rule getRead;
		let d = ram.dataout;
		if (readValidQ.first) outQ.enq(d);
		readValidQ.deq;
	endrule
	rule procIn;
		if ( inQ.notEmpty) begin
			inQ.deq;
			let r = inQ.first;
			let addr = tpl_1(r);
			let data = tpl_2(r);
			let write = tpl_3(r);
			let mask = tpl_4(r);
			ram.address(addr>>1);
			ram.datain(data);
			ram.maskwrin(mask);
			ram.wren(pack(write));

			if ( readValidQ.notFull ) begin
				if ( !write ) readValidQ.enq(True);
				else readValidQ.enq(False);
			end
		end else begin
			ram.address(0);
			ram.datain(0);
			ram.maskwrin(0);
			ram.wren(0);
			if ( readValidQ.notFull ) readValidQ.enq(False);
		end
	endrule
	*/

	method Action req(Bit#(14) addr, Bit#(16) data, Bool write, Bit#(4) mask) if ( outQ.notFull );
		//inQ.enq(tuple4(addr,data,write,mask));
		reqWire <= tuple4(addr,data,write,mask);
	endmethod

	method ActionValue#(Bit#(16)) resp;
		outQ.deq;
		return outQ.first;
	endmethod
`endif
endmodule
