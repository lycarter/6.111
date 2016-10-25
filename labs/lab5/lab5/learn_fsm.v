`timescale 1ns / 1ps

module learn_fsm(input clock_27mhz, clock_75us, reset,
                 input button_0, button_1, button_2, button_3,
                 output out);

	parameter S_learn = 0;
	parameter S_playback = 1;
	parameter S_blah = 2;

	reg [2:0] state, next_state;
	reg reg_out;
	
	wire [11:0] pattern0, pattern1, pattern2, pattern3;
	wire start0, start1, start2, start3;
	
	
	receive_bit_fsm button0_rcv(.clock_27mhz(clock_27mhz), .clock_75us(clock_75us),
		.start(start0), .reset(reset), .demodulated_synchronized_in(button_0), .data(pattern0));
	receive_bit_fsm button1_rcv(.clock_27mhz(clock_27mhz), .clock_75us(clock_75us),
		.start(start1), .reset(reset), .demodulated_synchronized_in(button_1), .data(pattern1));
	receive_bit_fsm button2_rcv(.clock_27mhz(clock_27mhz), .clock_75us(clock_75us),
		.start(start2), .reset(reset), .demodulated_synchronized_in(button_2), .data(pattern2));
	receive_bit_fsm button3_rcv(.clock_27mhz(clock_27mhz), .clock_75us(clock_75us),
		.start(start3), .reset(reset), .demodulated_synchronized_in(button_3), .data(pattern3));

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
