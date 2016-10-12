`timescale 1ns / 1ps

module siren #(parameter STEP=10) // how far to move the endpoint

	(input clock_25mhz,         // system clock
    input enable,              // siren enable
    output audio_out           // audio signal
    );

	// 700 hz is counting to 17857 for a half-period
	// 400 hz is counting to 31250 for a half-period

	reg audio_reg;
	reg [14:0] count;
	reg [14:0] endpoint = 31250;
	reg state = 0; // 1: increasing endpoint, 0: decreasing endpoint

	always @(posedge clock_25mhz) begin
		// keep endpoint bopping back and forth
		if (endpoint >= 31250) begin
			state <= 0;
		end
		else if (endpoint <= 17857) begin
			state <= 1;
		end
		if (count == endpoint) begin
			endpoint <= state ? endpoint + STEP : endpoint - STEP;
			count <= 0;
			audio_reg <= !audio_reg;  // toggle waveform
		end
		else begin
			count <= count + 1;
		end
	end

	assign audio_out = (enable & audio_reg);

endmodule