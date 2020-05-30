//
// Generated by Bluespec Compiler, version 2014.07.A (build 34078, 2014-07-30)
//
// On Tue May 19 16:06:31 PDT 2020
//
//
// Ports:
// Name                         I/O  size props
// blue                           O     1 const
// green                          O     1 const
// red                            O     1 const
// serial_txd                     O     1 reg
// CLK                            I     1 clock
// RST_N                          I     1 reset
// serial_rxd                     I     1 reg
//
// No combinational paths from inputs to outputs
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkBsvTop(CLK,
		RST_N,

		blue,

		green,

		red,

		serial_txd,

		serial_rxd);
  input  CLK;
  input  RST_N;

  // value method blue
  output blue;

  // value method green
  output green;

  // value method red
  output red;

  // value method serial_txd
  output serial_txd;

  // action method serial_rx
  input  serial_rxd;

  // signals for module outputs
  wire blue, green, red, serial_txd;

  // inlined wires
  wire [1 : 0] hwmain_mem_serverAdapterA_s1_1_wget,
	       hwmain_mem_serverAdapterA_writeWithResp_wget;
  wire hwmain_mem_serverAdapterA_cnt_1_whas,
       hwmain_mem_serverAdapterA_outData_deqCalled_whas,
       hwmain_mem_serverAdapterA_outData_enqData_whas,
       hwmain_mem_serverAdapterA_outData_outData_whas,
       hwmain_mem_serverAdapterA_writeWithResp_whas,
       hwmain_mem_serverAdapterB_outData_enqData_whas,
       hwmain_mem_serverAdapterB_writeWithResp_whas;

  // register hwmain_mem_serverAdapterA_cnt
  reg [2 : 0] hwmain_mem_serverAdapterA_cnt;
  wire [2 : 0] hwmain_mem_serverAdapterA_cnt_D_IN;
  wire hwmain_mem_serverAdapterA_cnt_EN;

  // register hwmain_mem_serverAdapterA_s1
  reg [1 : 0] hwmain_mem_serverAdapterA_s1;
  wire [1 : 0] hwmain_mem_serverAdapterA_s1_D_IN;
  wire hwmain_mem_serverAdapterA_s1_EN;

  // register hwmain_mem_serverAdapterB_cnt
  reg [2 : 0] hwmain_mem_serverAdapterB_cnt;
  wire [2 : 0] hwmain_mem_serverAdapterB_cnt_D_IN;
  wire hwmain_mem_serverAdapterB_cnt_EN;

  // register hwmain_mem_serverAdapterB_s1
  reg [1 : 0] hwmain_mem_serverAdapterB_s1;
  wire [1 : 0] hwmain_mem_serverAdapterB_s1_D_IN;
  wire hwmain_mem_serverAdapterB_s1_EN;

  // register uart_bleft
  reg [3 : 0] uart_bleft;
  wire [3 : 0] uart_bleft_D_IN;
  wire uart_bleft_EN;

  // register uart_clkcnt
  reg [15 : 0] uart_clkcnt;
  wire [15 : 0] uart_clkcnt_D_IN;
  wire uart_clkcnt_EN;

  // register uart_curoutd
  reg [10 : 0] uart_curoutd;
  wire [10 : 0] uart_curoutd_D_IN;
  wire uart_curoutd_EN;

  // register uart_curoutoff
  reg [4 : 0] uart_curoutoff;
  wire [4 : 0] uart_curoutoff_D_IN;
  wire uart_curoutoff_EN;

  // register uart_outword
  reg [7 : 0] uart_outword;
  wire [7 : 0] uart_outword_D_IN;
  wire uart_outword_EN;

  // register uart_rxin
  reg [3 : 0] uart_rxin;
  wire [3 : 0] uart_rxin_D_IN;
  wire uart_rxin_EN;

  // register uart_samplecountdown
  reg [15 : 0] uart_samplecountdown;
  wire [15 : 0] uart_samplecountdown_D_IN;
  wire uart_samplecountdown_EN;

  // register uart_txdr
  reg uart_txdr;
  wire uart_txdr_D_IN, uart_txdr_EN;

  // ports of submodule hwmain_mem_memory
  wire [15 : 0] hwmain_mem_memory_DIA,
		hwmain_mem_memory_DIB,
		hwmain_mem_memory_DOA,
		hwmain_mem_memory_DOB;
  wire hwmain_mem_memory_ADDRA,
       hwmain_mem_memory_ADDRB,
       hwmain_mem_memory_ENA,
       hwmain_mem_memory_ENB,
       hwmain_mem_memory_WEA,
       hwmain_mem_memory_WEB;

  // ports of submodule hwmain_mem_serverAdapterA_outDataCore
  wire [15 : 0] hwmain_mem_serverAdapterA_outDataCore_D_IN,
		hwmain_mem_serverAdapterA_outDataCore_D_OUT;
  wire hwmain_mem_serverAdapterA_outDataCore_CLR,
       hwmain_mem_serverAdapterA_outDataCore_DEQ,
       hwmain_mem_serverAdapterA_outDataCore_EMPTY_N,
       hwmain_mem_serverAdapterA_outDataCore_ENQ,
       hwmain_mem_serverAdapterA_outDataCore_FULL_N;

  // ports of submodule hwmain_mem_serverAdapterB_outDataCore
  wire [15 : 0] hwmain_mem_serverAdapterB_outDataCore_D_IN;
  wire hwmain_mem_serverAdapterB_outDataCore_CLR,
       hwmain_mem_serverAdapterB_outDataCore_DEQ,
       hwmain_mem_serverAdapterB_outDataCore_ENQ,
       hwmain_mem_serverAdapterB_outDataCore_FULL_N;

  // ports of submodule hwmain_proc
  wire [67 : 0] hwmain_proc_memReq;
  wire [31 : 0] hwmain_proc_memResp_data;
  wire hwmain_proc_EN_memReq,
       hwmain_proc_EN_memResp,
       hwmain_proc_RDY_memReq,
       hwmain_proc_RDY_memResp;

  // ports of submodule hwmain_relayUart
  wire [7 : 0] hwmain_relayUart_D_IN, hwmain_relayUart_D_OUT;
  wire hwmain_relayUart_CLR,
       hwmain_relayUart_DEQ,
       hwmain_relayUart_EMPTY_N,
       hwmain_relayUart_ENQ,
       hwmain_relayUart_FULL_N;

  // ports of submodule uart_outQ
  wire [7 : 0] uart_outQ_D_IN, uart_outQ_D_OUT;
  wire uart_outQ_CLR,
       uart_outQ_DEQ,
       uart_outQ_EMPTY_N,
       uart_outQ_ENQ,
       uart_outQ_FULL_N;

  // rule scheduling signals
  wire WILL_FIRE_RL_hwmain_mem_serverAdapterA_outData_enqAndDeq,
       WILL_FIRE_RL_relayUartOut,
       WILL_FIRE_RL_uart_insample;

  // inputs to muxes for submodule ports
  wire [10 : 0] MUX_uart_curoutd_write_1__VAL_1,
		MUX_uart_curoutd_write_1__VAL_2;
  wire [4 : 0] MUX_uart_curoutoff_write_1__VAL_1;
  wire MUX_uart_curoutd_write_1__SEL_1;

  // remaining internal signals
  wire [15 : 0] v__h4410, x__h369, x__h797;
  wire [3 : 0] x__h949;
  wire [2 : 0] hwmain_mem_serverAdapterA_cnt_0_PLUS_IF_hwmain_ETC___d76;
  wire [1 : 0] hwmain_procmemReq_BITS_67_TO_66__q1;
  wire uart_clkcnt_PLUS_1_ULT_1250___d3;

  // value method blue
  assign blue = 1'd0 ;

  // value method green
  assign green = 1'd0 ;

  // value method red
  assign red = 1'd0 ;

  // value method serial_txd
  assign serial_txd = uart_txdr ;

  // submodule hwmain_mem_memory
  BRAM2 #(.PIPELINED(1'd0),
	  .ADDR_WIDTH(32'd1),
	  .DATA_WIDTH(32'd16),
	  .MEMSIZE(2'd2)) hwmain_mem_memory(.CLKA(CLK),
					    .CLKB(CLK),
					    .ADDRA(hwmain_mem_memory_ADDRA),
					    .ADDRB(hwmain_mem_memory_ADDRB),
					    .DIA(hwmain_mem_memory_DIA),
					    .DIB(hwmain_mem_memory_DIB),
					    .WEA(hwmain_mem_memory_WEA),
					    .WEB(hwmain_mem_memory_WEB),
					    .ENA(hwmain_mem_memory_ENA),
					    .ENB(hwmain_mem_memory_ENB),
					    .DOA(hwmain_mem_memory_DOA),
					    .DOB(hwmain_mem_memory_DOB));

  // submodule hwmain_mem_serverAdapterA_outDataCore
  SizedFIFO #(.p1width(32'd16),
	      .p2depth(32'd3),
	      .p3cntr_width(32'd1),
	      .guarded(32'd1)) hwmain_mem_serverAdapterA_outDataCore(.RST(RST_N),
								     .CLK(CLK),
								     .D_IN(hwmain_mem_serverAdapterA_outDataCore_D_IN),
								     .ENQ(hwmain_mem_serverAdapterA_outDataCore_ENQ),
								     .DEQ(hwmain_mem_serverAdapterA_outDataCore_DEQ),
								     .CLR(hwmain_mem_serverAdapterA_outDataCore_CLR),
								     .D_OUT(hwmain_mem_serverAdapterA_outDataCore_D_OUT),
								     .FULL_N(hwmain_mem_serverAdapterA_outDataCore_FULL_N),
								     .EMPTY_N(hwmain_mem_serverAdapterA_outDataCore_EMPTY_N));

  // submodule hwmain_mem_serverAdapterB_outDataCore
  SizedFIFO #(.p1width(32'd16),
	      .p2depth(32'd3),
	      .p3cntr_width(32'd1),
	      .guarded(32'd1)) hwmain_mem_serverAdapterB_outDataCore(.RST(RST_N),
								     .CLK(CLK),
								     .D_IN(hwmain_mem_serverAdapterB_outDataCore_D_IN),
								     .ENQ(hwmain_mem_serverAdapterB_outDataCore_ENQ),
								     .DEQ(hwmain_mem_serverAdapterB_outDataCore_DEQ),
								     .CLR(hwmain_mem_serverAdapterB_outDataCore_CLR),
								     .D_OUT(),
								     .FULL_N(hwmain_mem_serverAdapterB_outDataCore_FULL_N),
								     .EMPTY_N());

  // submodule hwmain_proc
  mkProcessor hwmain_proc(.CLK(CLK),
			  .RST_N(RST_N),
			  .memResp_data(hwmain_proc_memResp_data),
			  .EN_memReq(hwmain_proc_EN_memReq),
			  .EN_memResp(hwmain_proc_EN_memResp),
			  .memReq(hwmain_proc_memReq),
			  .RDY_memReq(hwmain_proc_RDY_memReq),
			  .RDY_memResp(hwmain_proc_RDY_memResp));

  // submodule hwmain_relayUart
  FIFO2 #(.width(32'd8), .guarded(32'd1)) hwmain_relayUart(.RST(RST_N),
							   .CLK(CLK),
							   .D_IN(hwmain_relayUart_D_IN),
							   .ENQ(hwmain_relayUart_ENQ),
							   .DEQ(hwmain_relayUart_DEQ),
							   .CLR(hwmain_relayUart_CLR),
							   .D_OUT(hwmain_relayUart_D_OUT),
							   .FULL_N(hwmain_relayUart_FULL_N),
							   .EMPTY_N(hwmain_relayUart_EMPTY_N));

  // submodule uart_outQ
  FIFO2 #(.width(32'd8), .guarded(32'd1)) uart_outQ(.RST(RST_N),
						    .CLK(CLK),
						    .D_IN(uart_outQ_D_IN),
						    .ENQ(uart_outQ_ENQ),
						    .DEQ(uart_outQ_DEQ),
						    .CLR(uart_outQ_CLR),
						    .D_OUT(uart_outQ_D_OUT),
						    .FULL_N(uart_outQ_FULL_N),
						    .EMPTY_N(uart_outQ_EMPTY_N));

  // rule RL_relayUartOut
  assign WILL_FIRE_RL_relayUartOut =
	     uart_curoutoff == 5'd0 && hwmain_relayUart_EMPTY_N ;

  // rule RL_uart_insample
  assign WILL_FIRE_RL_uart_insample =
	     uart_samplecountdown != 16'd0 || uart_bleft != 4'd1 ||
	     uart_outQ_FULL_N ;

  // rule RL_hwmain_mem_serverAdapterA_outData_enqAndDeq
  assign WILL_FIRE_RL_hwmain_mem_serverAdapterA_outData_enqAndDeq =
	     hwmain_mem_serverAdapterA_outDataCore_EMPTY_N &&
	     hwmain_mem_serverAdapterA_outDataCore_FULL_N &&
	     hwmain_mem_serverAdapterA_outData_deqCalled_whas &&
	     hwmain_mem_serverAdapterA_outData_enqData_whas ;

  // inputs to muxes for submodule ports
  assign MUX_uart_curoutd_write_1__SEL_1 =
	     !WILL_FIRE_RL_relayUartOut &&
	     !uart_clkcnt_PLUS_1_ULT_1250___d3 &&
	     uart_curoutoff != 5'd0 ;
  assign MUX_uart_curoutd_write_1__VAL_1 = { 1'd1, uart_curoutd[10:1] } ;
  assign MUX_uart_curoutd_write_1__VAL_2 =
	     { 2'b11, hwmain_relayUart_D_OUT, 1'b0 } ;
  assign MUX_uart_curoutoff_write_1__VAL_1 = uart_curoutoff - 5'd1 ;

  // inlined wires
  assign hwmain_mem_serverAdapterA_outData_enqData_whas =
	     (!hwmain_mem_serverAdapterA_s1[0] ||
	      hwmain_mem_serverAdapterA_outDataCore_FULL_N) &&
	     hwmain_mem_serverAdapterA_s1[1] &&
	     hwmain_mem_serverAdapterA_s1[0] ;
  assign hwmain_mem_serverAdapterA_outData_outData_whas =
	     hwmain_mem_serverAdapterA_outDataCore_EMPTY_N ||
	     !hwmain_mem_serverAdapterA_outDataCore_EMPTY_N &&
	     hwmain_mem_serverAdapterA_outData_enqData_whas ;
  assign hwmain_mem_serverAdapterA_cnt_1_whas =
	     hwmain_proc_RDY_memReq &&
	     (hwmain_mem_serverAdapterA_cnt ^ 3'h4) < 3'd7 &&
	     (!hwmain_procmemReq_BITS_67_TO_66__q1[1] ||
	      hwmain_procmemReq_BITS_67_TO_66__q1[0]) ;
  assign hwmain_mem_serverAdapterA_writeWithResp_wget =
	     hwmain_proc_memReq[67:66] ;
  assign hwmain_mem_serverAdapterA_writeWithResp_whas =
	     hwmain_proc_RDY_memReq &&
	     (hwmain_mem_serverAdapterA_cnt ^ 3'h4) < 3'd7 ;
  assign hwmain_mem_serverAdapterA_s1_1_wget =
	     { 1'd1,
	       !hwmain_mem_serverAdapterA_writeWithResp_wget[1] ||
	       hwmain_mem_serverAdapterA_writeWithResp_wget[0] } ;
  assign hwmain_mem_serverAdapterB_outData_enqData_whas =
	     (!hwmain_mem_serverAdapterB_s1[0] ||
	      hwmain_mem_serverAdapterB_outDataCore_FULL_N) &&
	     hwmain_mem_serverAdapterB_s1[1] &&
	     hwmain_mem_serverAdapterB_s1[0] ;
  assign hwmain_mem_serverAdapterB_writeWithResp_whas =
	     uart_outQ_EMPTY_N &&
	     (hwmain_mem_serverAdapterB_cnt ^ 3'h4) < 3'd7 ;
  assign hwmain_mem_serverAdapterA_outData_deqCalled_whas =
	     hwmain_proc_RDY_memResp &&
	     (hwmain_mem_serverAdapterA_outDataCore_EMPTY_N ||
	      hwmain_mem_serverAdapterA_outData_enqData_whas) &&
	     hwmain_mem_serverAdapterA_outData_outData_whas &&
	     hwmain_relayUart_FULL_N ;

  // register hwmain_mem_serverAdapterA_cnt
  assign hwmain_mem_serverAdapterA_cnt_D_IN =
	     hwmain_mem_serverAdapterA_cnt_0_PLUS_IF_hwmain_ETC___d76 ;
  assign hwmain_mem_serverAdapterA_cnt_EN =
	     hwmain_mem_serverAdapterA_cnt_1_whas ||
	     hwmain_mem_serverAdapterA_outData_deqCalled_whas ;

  // register hwmain_mem_serverAdapterA_s1
  assign hwmain_mem_serverAdapterA_s1_D_IN =
	     { hwmain_mem_serverAdapterA_writeWithResp_whas &&
	       hwmain_mem_serverAdapterA_s1_1_wget[1],
	       hwmain_mem_serverAdapterA_s1_1_wget[0] } ;
  assign hwmain_mem_serverAdapterA_s1_EN = 1'd1 ;

  // register hwmain_mem_serverAdapterB_cnt
  assign hwmain_mem_serverAdapterB_cnt_D_IN =
	     hwmain_mem_serverAdapterB_cnt + 3'd0 + 3'd0 ;
  assign hwmain_mem_serverAdapterB_cnt_EN = 1'b0 ;

  // register hwmain_mem_serverAdapterB_s1
  assign hwmain_mem_serverAdapterB_s1_D_IN =
	     { hwmain_mem_serverAdapterB_writeWithResp_whas, 1'b0 } ;
  assign hwmain_mem_serverAdapterB_s1_EN = 1'd1 ;

  // register uart_bleft
  assign uart_bleft_D_IN =
	     (uart_bleft == 4'd0 && !(uart_rxin != 4'd0)) ? 4'd9 : x__h949 ;
  assign uart_bleft_EN =
	     WILL_FIRE_RL_uart_insample &&
	     (uart_bleft == 4'd0 && !(uart_rxin != 4'd0) ||
	      uart_bleft != 4'd0 && uart_samplecountdown == 16'd0) ;

  // register uart_clkcnt
  assign uart_clkcnt_D_IN =
	     uart_clkcnt_PLUS_1_ULT_1250___d3 ? x__h369 : 16'd0 ;
  assign uart_clkcnt_EN = !WILL_FIRE_RL_relayUartOut ;

  // register uart_curoutd
  assign uart_curoutd_D_IN =
	     MUX_uart_curoutd_write_1__SEL_1 ?
	       MUX_uart_curoutd_write_1__VAL_1 :
	       MUX_uart_curoutd_write_1__VAL_2 ;
  assign uart_curoutd_EN =
	     !WILL_FIRE_RL_relayUartOut &&
	     !uart_clkcnt_PLUS_1_ULT_1250___d3 &&
	     uart_curoutoff != 5'd0 ||
	     WILL_FIRE_RL_relayUartOut ;

  // register uart_curoutoff
  assign uart_curoutoff_D_IN =
	     MUX_uart_curoutd_write_1__SEL_1 ?
	       MUX_uart_curoutoff_write_1__VAL_1 :
	       5'd11 ;
  assign uart_curoutoff_EN =
	     !WILL_FIRE_RL_relayUartOut &&
	     !uart_clkcnt_PLUS_1_ULT_1250___d3 &&
	     uart_curoutoff != 5'd0 ||
	     WILL_FIRE_RL_relayUartOut ;

  // register uart_outword
  assign uart_outword_D_IN = { uart_rxin != 4'd0, uart_outword[7:1] } ;
  assign uart_outword_EN =
	     WILL_FIRE_RL_uart_insample && uart_bleft != 4'd0 &&
	     uart_samplecountdown == 16'd0 ;

  // register uart_rxin
  assign uart_rxin_D_IN = { serial_rxd, uart_rxin[3:1] } ;
  assign uart_rxin_EN = 1'd1 ;

  // register uart_samplecountdown
  assign uart_samplecountdown_D_IN =
	     (uart_bleft == 4'd0 && !(uart_rxin != 4'd0)) ?
	       16'd1875 :
	       ((uart_samplecountdown == 16'd0) ? 16'd1250 : x__h797) ;
  assign uart_samplecountdown_EN =
	     WILL_FIRE_RL_uart_insample &&
	     (!(uart_rxin != 4'd0) || uart_bleft != 4'd0) ;

  // register uart_txdr
  assign uart_txdr_D_IN = uart_curoutd[0] ;
  assign uart_txdr_EN = MUX_uart_curoutd_write_1__SEL_1 ;

  // submodule hwmain_mem_memory
  assign hwmain_mem_memory_ADDRA = hwmain_proc_memReq[37] ;
  assign hwmain_mem_memory_ADDRB = uart_outQ_D_OUT[0] ;
  assign hwmain_mem_memory_DIA = hwmain_proc_memReq[18:3] ;
  assign hwmain_mem_memory_DIB = { 8'd0, uart_outQ_D_OUT } ;
  assign hwmain_mem_memory_WEA = hwmain_proc_memReq[67] ;
  assign hwmain_mem_memory_WEB = 1'd1 ;
  assign hwmain_mem_memory_ENA =
	     hwmain_mem_serverAdapterA_writeWithResp_whas ;
  assign hwmain_mem_memory_ENB =
	     hwmain_mem_serverAdapterB_writeWithResp_whas ;

  // submodule hwmain_mem_serverAdapterA_outDataCore
  assign hwmain_mem_serverAdapterA_outDataCore_D_IN = hwmain_mem_memory_DOA ;
  assign hwmain_mem_serverAdapterA_outDataCore_ENQ =
	     WILL_FIRE_RL_hwmain_mem_serverAdapterA_outData_enqAndDeq ||
	     hwmain_mem_serverAdapterA_outDataCore_FULL_N &&
	     !hwmain_mem_serverAdapterA_outData_deqCalled_whas &&
	     hwmain_mem_serverAdapterA_outData_enqData_whas ;
  assign hwmain_mem_serverAdapterA_outDataCore_DEQ =
	     WILL_FIRE_RL_hwmain_mem_serverAdapterA_outData_enqAndDeq ||
	     hwmain_mem_serverAdapterA_outDataCore_EMPTY_N &&
	     hwmain_mem_serverAdapterA_outData_deqCalled_whas &&
	     !hwmain_mem_serverAdapterA_outData_enqData_whas ;
  assign hwmain_mem_serverAdapterA_outDataCore_CLR = 1'b0 ;

  // submodule hwmain_mem_serverAdapterB_outDataCore
  assign hwmain_mem_serverAdapterB_outDataCore_D_IN = hwmain_mem_memory_DOB ;
  assign hwmain_mem_serverAdapterB_outDataCore_ENQ =
	     hwmain_mem_serverAdapterB_outDataCore_FULL_N &&
	     hwmain_mem_serverAdapterB_outData_enqData_whas ;
  assign hwmain_mem_serverAdapterB_outDataCore_DEQ = 1'b0 ;
  assign hwmain_mem_serverAdapterB_outDataCore_CLR = 1'b0 ;

  // submodule hwmain_proc
  assign hwmain_proc_memResp_data = { 16'd0, v__h4410 } ;
  assign hwmain_proc_EN_memReq =
	     hwmain_proc_RDY_memReq &&
	     (hwmain_mem_serverAdapterA_cnt ^ 3'h4) < 3'd7 ;
  assign hwmain_proc_EN_memResp =
	     hwmain_proc_RDY_memResp &&
	     (hwmain_mem_serverAdapterA_outDataCore_EMPTY_N ||
	      hwmain_mem_serverAdapterA_outData_enqData_whas) &&
	     hwmain_mem_serverAdapterA_outData_outData_whas &&
	     hwmain_relayUart_FULL_N ;

  // submodule hwmain_relayUart
  assign hwmain_relayUart_D_IN = v__h4410[7:0] ;
  assign hwmain_relayUart_ENQ =
	     hwmain_mem_serverAdapterA_outData_deqCalled_whas ;
  assign hwmain_relayUart_DEQ = WILL_FIRE_RL_relayUartOut ;
  assign hwmain_relayUart_CLR = 1'b0 ;

  // submodule uart_outQ
  assign uart_outQ_D_IN = uart_outword ;
  assign uart_outQ_ENQ =
	     WILL_FIRE_RL_uart_insample && uart_samplecountdown == 16'd0 &&
	     uart_bleft == 4'd1 ;
  assign uart_outQ_DEQ = hwmain_mem_serverAdapterB_writeWithResp_whas ;
  assign uart_outQ_CLR = 1'b0 ;

  // remaining internal signals
  assign hwmain_mem_serverAdapterA_cnt_0_PLUS_IF_hwmain_ETC___d76 =
	     hwmain_mem_serverAdapterA_cnt +
	     (hwmain_mem_serverAdapterA_cnt_1_whas ? 3'd1 : 3'd0) +
	     (hwmain_mem_serverAdapterA_outData_deqCalled_whas ?
		3'd7 :
		3'd0) ;
  assign hwmain_procmemReq_BITS_67_TO_66__q1 = hwmain_proc_memReq[67:66] ;
  assign uart_clkcnt_PLUS_1_ULT_1250___d3 = x__h369 < 16'd1250 ;
  assign v__h4410 =
	     hwmain_mem_serverAdapterA_outDataCore_EMPTY_N ?
	       hwmain_mem_serverAdapterA_outDataCore_D_OUT :
	       hwmain_mem_memory_DOA ;
  assign x__h369 = uart_clkcnt + 16'd1 ;
  assign x__h797 = uart_samplecountdown - 16'd1 ;
  assign x__h949 = uart_bleft - 4'd1 ;

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        hwmain_mem_serverAdapterA_cnt <= `BSV_ASSIGNMENT_DELAY 3'd0;
	hwmain_mem_serverAdapterA_s1 <= `BSV_ASSIGNMENT_DELAY 2'd0;
	hwmain_mem_serverAdapterB_cnt <= `BSV_ASSIGNMENT_DELAY 3'd0;
	hwmain_mem_serverAdapterB_s1 <= `BSV_ASSIGNMENT_DELAY 2'd0;
	uart_bleft <= `BSV_ASSIGNMENT_DELAY 4'd0;
	uart_clkcnt <= `BSV_ASSIGNMENT_DELAY 16'd0;
	uart_curoutd <= `BSV_ASSIGNMENT_DELAY 11'd0;
	uart_curoutoff <= `BSV_ASSIGNMENT_DELAY 5'd0;
	uart_outword <= `BSV_ASSIGNMENT_DELAY 8'd0;
	uart_rxin <= `BSV_ASSIGNMENT_DELAY 4'b1111;
	uart_samplecountdown <= `BSV_ASSIGNMENT_DELAY 16'd0;
	uart_txdr <= `BSV_ASSIGNMENT_DELAY 1'd1;
      end
    else
      begin
        if (hwmain_mem_serverAdapterA_cnt_EN)
	  hwmain_mem_serverAdapterA_cnt <= `BSV_ASSIGNMENT_DELAY
	      hwmain_mem_serverAdapterA_cnt_D_IN;
	if (hwmain_mem_serverAdapterA_s1_EN)
	  hwmain_mem_serverAdapterA_s1 <= `BSV_ASSIGNMENT_DELAY
	      hwmain_mem_serverAdapterA_s1_D_IN;
	if (hwmain_mem_serverAdapterB_cnt_EN)
	  hwmain_mem_serverAdapterB_cnt <= `BSV_ASSIGNMENT_DELAY
	      hwmain_mem_serverAdapterB_cnt_D_IN;
	if (hwmain_mem_serverAdapterB_s1_EN)
	  hwmain_mem_serverAdapterB_s1 <= `BSV_ASSIGNMENT_DELAY
	      hwmain_mem_serverAdapterB_s1_D_IN;
	if (uart_bleft_EN)
	  uart_bleft <= `BSV_ASSIGNMENT_DELAY uart_bleft_D_IN;
	if (uart_clkcnt_EN)
	  uart_clkcnt <= `BSV_ASSIGNMENT_DELAY uart_clkcnt_D_IN;
	if (uart_curoutd_EN)
	  uart_curoutd <= `BSV_ASSIGNMENT_DELAY uart_curoutd_D_IN;
	if (uart_curoutoff_EN)
	  uart_curoutoff <= `BSV_ASSIGNMENT_DELAY uart_curoutoff_D_IN;
	if (uart_outword_EN)
	  uart_outword <= `BSV_ASSIGNMENT_DELAY uart_outword_D_IN;
	if (uart_rxin_EN) uart_rxin <= `BSV_ASSIGNMENT_DELAY uart_rxin_D_IN;
	if (uart_samplecountdown_EN)
	  uart_samplecountdown <= `BSV_ASSIGNMENT_DELAY
	      uart_samplecountdown_D_IN;
	if (uart_txdr_EN) uart_txdr <= `BSV_ASSIGNMENT_DELAY uart_txdr_D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    hwmain_mem_serverAdapterA_cnt = 3'h2;
    hwmain_mem_serverAdapterA_s1 = 2'h2;
    hwmain_mem_serverAdapterB_cnt = 3'h2;
    hwmain_mem_serverAdapterB_s1 = 2'h2;
    uart_bleft = 4'hA;
    uart_clkcnt = 16'hAAAA;
    uart_curoutd = 11'h2AA;
    uart_curoutoff = 5'h0A;
    uart_outword = 8'hAA;
    uart_rxin = 4'hA;
    uart_samplecountdown = 16'hAAAA;
    uart_txdr = 1'h0;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on

  // handling of system tasks

  // synopsys translate_off
  always@(negedge CLK)
  begin
    #0;
    if (RST_N != `BSV_RESET_VALUE)
      if (uart_outQ_EMPTY_N && (hwmain_mem_serverAdapterB_cnt ^ 3'h4) < 3'd7)
	$write("uartIn %d\n", uart_outQ_D_OUT);
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_relayUartOut)
	$write("uartOut %d\n", hwmain_relayUart_D_OUT);
    if (RST_N != `BSV_RESET_VALUE)
      if (hwmain_mem_serverAdapterA_s1[1] &&
	  !hwmain_mem_serverAdapterA_outDataCore_FULL_N)
	$display("ERROR: %m: mkBRAMSeverAdapter overrun");
    if (RST_N != `BSV_RESET_VALUE)
      if (hwmain_mem_serverAdapterB_s1[1] &&
	  !hwmain_mem_serverAdapterB_outDataCore_FULL_N)
	$display("ERROR: %m: mkBRAMSeverAdapter overrun");
  end
  // synopsys translate_on
endmodule  // mkBsvTop
