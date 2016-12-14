///////////////////////////////////////////////////////////////////////////////
// A programmable timer with 75us increments. When start_timer is asserted,
// the timer latches length, and asserts expired for one clock cycle 
// after 'length' 75us intervals have passed. e.g. if length is 10, timer will
// assert expired after 750us.
///////////////////////////////////////////////////////////////////////////////
module timer (input wire clk,
                 input wire reset,
                 input wire start_timer,
                 input wire [16:0] length,
                 output wire expired);
  
  wire enable;
  divider_600us sc(.clk(clk),.reset(start_timer),.enable(enable));
  reg [16:0] count_length;
  reg [16:0] count;
  reg counting;
  
  always@(posedge clk) 
  begin
     if (reset)
        counting <= 0;
     else if (start_timer) 
     begin
        count_length <= length;
        count <= 0;
        counting <= 1;
     end
     else if (counting && enable)
        count <= count + 1;
     else if (expired)
        counting <= 0;
  end
  
  assign expired = (counting && (count == count_length));
endmodule   

