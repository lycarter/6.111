`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2016 02:03:56 PM
// Design Name: 
// Module Name: fuel_pump_fsm
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


module fuel_pump_fsm(
    input ignition_switch,
    input hidden_switch,
    input brake,
    input reset_sync,
    input clock_25mhz,
    output fuel_pump
    );
    
    parameter S_off  = 0;
    parameter S_off2 = 1;
    parameter S_on   = 2;
    
    reg [1:0] state, next_state;
    
    always @(*) begin
        case (state)
            S_off: next_state <= ignition_switch ? S_off2 : S_off;
            S_off2: next_state <= !ignition_switch ? S_off : ((hidden_switch && brake) ? S_on : S_off2); 
            S_on: next_state <= ignition_switch ? S_on : S_off;
            default: next_state <= S_off;
        endcase
    end
    
    always @(posedge clock_25mhz) state <= next_state;
    
    assign fuel_pump = (state == S_on);
endmodule
