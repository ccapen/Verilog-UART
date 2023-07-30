module top(
	input		I_inclk,
	input		I_key_rstn,
	
	output		O_busy,
	output		O_valid,
	output		O_error,
	
	input		I_rxd,
	output		O_txd
);

	wire W_mclk;
	wire W_locked;
	

	alt_pll pll_u(
		.areset		(!I_key_rstn),
		.inclk0		(I_inclk),
		.c0			(W_mclk),	//50MHz
		.locked		(W_locked)
	);
	
	wire [7:0] W_data;
	
	uart_tx #(
		.FREQUENCY	(50_000_000),
		.BAUDRATE	(9600),
		.DATABITS	(8),
		.PARITY		("N"),	//"N" "O" "E" "M" "S"
		.STOPBITS	(1.0)
	) uart_tx_u(
		.I_clk		(W_mclk),
		.I_rstn		(W_locked),
	
		.I_data		(W_data),
		.I_txen		(W_valid),
		.O_busy		(O_busy),
	
		.O_txd		(O_txd)
	);
	
	uart_rx #(
		.FREQUENCY	(50_000_000),
		.BAUDRATE	(9600),
		.DATABITS	(8),
		.PARITY		("N"),	//"N" "O" "E" "M" "S"
		.STOPBITS	(1.0)
	) uart_rx_u(
		.I_clk		(W_mclk),
		.I_rstn		(W_locked),
	
		.O_data		(W_data),
		.O_valid	(W_valid),
		.O_error	(O_error),
	
		.I_rxd		(I_rxd)
	);
	
	assign O_valid = W_valid;
	
endmodule
