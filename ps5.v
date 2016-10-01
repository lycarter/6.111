`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:20:37 09/29/2016 
// Design Name: 
// Module Name:    ps5 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ps5(
    input req,
    input clk,
    output ras,
    output mux,
    output cas
    );
	 
	 parameter S_IDLE   = 0;
	 parameter S_1      = 1;
	 parameter S_2      = 2;
	 parameter S_3      = 3;
	 parameter S_4      = 4;

	reg [4:0] state, next_state;
	always @(*) begin
		case (state)
			S_IDLE: next_state = req ? S_1 : S_IDLE;
			S_1: next_state = S_2;
			S_2: next_state = S_3;
			S_3: next_state = S_4;
			S_4: next_state = S_IDLE;
			default: next_state = S_IDLE;
		endcase
	end
	always @(posedge clk) state <= next_state;
	
	assign ras = (state == S_IDLE);
	assign mux = !(state == S_IDLE || state == S_1);
	assign cas = !(state == S_3 || state == S_4);

endmodule
