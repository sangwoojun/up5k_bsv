module top (output wire led_blue,
               output wire led_green,
               output wire led_red,

				output serial_txd,
				input serial_rxd,

				output spi_cs
				//, input clk // 12? MHz clock
			   );
	
	assign spi_cs = 1; // it is necessary to turn off the SPI flash chip

	wire clk; // 48 mhz clock
	SB_HFOSC# (
		.CLKHF_DIV("0b01") // divide clock by
	) inthosc(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

	wire rst; 
	reg [3:0] cntr;
	assign rst = (cntr == 15);
	initial
	begin
		cntr <= 0;
	end
	always @ (posedge clk)
	begin
		if ( cntr != 15 ) begin
			cntr <= cntr + 1;
		end
	end




	mkBsvTop hwtop(.CLK(clk), .RST_N(rst), .blue(led_blue), .green(led_green), .red(led_red),
		.serial_txd(serial_txd), .serial_rxd(serial_rxd));
endmodule

