`timescale 1ns / 1ps

module divider(
    input clock_25mhz,         // system clock
    input reset_sync,          // system reset
    output one_hz_enable       // 1hz clock
    );

  reg [24:0] count;
  reg enable;

  always @(posedge clock_25mhz) begin
    if (reset_sync) begin
      count <= 0;
      enable <= 0;
    end
    else begin
      if (count == 25000000) begin
        enable <= 1;
        count <= 0;
      end
      else begin
        count <= count + 1;
        enable <= 0;
      end
    end
  end

  assign one_hz_enable = enable;

endmodule
