`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////
//
// lpset CRC test bench
//
/////////////////////////////////////////////////////////////////////////////

module crc_tf;

	// Inputs
	reg clock;
	reg start;
	reg data;

	// Outputs
	wire done;
	wire [15:0] r;

   // Instantiate the Unit Under Test (UUT)
   lpset_crc uut (
      .clock(clock), 
      .start(start), 
      .data(data), 
      .done(done), 
      .r(r)
   );
 
   // this is the input data
   reg [47:0] input_data = 48'h03_01_02_03_30_3A;
   
   integer i;                      // required for "for" loop
   always #5 clock = !clock;
   initial begin
      // Initialize Inputs
      clock = 0;
      start = 0;
      data = 0;

      // Wait 100 ns for global reset to finish
      #100;
        
      // Add stimulus here
      start=1;
      #10 start = 0;
      
       for (i=0; i<48; i=i+1)
       begin
         data = input_data[47];
         // at each clock, left shift the data
         // note syntax for test bench "for" loop - no "always"
         // note the blocking assignment (immediate)
         @(posedge clock) input_data = {input_data[46:0],1'b0};     
       end
        
   $stop; // Pause simulation   

   end

   endmodule
