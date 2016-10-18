`timescale 1ns / 1ps

module pt_1_divider(
    input clock_25mhz,         // system clock
    input reset_sync,          // system reset
    output pt_one_hz_enable       // 1hz pulse
    );

  reg [24:0] count = 0;
  reg enable = 0;

  always @(posedge clock_25mhz) begin
    if (reset_sync) begin
      count <= 0;
      enable <= 0;
    end
    else begin
      if (count == 2500000) begin
        enable <= 1;
        count <= 0;
      end
      else begin
        count <= count + 1;
        enable <= 0;
      end
    end
  end

  assign pt_one_hz_enable = enable;

endmodule
