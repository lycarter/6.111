`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2016 05:40:39 PM
// Design Name: 
// Module Name: status_indicator_led_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module status_indicator_led_fsm(
    input [1:0] status_indicator_led_status,
    input clock_25mhz,
    input reset_sync,
    output status_indicator_led
    );
    
    divider divider1(.clock_25mhz(clock_25mhz), .reset_sync(reset_sync),
                     .one_hz_enable(one_hz_enable));
    
    parameter S_blinking_off = 0;
    parameter S_blinking_on = 1;
    
    reg [1:0] state, next_state;
    
    always @(*) begin
        case (state)
            S_blinking_on: next_state <= one_hz_enable ? S_blinking_off : S_blinking_on;
            S_blinking_off: next_state <= one_hz_enable ? S_blinking_on : S_blinking_off;
        endcase
    end
    
    always @(posedge clock_25mhz) begin
        state <= next_state;
    end
    
    assign status_indicator_led = ((state == S_blinking_on && status_indicator_led_status == 2'b11) ||
                                   (status_indicator_led_status == 2'b01));
    
    
endmodule
