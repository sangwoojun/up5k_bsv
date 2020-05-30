import FIFO::*;
import FIFOF::*;

import RFile::*;
import MemorySystem::*;
import Defines::*;
import Decode::*;
import Execute::*;

typedef struct {
	Word pc;
	Word pc_predicted;
	Bool epoch;
} F2D deriving(Bits, Eq);

typedef struct {
	Word pc;
	Word pc_predicted;
	Bool epoch;
	DecodedInst dInst; 
	Word rVal1; 
	Word rVal2;
} D2E deriving(Bits, Eq);

typedef struct {
	Word pc;
	RIndx dst;

	Bool isMem;

	Word data;
	Bool extendSigned;
	SizeType size;
} E2M deriving(Bits,Eq);

interface ProcessorIfc;
	method ActionValue#(MemReq32) memReq;
	method Action memResp(Word data);
endinterface

(* synthesize *)
module mkProcessor(ProcessorIfc);

	Reg#(Bit#(32)) cycles <- mkReg(0);
	Reg#(Bit#(32)) instCnt <- mkReg(0);
	rule incCycle;
		cycles <= cycles + 1;
	endrule

	FIFOF#(F2D) f2d <- mkSizedFIFOF(2);
    FIFOF#(D2E) d2e <- mkSizedFIFOF(2);
	FIFOF#(E2M) e2m <- mkSizedFIFOF(2);

	RFile2R1W   rf <- mkRFile2R1W;
	MemorySystemIfc mem <- mkMemorySystemBypass;

	FIFOF#(Word) nextpcQ <- mkSizedFIFOF(4);
	Reg#(Word)  pc <- mkReg(0);
	Reg#(Bool) epoch <- mkReg(False);

	rule doFetch;// (stage == Fetch);
		Word curpc = pc;

		if ( nextpcQ.notEmpty ) begin
			nextpcQ.deq;
			curpc = nextpcQ.first;
		end

		Word pc_predicted = curpc + 4;
		pc <= pc_predicted; // For next cycle

		mem.iMem.req(MemReq32{write:False,addr:curpc,data:?,size:4});
		f2d.enq(F2D {pc: curpc, pc_predicted:pc_predicted, epoch:epoch});

		$write( "[0x%8x:0x%4x] Fetching instruction count 0x%4x\n", cycles, curpc, instCnt );
		//stage <= Decode;
		instCnt <= instCnt + 1;
	endrule

	rule doDecode;// (stage == Decode);
		let x = f2d.first;
		Word inst = mem.iMem.first;
		mem.iMem.deq;

		let dInst = decode(inst);
		let rVal1 = rf.rd1(dInst.src1);
		let rVal2 = rf.rd2(dInst.src2);

		d2e.enq(D2E {pc: x.pc, pc_predicted:x.pc_predicted, epoch:x.epoch, dInst: dInst, rVal1: rVal1, rVal2: rVal2});
		f2d.deq;

		$write( "[0x%8x:0x%04x] Decoding 0x%08x\n", cycles, x.pc, inst );
		//stage <= Execute;
	endrule

	rule doExecute;// (stage == Execute);
		D2E x = d2e.first; d2e.deq;
		Word pc = x.pc; 
		Word pc_predicted = x.pc_predicted;
		Bool epoch_fetched = x.epoch;
		Word rVal1 = x.rVal1; Word rVal2 = x.rVal2; 
		DecodedInst dInst = x.dInst;

		if ( epoch_fetched == epoch ) begin
			let eInst = exec(dInst, rVal1, rVal2, pc);
			
			if ( pc_predicted != eInst.nextPC ) begin
				nextpcQ.enq(eInst.nextPC);
				epoch <= !epoch;
				$write( "[0x%8x:0x%04x] \t\t detected misprediction, jumping to 0x%08x\n", cycles, pc, eInst.nextPC );
			end
			
			if (eInst.iType == Unsupported) begin
				$display("Reached unsupported instruction");
				//$display("Total Clock Cycles = %d\nTotal Instruction Count = %d", cycles, instCnt);
				$display("Dumping the state of the processor");
				$display("pc = 0x%x", x.pc);
				//rf.displayRFileInSimulation;
				$display("Quitting simulation.");
				$finish;
			end

			if (eInst.iType == LOAD) begin
				mem.dMem.req(MemReq32{write:False,addr:eInst.addr,data:?,size:dInst.size});
				//dstLoad <= fromMaybe(?, eInst.dst); // FIXME to FIFO
				e2m.enq(E2M{dst:eInst.dst,extendSigned:dInst.extendSigned,size:dInst.size, pc:pc, data:0, isMem: True});
				//stage <= Writeback;
				$write( "[0x%8x:0x%04x] \t\t Mem read from 0x%08x\n", cycles, pc, eInst.addr );
			end 
			else if (eInst.iType == STORE) begin
				//if ( eInst.addr == 'h4000_1000)
				//$display("Total Clock Cycles = %d\nTotal Instruction Count = %d", cycles, instCnt);
				mem.dMem.req(MemReq32{write:True,addr:eInst.addr,data:eInst.data,size:dInst.size});
				//stage <= Fetch;
				$write( "[0x%8x:0x%04x] \t\t Mem write 0x%08x to 0x%08x\n", cycles, pc, eInst.data, eInst.addr );
			end
			else begin
				if(eInst.writeDst) begin
					$write( "[0x%8x:0x%04x] rf writing %x to %d\n", cycles, pc, eInst.data, eInst.dst );
					e2m.enq(E2M{dst:eInst.dst,extendSigned:?,size:?, pc:pc, data:eInst.data, isMem: False});
					//stage <= Writeback;
				end else begin
					//stage <= Fetch;
				end
			end
			$write( "[0x%8x:0x%04x] Executing\n", cycles, pc );
		end else begin
			e2m.enq(E2M{dst:0,extendSigned:?,size:?, pc:pc, data:?, isMem: False});
			$write( "[0x%8x:0x%04x] \t\t ignoring mispredicted instruction\n", cycles, pc );
		end
	endrule

	rule doWriteback;// (stage == Writeback);
		e2m.deq;
		let r = e2m.first;
		Word dw = r.data;
		if ( r.isMem ) begin
			let data = mem.dMem.first;
			mem.dMem.deq;

			if ( r.size == 1 ) begin
				if ( r.extendSigned ) begin
					Int#(8) id = unpack(data[7:0]);
					Int#(32) ide = signExtend(id);
					dw = pack(ide);
				end else begin
					dw = zeroExtend(data[7:0]);
				end
			end else if ( r.size == 2 ) begin
				if ( r.extendSigned ) begin
					Int#(16) id = unpack(data[15:0]);
					Int#(32) ide = signExtend(id);
					dw = pack(ide);
				end else begin
					dw = zeroExtend(data[15:0]);
				end
			end else begin
				dw = data;
			end
		end
		rf.wr(r.dst, dw);
		
		//stage <= Fetch;
		$write( "[0x%8x:0x%04x] Writeback writing %x to %d\n", cycles, r.pc, dw, r.dst );
	endrule

	method ActionValue#(MemReq32) memReq;
		let r <- mem.client.memReq;
		return r;
	endmethod
	method Action memResp(Word data);
		mem.client.memResp(data);
	endmethod
endmodule
