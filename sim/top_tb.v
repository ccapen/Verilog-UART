module top_tb();

	reg R_clk;
	reg R_rstn;
	reg R_valid;
	
	always #10 R_clk = !R_clk;
	
	initial
	begin
		R_clk = 1'b0;
		R_rstn = 1'b0;
		R_valid = 1'b0;
		#55 R_rstn = 1'b1;
		#20 R_valid = 1'b1;
		#20 R_valid = 1'b0;
	end


	wire W_uart_io;
	
	uart_top #(
		.FREQUENCY	(960_000),
		.BAUDRATE	(9600),
		.DATABITS	(8),
		.PARITY		("N"),	//"N" "O" "E" "M" "S"
		.STOPBITS	(1.0),
		.CHECKSTOP	("ENABLE")
	) uart_top_u(
		.I_clk		(R_clk),
		.I_rstn		(R_rstn),
	
		.I_data		(8'h5a),
		.I_txen		(R_valid),
		.O_busy		(),
	
		.O_data		(),
		.O_valid	(),
		.O_error	(),
	
		.I_rxd		(W_uart_io),
		.O_txd		(W_uart_io)
	);
	

	
endmodule
