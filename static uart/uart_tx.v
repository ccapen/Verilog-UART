module uart_tx #(
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
	
	output					O_txd
);

	localparam CNTDIV	= FREQUENCY/BAUDRATE;
	localparam STOPBITS2= (STOPBITS == 1.5) ? 3 : ((STOPBITS == 1.0) ? 2 : 4);
	localparam CNTMAX	= STOPBITS2*CNTDIV/2;
//	localparam CNTMAX	= $rtoi(STOPBITS*2.0)*CNTDIV/2;	//be replaced by 2 lines upper
	localparam CNTWIDTH	= $clog2(CNTMAX);
	localparam BITNUM	= 1+DATABITS+(PARITY != "N");	//bitnums exclude stopbits
	
	localparam IDLE	= 3'b001;
	localparam SEND	= 3'b010;
	localparam STOP	= 3'b100;

	localparam IDLE_IND	= 4'd0;
	localparam SEND_IND	= 4'd1;
	localparam STOP_IND	= 4'd2;
	
	reg [2:0] R_state;
	
	reg [CNTWIDTH-1:0] R_cnt;
	wire W_nextbit;
	wire W_tx_end;
	
	reg [3:0] R_cnt_bit;
	wire W_parity_end;
	
	wire W_parity;
	reg [DATABITS+1:0] R_txdata;
	
	always@(posedge I_clk or negedge I_rstn)
	if(!I_rstn) R_state <= IDLE;
	else case(R_state)
		IDLE:if(I_txen) R_state <= SEND;
				else R_state <= IDLE;
		SEND:if(W_parity_end) R_state <= STOP;
				else R_state <= SEND;
		STOP:if(W_tx_end) R_state <= IDLE;
				else R_state <= STOP;
		default:R_state <= IDLE;
	endcase
	
	
	always@(posedge I_clk or negedge I_rstn)
	if(!I_rstn) R_cnt <= {CNTWIDTH{1'b0}};
	else if(R_state[IDLE_IND] || W_nextbit) R_cnt <= {CNTWIDTH{1'b0}};
	else R_cnt <= R_cnt + 1'b1;
	
	assign W_nextbit = (R_cnt == (CNTDIV - 1'b1)) && R_state[SEND_IND];
	assign W_tx_end = (R_cnt == (CNTMAX - 1'b1));
	
	
	always@(posedge I_clk or negedge I_rstn)
	if(!I_rstn) R_cnt_bit <= 4'b0;
	else if(R_state[IDLE_IND]) R_cnt_bit <= 4'b0;
	else if(W_nextbit) R_cnt_bit <= R_cnt_bit + 1'b1;
	else R_cnt_bit <= R_cnt_bit;
	
	assign W_parity_end = (R_cnt_bit == (BITNUM-1)) && W_nextbit;
	
	
	generate
		case(PARITY)
			"N":assign W_parity = 1'b1;
			"O":assign W_parity = (!(^I_data));
			"E":assign W_parity = (^I_data);
			"M":assign W_parity = 1'b1;
			"S":assign W_parity = 1'b0;
		endcase
	endgenerate
	
	always@(posedge I_clk or negedge I_rstn)
	if(!I_rstn) R_txdata <= {(DATABITS+2){1'b1}};
	else if(R_state[IDLE_IND] && I_txen) R_txdata <= {W_parity,I_data,1'b0};
	else if(W_nextbit) R_txdata <= {1'b1,R_txdata[(DATABITS+1):1]};
	else R_txdata <= R_txdata;


	assign O_busy = (!R_state[IDLE_IND]);
	assign O_txd = R_txdata[0];

endmodule
