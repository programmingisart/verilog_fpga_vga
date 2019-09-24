module ttlrx(
	input  clk,
	input  rxpin,
	output[7:0] out_bytes,
	output out_byte_ok
);	
	
parameter IDLE         = 2'b00;
parameter WAITTORECEIVE         = 2'b01;
parameter RECEIVING 	= 2'b10;
parameter WAITTOIDLE 	= 2'b11;

reg byte_ok;
reg [1:0]state;
reg [7:0]bytes;

reg [3:0]bitcount;

reg [15:0] cnt;

initial begin

	state <= IDLE;
	bytes <= 8'h00;
	bitcount <= 4'h0;
	cnt <= 16'h0000;
end

always @(posedge clk) begin
	
	if(state != IDLE) cnt <= cnt + 1'b1;
	else cnt <= 16'h0000;

	if(state == IDLE && rxpin == 0) state <= WAITTORECEIVE;
	
	if(state == WAITTORECEIVE && cnt == 16'b11011)begin
		cnt <= 16'h0000;
		if(rxpin == 0) state <= RECEIVING;
		else state <= IDLE;
	end

	
	if(state == RECEIVING && cnt == 16'b110110) begin
		cnt <= 16'h0000;
		bytes[bitcount] <= rxpin;
		bitcount <= bitcount + 1'b1;
	end
	
	if(state == RECEIVING && bitcount >= 8) begin
		cnt <= 16'h0000;
		byte_ok <= 1'b1;
		state <= WAITTOIDLE;
	end
	
	if(state == WAITTOIDLE && cnt == 16'b11011)begin
		cnt <= 16'h0000;
		bitcount <= 4'h0;
		byte_ok <= 1'b0;
		state <= IDLE;
	end
		
end
	
	
assign out_bytes = bytes; //{state,state};
assign out_byte_ok = byte_ok;


endmodule