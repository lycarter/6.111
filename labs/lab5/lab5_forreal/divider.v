`timescale 1ns / 1ps

module divider(
    input clock_27mhz,         // system clock
    input reset_sync,          // system reset
    output clock_75us          // 75us clock period (13.3 kHz)
    );

  reg [9:0] count = 0;
  reg enable = 0;

  always @(posedge clock_27mhz) begin
    if (reset_sync) begin
      count <= 0;
      enable <= 0;
    end
    else begin
      if (count == 1012) begin
        enable <= !enable;  // swap enable every 37.5 us
        count <= 0;
      end
      else begin
        count <= count + 1;
      end
    end
  end

  assign clock_75us = enable;

endmodule
