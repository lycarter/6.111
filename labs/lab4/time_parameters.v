`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2016 01:52:21 PM
// Design Name: 
// Module Name: time_parameters
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


module time_parameters(
    input [1:0] time_parameter_selecter,
    input [3:0] time_value,
    input reprogram,
    output [3:0] T_ARM_DELAY,
    output [3:0] T_DRIVER_DELAY,
    output [3:0] T_PASSENGER_DELAY,
    output [3:0] T_ALARM_DELAY
    );
    
    // default values
    
    reg [3:0] arm = 6;
    reg [3:0] driver = 8;
    reg [3:0] passenger = 15;
    reg [3:0] alarm = 10;
    
    always @(*) begin
        if (reprogram) begin
            case (time_parameter_selecter)
                2'b00: arm <= time_parameter_selecter;
                2'b01: driver <= time_parameter_selecter;
                2'b10: passenger <= time_parameter_selecter;
                2'b11: alarm <= time_parameter_selecter;
                default: ;  // do nothing, shouldn't actually ever be hit anyway
            endcase
        end
    end
    
    assign T_ARM_DELAY = arm;
    assign T_DRIVER_DELAY = driver;
    assign T_PASSENGER_DELAY = passenger;
    assign T_ALARM_DELAY = alarm;
endmodule
