package LSTMCell;

import DSPArith::*;
import QuantizedMath::*;
import FIFO::*;
import Vector::*;

import BRAM::*;
import BRAMCore::*;
import FIFOF::*;
import BRAMFIFO::*;
import Spram::*;


interface LSTMCell8bIfc;
	//method Action loadWeight(Bit#(8) weight);
	method Action cmd(Bit#(8) data);

	method ActionValue#(Bit#(8)) getResult;
endinterface


/***
	Max unit: 64
	Max input width: 32
	Maximum Weight count: 
		32*64*4 Wi/f/c/o = 8192
		64*64*4 Ui/f/c/o = 16384
		64*4 Bi/f/c/o = 256

		Total: 24,832

****/


typedef 6 CommandBytes;
//Integer commandBytes = 6; // WeightCnt:2 (input+state), NodeCnt:1, InputCnt:1 (x), StateCnt:1 (y), Feedback:1 (Otherwise to host) -- Per layer
/*****
data ordering:
	load weights once
		weights are ordered input_column-major, then bias
	command sent per LSTM layer
	e.g. first layer: input,input,input, ....,cmd,cmd,cmd
	     second layer: cmd,cmd,cmd... (because output from first layer is fed back to input)
		 
		 at the last layer, set [feecback] to false to route it to output or dense

****/


//(* synthesize *)
module mkLSTMCell8b (LSTMCell8bIfc);
	//Integer spramBytes = (1024*1024/8);
	Integer commandBytes = valueOf(CommandBytes);
	Vector#(CommandBytes, Reg#(Bit#(8))) curCommand <- replicateM(mkReg(0));
	Integer commandIdx_InputCnt = 0;
	Integer commandIdx_StateCnt = 1;
	Integer commandIdx_NodeCnt = 2;
	Integer commandIdx_MatWeightCntU = 3; // number of 4-sets! so bytes/4
	Integer commandIdx_MatWeightCntL = 4;
	Integer commandIdx_ShouldFeedback = 4;
	

	Reg#(Bit#(20)) weightBytes <- mkReg(0);

	FIFO#(Bit#(8)) cmdQ <- mkFIFO;
	Reg#(Bool) weightLoadDone <- mkReg(False);
	Reg#(Bool) commandLoadDone <- mkReg(False);


	
	Vector#(4,Spram256KAIfc) spram <- replicateM(mkSpram256KA);
	//BRAM2Port#(Bit#(8),Bit#(16)) input_buffer <- mkBRAM2Server(defaultValue); // 512 bytes, 1 ice40 BRAM
	FIFO#(Bit#(8)) input_bufferQ <- mkSizedBRAMFIFO(256); 
	FIFO#(Bit#(8)) h_prev_bufferQ <- mkSizedBRAMFIFO(256); 

	FIFO#(Bit#(8)) outputQ <- mkFIFO;
	FIFO#(Bit#(2)) spramReadIdxQ <- mkFIFO;

	Reg#(Bit#(8)) weightBuffer <- mkReg(0);

	Reg#(Bit#(20)) weightReadIdx <- mkReg(0);
	rule readWeights (weightLoadDone);
		let wa = weightReadIdx;
		Bit#(2) ramidx = truncate(wa>>14); // Is this ordering okay...
		Bit#(14) subaddr = truncate(wa);
		spram[ramidx].req(subaddr, ?, False, 4'b1111);
		spramReadIdxQ.enq(ramidx);

		if ( ((weightReadIdx+1)<<2) < weightBytes ) begin
			weightReadIdx <= weightReadIdx + 1;
		end else begin
			weightReadIdx <= 0;
		end
	endrule

	FIFO#(Bit#(8)) multInputQ <- mkFIFO;

	Reg#(Bit#(8)) inputRelayed <- mkReg(0);
	Reg#(Bit#(8)) stateRelayed <- mkReg(0);
	Reg#(Bool) relayInputDone <- mkReg(False);
	rule relayInput(!relayInputDone);
		Bit#(8) inputCnt = curCommand[commandIdx_InputCnt];
		Bit#(8) stateCnt = curCommand[commandIdx_StateCnt];
		if ( inputRelayed < inputCnt ) begin
			inputRelayed <= inputRelayed + 1;
			input_bufferQ.deq;
			multInputQ.enq(input_bufferQ.first);
		end else if ( stateRelayed < stateCnt ) begin
			stateRelayed <= stateRelayed + 1;
			h_prev_bufferQ.deq;
			multInputQ.enq(h_prev_bufferQ.first);
		end else begin
			inputRelayed <= 0;
			stateRelayed <= 0;
			relayInputDone <= True;
		end
	endrule


	Vector#(2,QuantizedMathIfc) qm <- replicateM(mkQuantizedMath);
	Vector#(4,Reg#(Int#(8))) ifcoBuffer <- replicateM(mkReg(0)); // TODO where to init?
	Reg#(Bit#(8)) curNodeIdx <- mkReg(0);

	FIFO#(Bit#(16)) macWeightQ <- mkFIFO;
	FIFO#(Bit#(16)) biasQ <- mkFIFO;

	Reg#(Bit#(16)) weightRelayCounter <- mkReg(0);
	Reg#(Bool) relayWeightsDone <- mkReg(False);
	rule relayWeights(!relayWeightsDone);
		spramReadIdxQ.deq;
		let idx = spramReadIdxQ.first;
		let d <- spram[idx].resp;

		Bit#(16) matWeightCount = {curCommand[commandIdx_MatWeightCntU],curCommand[commandIdx_MatWeightCntL]};
		Bit#(16) layerWeightCount = matWeightCount + zeroExtend(curCommand[commandIdx_NodeCnt]);

		if ( (weightRelayCounter>>2) < matWeightCount ) begin
			weightRelayCounter <= weightRelayCounter + 1;
			macWeightQ.enq(d);
		end else if ( (zeroExtend(weightRelayCounter)>>2) < layerWeightCount ) begin
			biasQ.enq(d);
			if ( ((zeroExtend(weightRelayCounter)+1)>>2) >= layerWeightCount ) begin
				weightRelayCounter <= 0;
				relayWeightsDone <= True;
			end else begin
				weightRelayCounter <= weightRelayCounter + 1;
			end
		end
	endrule
	
	FIFO#(Tuple2#(Int#(8),Int#(8))) x_bufferQ <- mkSizedBRAMFIFO(256); 
	FIFO#(Tuple2#(Int#(8),Int#(8))) y_bufferQ <- mkSizedBRAMFIFO(256); 
	Reg#(Bit#(8)) x_offset <- mkReg(0);
	Reg#(Bit#(8)) x_loopcnt <- mkReg(0);
	Reg#(Bit#(8)) y_offset <- mkReg(0);
	Reg#(Bit#(8)) y_loopcnt <- mkReg(0);

	
	Reg#(Bit#(8)) multInputBuffer <- mkReg(0);
	Reg#(Bool) x_loop_done <- mkReg(False);
	Reg#(Bool) y_loop_done <- mkReg(False);
	rule doMult_x (!x_loop_done && !y_loop_done );
		let d = macWeightQ.first;
		macWeightQ.deq;

		let mv = multInputBuffer;
		if ( x_offset == 0 ) begin
			multInputQ.deq;
			mv = multInputQ.first;
			multInputBuffer <= mv;

			x_offset <= 1;
		end else begin
			if ( x_offset + 1 < (curCommand[commandIdx_NodeCnt]<<2) ) begin
				x_offset <= x_offset + 1;
			end else begin
				x_offset <= 0;
				x_loopcnt <= x_loopcnt + 1;
				if ( x_loopcnt + 1 == (curCommand[commandIdx_InputCnt]<<2) ) begin
					x_loop_done <= True;
				end
			end
		end

		let vu <- qm[0].quantizedMult(unpack(mv),unpack(truncate(d>>8)));
		let vl <- qm[1].quantizedMult(unpack(mv),unpack(truncate(d)));
		if (x_loopcnt == 0 ) begin
			x_bufferQ.enq(tuple2(vu,vl));
		end else begin
			let bv = x_bufferQ.first;
			x_bufferQ.deq;
			
			let nu = qm[0].quantizedAdd(vu,tpl_1(bv));
			let nl = qm[1].quantizedAdd(vu,tpl_2(bv));
			x_bufferQ.enq(tuple2(nu,nl));
		end
	endrule
	rule doMult_y (x_loop_done && !y_loop_done );
		let d = macWeightQ.first;
		macWeightQ.deq;

		let mv = multInputBuffer;
		if ( y_offset == 0 ) begin
			multInputQ.deq;
			mv = multInputQ.first;
			multInputBuffer <= mv;

			y_offset <= 1;
		end else begin
			if ( y_offset + 1 < (curCommand[commandIdx_NodeCnt]<<2) ) begin
				y_offset <= y_offset + 1;
			end else begin
				y_offset <= 0;
				y_loopcnt <= y_loopcnt + 1;
				if ( y_loopcnt + 1 == (curCommand[commandIdx_StateCnt]<<2) ) begin
					y_loop_done <= True;
				end
			end
		end

		let vu <- qm[0].quantizedMult(unpack(mv),unpack(truncate(d>>8)));
		let vl <- qm[1].quantizedMult(unpack(mv),unpack(truncate(d)));
		if (y_loopcnt == 0 ) begin
			y_bufferQ.enq(tuple2(vu,vl));
		end else begin
			let bv = y_bufferQ.first;
			y_bufferQ.deq;
			
			let nu = qm[0].quantizedAdd(vu,tpl_1(bv));
			let nl = qm[1].quantizedAdd(vu,tpl_2(bv));
			y_bufferQ.enq(tuple2(nu,nl));
		end
	endrule

	FIFO#(Tuple2#(Int#(8),Int#(8))) subaddQ <- mkFIFO;
	Reg#(Bit#(8)) mac_resultCounter <- mkReg(0);
	rule relayMacResult(x_loop_done && y_loop_done);
		x_bufferQ.deq;
		let xv = x_bufferQ.first;
		y_bufferQ.deq;
		let yv = y_bufferQ.first;
		let nu = quantizedAddInternal(tpl_1(xv),tpl_1(yv));
		let nl = quantizedAddInternal(tpl_2(xv),tpl_2(yv));
		let b = biasQ.first;
		biasQ.deq;
		
		let nub = quantizedAddInternal(nu, unpack(truncate(b>>8)));
		let nlb = quantizedAddInternal(nl, unpack(truncate(b)));

		subaddQ.enq(tuple2(nub,nlb));

		if ( mac_resultCounter + 1 < (curCommand[commandIdx_NodeCnt]<<2) ) begin //FIXME two per...
			mac_resultCounter <= mac_resultCounter + 1;
		end else begin
			x_loop_done <= False;
			y_loop_done <= False;
			x_loopcnt <= 0;
			y_loopcnt <= 0;
			mac_resultCounter <= 0;
		end
	endrule

	Reg#(Bit#(10)) calcResultCnt <- mkReg(0);
	rule doSigmoid;
		subaddQ.deq;
		let s = subaddQ.first;
		
		let vu <- qm[0].hardSigmoid(tpl_1(s));
		let vl <- qm[1].hardSigmoid(tpl_2(s));

		// yc = i*c + f*c_prev
		// c_prev = sigmoid(yc)
		// state == sigmoid(o*yc) ...?

		if (curCommand[commandIdx_ShouldFeedback] == 0 ) begin
			outputQ.enq(pack(vu)^pack(vl)); // FIXME wrong--- placeholder
		end else begin
			h_prev_bufferQ.enq(pack(vu)); // FIXME wrong--- placeholder
		end

		if ( truncate((calcResultCnt+1)>>2) == curCommand[commandIdx_NodeCnt] ) begin
			calcResultCnt <= 0;
			commandLoadDone <= False;
		end else begin
			calcResultCnt <= calcResultCnt + 1;
		end
	endrule



/*
	FIFO#(Tuple2#(Int#(8),Int#(8))) macResultQ <- mkFIFO;
	rule relayWeightsXXXX;
		macResultQ.deq;
		let m = macResultQ.first;
		let vu <- qm[0].hardSigmoid(tpl_1(m));
		let vl <- qm[1].hardSigmoid(tpl_2(m));
		outputQ.enq(pack(vu)^pack(vl));
		h_prev_bufferQ.enq(pack(vu));
	endrule
*/






















	Reg#(Bit#(4)) dataInCounter <- mkReg(0);
	Reg#(Bit#(17)) weightAddr <- mkReg(0);
	rule procCmd_LoadWeights (!weightLoadDone);
		let data = cmdQ.first;
		cmdQ.deq;

		if ( dataInCounter < 2 ) begin // Total sets of weight count (across all layers), (per i/f/c/o set)
			weightBytes <= ((weightBytes<<10)|(zeroExtend(data)<<2)); // 4 bytes per weight set
			dataInCounter <= dataInCounter + 1;
		end else if ( weightAddr < truncate(weightBytes) ) begin
			if (weightAddr[0] == 1 ) begin
				Bit#(2) ramidx = truncate(weightAddr>>15); // Is this ordering okay...
				Bit#(14) subaddr = truncate(weightAddr>>1);
				spram[ramidx].req(subaddr, {data,weightBuffer}, True, 4'b1111);
			end
			if ( weightAddr + 1 > truncate(weightBytes) ) begin
				weightLoadDone <= True;
				dataInCounter <= 0;
			end

			weightBuffer <= data;
			weightAddr <= weightAddr + 1;
		end
	endrule

	//FIFO#(Tuple2#(Bool,Bit#(8)))
	Reg#(Maybe#(Bool)) nextCmdIsInput <- mkReg(tagged Invalid);
	rule procCmd(weightLoadDone && !commandLoadDone);
		cmdQ.deq;
		let data = cmdQ.first;
		if ( isValid(nextCmdIsInput) ) begin
			Bool isi = fromMaybe(?, nextCmdIsInput);
			if ( isi ) input_bufferQ.enq(data);
			else begin
				curCommand[0] <= data;
				for (Integer i = 1; i < commandBytes; i=i+1) begin
					curCommand[i] <= curCommand[i-1];
				end

				if ( dataInCounter < fromInteger(commandBytes) -1 ) begin
					dataInCounter <= dataInCounter + 1;
				end else begin
					dataInCounter <= 0;

					commandLoadDone <= True;
					relayInputDone <= False;
					relayWeightsDone <= False;
				end
			end
			nextCmdIsInput <= tagged Invalid;
		end else begin
			if ( data == 0 ) begin
				nextCmdIsInput <= tagged Valid False;
			end else begin
				nextCmdIsInput <= tagged Valid True;
			end
		end
	endrule


	method Action cmd(Bit#(8) data);
		cmdQ.enq(data);
	endmethod
	method ActionValue#(Bit#(8)) getResult;
		outputQ.deq;
		return outputQ.first;
	endmethod
endmodule


endpackage: LSTMCell

