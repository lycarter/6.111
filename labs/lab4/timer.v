module timer (
	input clock_25mhz,   // system clock
	input reset_sync,    // system reset
	input [3:0] value,   // initial value
	input start_timer,   // asserted high to start the timer
	output expired,       // asserted high when timer ends
	output [3:0] output_hex
	);

	reg [3:0] countup = 0;
	reg state = 0;  // 1: counting. 0: halted
	reg out = 0;

	wire one_hz_enable;

	divider divider1(.clock_25mhz(clock_25mhz), .reset_sync(start_timer),
					 .one_hz_enable(one_hz_enable));
					 
    always @(*) begin
        if (start_timer) begin
            state <= 1;
            out <= 0;
        end
    end

	always @(posedge clock_25mhz) begin
		if (reset_sync) begin
			countup <= 0;
			state <= 0;
			out <= 0;
		end
		else if (one_hz_enable && state) begin
			if (countup == value) begin
				countup <= 0;
				state <= 0;
				out <= 1;  // set expired high
			end
			else begin
				countup <= countup + 1;
			end
		end
	end
	
	assign output_hex = countup;

	assign expired = out;

endmodule

