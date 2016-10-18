`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// 
// Create Date: 10/1/2015 V1.0
// Design Name: 
// Module Name: labkit
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


module labkit(
   input CLK100MHZ,
   input[15:0] SW, 
   input BTNC, BTNU, BTNL, BTNR, BTND,
   output[3:0] VGA_R, 
   output[3:0] VGA_B, 
   output[3:0] VGA_G,
   output[7:0] JA, 
   output VGA_HS, 
   output VGA_VS, 
   output LED16_B, LED16_G, LED16_R,
   output LED17_B, LED17_G, LED17_R,
   output[15:0] LED,
   output[7:0] SEG,  // segments A-G (0-6), DP (7)
   output[7:0] AN    // Display 0-7
   );
   

// create 25mhz system clock
    wire clock_25mhz;
    clock_quarter_divider clockgen(.clk100_mhz(CLK100MHZ), .clock_25mhz(clock_25mhz));

//  instantiate 7-segment display;  
    wire [31:0] data;
    wire [6:0] segments;
    display_8hex display(.clk(clock_25mhz),.data(data), .seg(segments), .strobe(AN));    
    assign SEG[6:0] = segments;
    assign SEG[7] = 1'b1;
    
// instantiate inputs:
    wire reset_sync;
    synchronize rs(.clk(clock_25mhz), .in(SW[15]), .out(reset_sync));


    wire hidden_switch, brake, driver_door, passenger_door, reprogram;
    
    debounce hidden_switch_db(.reset(reset_sync), .clock(clock_25mhz),
        .noisy(BTNU), .clean(hidden_switch));
    debounce brake_db(.reset(reset_sync), .clock(clock_25mhz),
        .noisy(BTND), .clean(brake));
    debounce driver_door_db(.reset(reset_sync), .clock(clock_25mhz),
        .noisy(BTNL), .clean(driver_door));
    debounce passenger_door_db(.reset(reset_sync), .clock(clock_25mhz),
        .noisy(BTNR), .clean(passenger_door));
    debounce reprogram_db(.reset(reset_sync), .clock(clock_25mhz),
        .noisy(BTNC), .clean(reprogram));
    
    wire ignition_switch;
    debounce ignition_switch_db(.reset(reset_sync), .clock(clock_25mhz),
        .noisy(SW[7]), .clean(ignition_switch));
    
    wire [1:0] time_parameter_selecter;
    debounce tps1_db(.reset(reset_sync), .clock(clock_25mhz),
        .noisy(SW[5]), .clean(time_parameter_selecter[1]));
    debounce tps2_db(.reset(reset_sync), .clock(clock_25mhz),
            .noisy(SW[4]), .clean(time_parameter_selecter[0]));
    
    wire [3:0] time_value;
    debounce tv1_db(.reset(reset_sync), .clock(clock_25mhz),
        .noisy(SW[0]), .clean(time_value[0]));
    debounce tv2_db(.reset(reset_sync), .clock(clock_25mhz),
        .noisy(SW[1]), .clean(time_value[1]));
    debounce tv3_db(.reset(reset_sync), .clock(clock_25mhz),
        .noisy(SW[2]), .clean(time_value[2]));
    debounce tv4_db(.reset(reset_sync), .clock(clock_25mhz),
        .noisy(SW[3]), .clean(time_value[3]));
    
    wire status_indicator_led, fuel_pump_power, siren_out;


// declare wires as shown in Figure 2 to connect the submodules:
    wire one_hz_enable;
    wire [3:0] value;
    wire expired, start_timer; 
    wire sound_enable;
    wire [1:0] status_indicator_led_status;

    // instantiate the submodules and wire their inputs and outputs
    // (use the labkit's clock_25mhz as the clock to all blocks) 
    
    wire [3:0] T_ARM_DELAY, T_DRIVER_DELAY, T_PASSENGER_DELAY, T_ALARM_DELAY;
    wire [3:0] hex1, hex2, hex3, hex4, state_hex;
    wire led1, led2, led3, led4;
    
    time_parameters tp(.time_parameter_selecter(time_parameter_selecter),
        .time_value(time_value), .reprogram(reprogram), .T_DRIVER_DELAY(T_DRIVER_DELAY),
        .T_PASSENGER_DELAY(T_PASSENGER_DELAY), .T_ARM_DELAY(T_ARM_DELAY), .T_ALARM_DELAY(T_ALARM_DELAY));
    
    anti_theft_fsm big_fsm(.reprogram(reprogram), .ignition_switch(ignition_switch), .driver_door(driver_door), .passenger_door(passenger_door),
        .clock_25mhz(clock_25mhz), .reset_sync(reset_sync), .T_DRIVER_DELAY(T_DRIVER_DELAY),
        .T_PASSENGER_DELAY(T_PASSENGER_DELAY), .T_ARM_DELAY(T_ARM_DELAY), .T_ALARM_DELAY(T_ALARM_DELAY),
        .status_indicator_led_status(status_indicator_led_status), .sound(sound_enable), .state_hex(state_hex),
        .hex1(hex1), .hex2(hex2), .hex3(hex3), .hex4(hex4), .led1(led1), .led2(led2), .led3(led3), .led4(led4));
        
    siren siren1(.clock_25mhz(clock_25mhz), .enable(sound_enable), .audio_out(siren_out));
    
    fuel_pump_fsm fpfsm(.ignition_switch(ignition_switch), .hidden_switch(hidden_switch), .brake(brake), .reset_sync(reset_sync),
        .clock_25mhz(clock_25mhz), .fuel_pump(fuel_pump_power));
        
    status_indicator_led_fsm silfsm(.status_indicator_led_status(status_indicator_led_status),
        .clock_25mhz(clock_25mhz), .reset_sync(reset_sync), .status_indicator_led(status_indicator_led));
        
    
    assign LED[15:4] = {led1, led2, led3, led4, SW[11:4]};     
    assign JA[7:1] = 7'b0;
//    assign data = {T_DRIVER_DELAY, T_PASSENGER_DELAY, T_ARM_DELAY, T_ALARM_DELAY, 12'h456, state_hex}; // driver, passenger, arm, alarm, 4, 5, 6, state
    assign data = {hex1, hex2, hex3, hex4, 12'h456, state_hex}; // driver, passenger, arm, alarm, 4, 5, 6, state
    assign LED16_R = BTNL;                  // left button -> red led
    assign LED16_G = BTNC;                  // center button -> green led
    assign LED16_B = BTNR;                  // right button -> blue led
    assign LED17_R = BTNL;
    assign LED17_G = BTNC;
    assign LED17_B = BTNR; 
    
    
    assign LED[0] = status_indicator_led;
    assign LED[1] = fuel_pump_power;
    assign LED[3:2] = status_indicator_led_status;
    assign JA[0] = siren_out;
    
endmodule

module clock_quarter_divider(input clk100_mhz, output reg clock_25mhz = 0);
    reg counter = 0;
    
    always @(posedge clk100_mhz) begin
        counter <= counter + 1;
        if (counter == 0) begin
            clock_25mhz <= ~clock_25mhz;
        end
    end
endmodule

