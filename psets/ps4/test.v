// Landon Carter
// 6.111 PSET4

module jk
	(input j, k, preset, clear, clk,
	 output q, qbar);

	reg state;

	always @(posedge clk or negedge preset or negedge clear) begin
		if (preset && claer) begin  // standard operation
			case ({j, k})
				2'b00: state <= state;
				2'b01: state <= j;
				2'b10: state <= j;
				2'b11: state <= ~state;
				default: state <= state;
			endcase
		end
		else if (~preset) begin  // set state
			state <= 1;
		end
		else if (~clear) begin  // clear state
			state <= 0;
		end
	end

	assign q = state;
	assign qbar = ~q;

endmodule