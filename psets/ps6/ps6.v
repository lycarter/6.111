module ps6(
	input clock,
	input start,
	input data,
	output done,
	output [15:0] r
    );

	reg [15:0] state;

	always @(posedge clock) begin
		if (start) begin
			// clear things
			state <= 16'hFFFF;
		end
	end

	assign r = state;

endmodule
