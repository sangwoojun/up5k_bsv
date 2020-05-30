import Clocks :: *;
import Vector::*;

import Main::*;

import Uart::*;

import "BDPI" function Action bdpiSwInit();


interface BsvTopIfc;
	(* always_ready *)
	method Bit#(1) blue;
	(* always_ready *)
	method Bit#(1) green;
	(* always_ready *)
	method Bit#(1) red;
	
	(* always_ready *)
	method Bit#(1) serial_txd;
	(* always_enabled, always_ready, prefix = "", result = "serial_rxd" *)
	method Action serial_rx(Bit#(1) serial_rxd);
endinterface

module mkBsvTop(BsvTopIfc);
	UartIfc uart <- mkUart(1250);
	MainIfc hwmain <- mkMain;

	rule relayUartIn;
		Bit#(8) d <- uart.user.get;
		hwmain.uartIn(d);
	endrule
	rule relayUartOut;
		let d <- hwmain.uartOut;
		uart.user.send(d);
	endrule


	method Bit#(1) blue;
		return hwmain.rgbOut()[2];
	endmethod
	method Bit#(1) green;
		return hwmain.rgbOut()[1];
	endmethod
	method Bit#(1) red;
		return hwmain.rgbOut()[0];
	endmethod
	method Bit#(1) serial_txd;
		return uart.serial_txd;
	endmethod
	method Action serial_rx(Bit#(1) serial_rxd);
		uart.serial_rx(serial_rxd);
	endmethod
endmodule

module mkBsvTop_bsim(Empty);
	UartUserIfc uart <- mkUart_bsim;
	MainIfc hwmain <- mkMain;
	Reg#(Bool) initialized <- mkReg(False);
	rule doinit ( !initialized );
		initialized <= True;
		bdpiSwInit();
	endrule

	rule relayUartIn;
		Bit#(8) d <- uart.get;
		hwmain.uartIn(d);
	endrule
	rule relayUartOut;
		let d <- hwmain.uartOut;
		uart.send(d);
	endrule
endmodule
