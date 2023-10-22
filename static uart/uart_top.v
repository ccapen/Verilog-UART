module uart_top #(
	parameter	FREQUENCY	= 50000000,
	parameter	BAUDRATE	= 9600,
	parameter	DATABITS	= 8,
	parameter	PARITY		= "N",	//"N" "O" "E" "M" "S"
	parameter	STOPBITS	= 1.0
)(
	input					I_clk,
	input					I_rstn,
	
	input	[DATABITS-1:0]	I_data,
	input					I_txen,
	output					O_busy,
	
	output	[DATABITS-1:0]	O_data,
	output					O_valid,
	output					O_error,
	
	input					I_rxd,
	output					O_txd
);

	uart_tx #(
		.FREQUENCY	(FREQUENCY),
		.BAUDRATE	(BAUDRATE),
		.DATABITS	(DATABITS),
		.PARITY		(PARITY),	//"N" "O" "E" "M" "S"
		.STOPBITS	(STOPBITS)
	) uart_tx_u(
		.I_clk		(I_clk),
		.I_rstn		(I_rstn),
	
		.I_data		(I_data),
		.I_txen		(I_txen),
		.O_busy		(O_busy),
	
		.O_txd		(O_txd)
	);
	
	uart_rx #(
		.FREQUENCY	(FREQUENCY),
		.BAUDRATE	(BAUDRATE),
		.DATABITS	(DATABITS),
		.PARITY		(PARITY),	//"N" "O" "E" "M" "S"
		.STOPBITS	(STOPBITS)
	) uart_rx_u(
		.I_clk		(I_clk),
		.I_rstn		(I_rstn),
	
		.O_data		(O_data),
		.O_valid	(O_valid),
		.O_error	(O_error),
	
		.I_rxd		(I_rxd)
	);




endmodule
