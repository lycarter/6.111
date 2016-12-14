`timescale 1ns / 1ps

module learn_fsm(input clock_27mhz, reset,
                 input ir_in, start_learn,
                 output out_ready,
                 output[6:0] command,
                 output[4:0] address,
                 output[2:0] debug_state);

	parameter S_IDLE= 3'd0;
	parameter S_PRESTART = 3'd1;
	parameter S_START = 3'd2;
	parameter S_IN_HIGH = 3'd3;	
	parameter S_IN_LOW = 3'd4;

	reg [2:0] state, next_state;
	reg [11:0] sequence;
	reg [3:0] cur_position;
	reg cur_bit, out_ready_reg;
	wire start_75us_counter;
	wire expired_75us_counter;

    timer t (.clk(clock_27mhz),
             .reset(reset),
             .start_timer(start_75us_counter),
             .length(16'd9), // one longer cycle than a 0 would be
             .expired(expired_75us_counter));

    always @(posedge clock_27mhz) begin
    	if (reset) begin
    		state <= S_IDLE;
    		sequence <= 12'd0;
    		cur_position <= 12'd0;
    		cur_bit <= 0;
		end
		else if (state == S_START) begin
			sequence <= 12'd0;
			cur_position <= 12'd0;
			cur_bit <= 0;
		end
		else if (state == S_IN_HIGH && (next_state == S_IN_LOW || next_state == S_IDLE)) begin
			// end of a bit, write learned bit to sequence
			cur_position <= cur_position + 1;
			sequence[4'd11 - cur_position] <= cur_bit;
			cur_bit <= 0;
		end
		else if (state == S_IN_HIGH && next_state == S_IN_HIGH && expired_75us_counter) begin
			// timer expired but ir_in is still high, so we have a 1
			cur_bit <= 1;
		end

		if (state == S_IN_HIGH && next_state == S_IDLE) begin
			out_ready_reg <= 1;
		end else begin
			out_ready_reg <= 0;
		end

		state <= next_state;
	end

	always @(*) begin
		case (state)
			S_IDLE: next_state <= start_learn ? S_PRESTART : S_IDLE;
			S_PRESTART: next_state <= ir_in ? S_START : S_PRESTART;
			S_START: next_state <= ir_in ? S_START : S_IN_LOW;
			S_IN_LOW: next_state <= ir_in ? S_IN_HIGH : S_IN_LOW;
			S_IN_HIGH: next_state <= ir_in ? S_IN_HIGH : ((cur_position == 11) ? S_IDLE : S_IN_LOW);
			default: next_state <= S_IDLE;
		endcase
	end

	// start timer on state change
	assign start_75_us_counter = (state != next_state);

	always @(posedge clock_27mhz) state <= next_state;

	assign {command, address} = sequence;
	assign debug_state = state;
	assign out_ready = out_ready_reg;
endmodule
