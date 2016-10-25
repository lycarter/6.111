`timescale 1ns / 1ps

// pulse synchronizer
module learn_fsm(input clock_27mhz,
                 input button_0, button_1, button_2, button_3,
                 output out);

	parameter S_learn = 0;
	parameter S_playback = 1;
	parameter S_blah = 2;

	reg [2:0] state, next_state;
	reg reg_out;

	always @(*) begin
		case (state)
			S_learn: begin
				next_state <= S_blah;
			end
			S_playback: next_state <= S_blah;
			S_blah: next_state <= S_blah;
			default: next_state <= S_blah;
		endcase
	end

	always @(posedge clock_27mhz) state <= next_state;

	assign out = reg_out;
endmodule
