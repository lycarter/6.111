module timer (
	input clock_25mhz,   // system clock
	input reset_sync,    // system reset
	input [3:0] value,   // initial value
	input start_timer,   // asserted high to start the timer
	output expired,       // asserted high when timer ends
	output [3:0] output_hex,  // for debugging, one_hz_enable count
	output expired_led  // for debugging, equal to expired
	);

	reg [3:0] countup = 0;
	reg [3:0] one_hz_hex = 0;
	reg state = 0;  // 1: counting. 0: halted
	reg out = 0;

	wire one_hz_enable;

	divider divider1(.clock_25mhz(clock_25mhz), .reset_sync(start_timer),
					 .one_hz_enable(one_hz_enable));

	always @(posedge clock_25mhz) begin
	
        if (start_timer) begin
            state <= 1;
            out <= 0;
            countup <= 0;
        end
	
	    if (one_hz_enable) begin
    	    one_hz_hex <= one_hz_hex + 1;
    	end
	
		if (reset_sync) begin
			countup <= 0;
			state <= 0;
			out <= 0;
		end
		else if (one_hz_enable && state) begin
			countup <= countup + 1;
		end

		if (countup == value) begin
            countup <= 0;
            state <= 0;
            out <= 1;  // set expired high
        end
	end
	
	assign output_hex = value - countup;

	assign expired = out;
	assign expired_led = expired;

endmodule

