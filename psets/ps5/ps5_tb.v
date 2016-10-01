`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:07:05 09/29/2016
// Design Name:   ps5
// Module Name:   /afs/athena.mit.edu/user/l/c/lcarter/6.111/Psets/pset5/ps5_tb.v
// Project Name:  pset5
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ps5
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ps5_tb;

	// Inputs
	reg req;
	reg clk;

	// Outputs
	wire ras;
	wire mux;
	wire cas;

	// Instantiate the Unit Under Test (UUT)
	ps5 uut (
		.req(req), 
		.clk(clk), 
		.ras(ras), 
		.mux(mux), 
		.cas(cas)
	);

	always #5 clk = !clk;  // 10 ns clk
	initial begin
		// Initialize Inputs
		req = 0;
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
		#2; // Wait part of a clk cycle
		// Pulse req
		req = 1;
		#10;
		req = 0;

	end
      
endmodule

