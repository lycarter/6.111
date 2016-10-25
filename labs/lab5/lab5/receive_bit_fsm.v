`timescale 1ns / 1ps

// pulse synchronizer
module receive_bit_fsm(input clock_27mhz,
					   input clock_75us,
					   input start, reset,
                       input demodulated_synchronized_in,
                       output [11:0] data);

	parameter S_idle = 0;
	parameter S_wait_for_high = 1;
	parameter S_wait_for_low = 2;

	reg [2:0] state = 0;
	reg [2:0] next_state = 0;
	reg [11:0] reg_data = 0;   // decoded data
	reg [3:0] position = 0;    // position of the current bit
	reg [5:0] count_75us = 0;  // count of the number of 75us clock cycles high

	always @(*) begin
		case (state)
			S_idle: begin
				if (start) begin
					next_state <= S_wait_for_high;
					position <= 0;
					count_75us <= 0;
				end
				else begin
					next_state <= S_idle;
				end
			end
			S_wait_for_low: begin
				if (demodulated_synchronized_in) begin
					next_state <= S_wait_for_low;
					count_75us <= count_75us + 1;
				end
				else begin
					if (count_75us == 8) begin
						reg_data[position] <= 0;
						position <= position + 1;
					end
					else if (count_75us == 16) begin
						reg_data[position] <= 1;
						position <= position + 1;
					end
					else if (count_75us == 32) begin  // start receiving
						reg_data <= 0;
						position <= 0;
					end
					next_state <= S_wait_for_high;
				end
			end
			S_wait_for_high: begin
				if (position == 12) begin  // done receiving
					next_state <= S_idle;
					position <= 0;
				end
				else if (demodulated_synchronized_in) begin
					count_75us <= 0;
					next_state <= S_wait_for_low;
				end
				else begin
					next_state <= S_wait_for_high;
				end
			end
			default: next_state <= S_idle;
		endcase
	end

	always @(posedge clock_75us) state <= reset ? S_idle : next_state;

	assign data = reg_data;
endmodule
