///////////////////////////////////////////////////////////////////////////////
// enable goes high every 75us, providing 8x oversampling for 
// 600us width signal (with 27mhz clock)
///////////////////////////////////////////////////////////////////////////////
module divider_600us (input wire clk,
                             input wire reset,
                             output wire enable);

  reg [10:0] count;

  always@(posedge clk) 
  begin
     if (reset)
        count <= 0;
     else if (count == 2024)
        count <= 0;
     else
        count <= count + 1;
  end
  assign enable = (count == 2024);  
endmodule  
