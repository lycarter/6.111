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
    parameter S_off3 = 2;
    parameter S_off_one = 4;
    parameter S_off_one_triggered = 5;
    parameter S_on_maybe = 6;
    parameter S_on   = 7;
    
    reg [2:0] state, next_state;
    reg pt_1_sec_timer_start;

    pt_1_sec_timer quick_timer(.clock_25mhz(clock_25mhz), .reset_sync(reset_sync), .value(1),  
        .expired(pt_1_sec_expired), .start_timer(pt_1_sec_timer_start));
    
    always @(*) begin
        case (state)
            S_off: next_state <= ignition_switch ? S_off2 : S_off;
            S_off2: next_state <= !ignition_switch ? S_off : ((!hidden_switch && !brake) ? S_off3 : S_off2);
            S_off3: next_state <= !ignition_switch ? S_off : ((hidden_switch || brake) ? S_off_one : S_off3);
            S_off_one: begin
                pt_1_sec_timer_start <= 1;
                next_state <= S_off_one_triggered;
            end
            S_off_one_triggered: begin
                pt_1_sec_timer_start <= 0;
                next_state <= !ignition_switch ? S_off : (pt_1_sec_expired ? S_on_maybe : S_off_one_triggered);
            end
            S_on_maybe: next_state <= (hidden_switch && brake) ? S_on : S_off;
            S_on: next_state <= ignition_switch ? S_on : S_off;
            default: next_state <= S_off;
        endcase
    end
    
    always @(posedge clock_25mhz) state <= next_state;
    
    assign fuel_pump = (state == S_on);
endmodule
