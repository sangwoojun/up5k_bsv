module osc(clk);
	output clk;

	SB_HFOSC inthosc (
		.CLKHFPU(1'b1),
		.CLKHFEN(1'b1),
		.CLKHF(clk)
	);
endmodule

module null_reset(rst);
	output rst;
	assign rst = 1;
endmodule
