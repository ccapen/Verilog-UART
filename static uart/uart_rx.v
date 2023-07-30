module uart_rx #(
	parameter	FREQUENCY	= 50000000,
	parameter	BAUDRATE	= 9600,
	parameter	DATABITS	= 8,
	parameter	PARITY		= "N",	//"N" "O" "E" "M" "S"
	parameter	STOPBITS	= 1.0
)(
	input					I_clk,
	input					I_rstn,
	
	output	[DATABITS-1:0]	O_data,
	output					O_valid,
	output					O_error,
	
	input					I_rxd
);

	localparam CNTDIV	= FREQUENCY/BAUDRATE;
	localparam CNTWIDTH	= $clog2(CNTDIV);
	localparam BITNUM	= 1+DATABITS+(PARITY != "N");	//bitnums exclude stopbits
	
	reg R_recving;
	
	reg [2:0] R_rxd;
	wire W_fall;
	
	reg [CNTWIDTH-1:0] R_cnt;
	wire W_nextbit;
	wire W_sample;
	
	reg [3:0] R_cnt_bit;
	wire W_recv_end;
	
	reg R_odd_parity;
	wire W_error;
	reg [DATABITS:0] R_rxdata;
	reg R_valid;
	reg R_error;
	
	always@(posedge I_clk or negedge I_rstn)
	if(!I_rstn) R_recving <= 1'b0;
	else if((R_recving == 1'b0) && W_fall) R_recving <= 1'b1;
	else if(W_recv_end) R_recving <= 1'b0;
	else R_recving <= R_recving;
	
	always@(posedge I_clk or negedge I_rstn)
	if(!I_rstn) R_rxd <= 3'b111;
	else R_rxd <= {R_rxd[1:0],I_rxd};
	
	assign W_fall = (R_rxd[2] && (!R_rxd[1]));
	
	always@(posedge I_clk or negedge I_rstn)
	if(!I_rstn) R_cnt <= {CNTWIDTH{1'b0}};
	else if(W_nextbit || (!R_recving)) R_cnt <= {CNTWIDTH{1'b0}};
	else R_cnt <= R_cnt + 1'b1;
	
	assign W_nextbit = (R_cnt == (CNTDIV - 1'b1)) || ((R_rxd[2] != R_rxd[1]) && (R_cnt > (CNTDIV/2)));
	
	assign W_sample = (R_cnt == ((CNTDIV - 1'b1)/2));
	
	
	always@(posedge I_clk or negedge I_rstn)
	if(!I_rstn) R_cnt_bit <= 4'b0;
	else if(!R_recving) R_cnt_bit <= 4'b0;
	else if(W_nextbit) R_cnt_bit <= R_cnt_bit + 1'b1;
	else R_cnt_bit <= R_cnt_bit;
	
	assign W_recv_end = (R_cnt_bit == (BITNUM-1)) && W_nextbit;
	
	
	
	always@(posedge I_clk or negedge I_rstn)
	if(!I_rstn) R_odd_parity <= 1'b0;
	else if(!R_recving) R_odd_parity <= 1'b0;
	else if(W_sample) R_odd_parity <= R_odd_parity ^ R_rxd[2];
	else R_odd_parity <= R_odd_parity;
	
	generate
		case(PARITY)
			"N":assign W_error = 1'b0;
			"O":assign W_error = (R_odd_parity == 1'b0);
			"E":assign W_error = (R_odd_parity == 1'b1);
			"M":assign W_error = (R_rxdata[DATABITS] == 1'b0);
			"S":assign W_error = (R_rxdata[DATABITS] == 1'b1);
		endcase
	endgenerate
	
	always@(posedge I_clk or negedge I_rstn)
	if(!I_rstn) R_rxdata <= {(DATABITS+1){1'b1}};
	else if(W_sample && R_recving) R_rxdata <= {R_rxd[2],R_rxdata[DATABITS:1]};
	else R_rxdata <= R_rxdata;
	
	always@(posedge I_clk or negedge I_rstn)
	if(!I_rstn) R_valid <= 1'b0;
	else R_valid <= W_recv_end && (!W_error);
	
	always@(posedge I_clk or negedge I_rstn)
	if(!I_rstn) R_error <= 1'b0;
	else if(W_recv_end) R_error <= W_error;
	else R_error <= R_error;


	assign O_data = (PARITY == "N") ? R_rxdata[DATABITS:1] : R_rxdata[DATABITS-1:0];
	assign O_valid = R_valid;
	assign O_error = R_error;


endmodule
