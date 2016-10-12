`timescale 1ns / 1ps

module anti_theft_fsm(
    input ignition_switch,
    input driver_door,
    input passenger_door,
    input clock_25mhz,
    input reset_sync,
    input [3:0] T_DRIVER_DELAY,
    input [3:0] T_PASSENGER_DELAY,
    input [3:0] T_ARM_DELAY,
    input [3:0] T_ALARM_DELAY,
    output [1:0] status_indicator_led_status, // 00: off, 11: blinking, 01: on
    output sound,
    output [3:0] state_hex, hex1, hex2, hex3, hex4
    );
    
    parameter S_armed            = 4'h0;
    parameter S_armed1           = 4'h1;  // driver door
    parameter S_armed1_triggered = 4'h2;
    parameter S_armed2           = 4'h3;  // passenger door
    parameter S_armed2_triggered = 4'h4;
    parameter S_sound            = 4'h5;
    parameter S_sound1           = 4'h6;  // after door closes
    parameter S_sound2           = 4'h7;
    parameter S_disarmed         = 4'h8;
    parameter S_disarmed1        = 4'h9;
    parameter S_disarmed2        = 4'ha;
    parameter S_disarmed3        = 4'hb;
    parameter S_disarmed4        = 4'hc;
    
    wire driver_expired;
    reg start_driver;
    wire passenger_expired;
    reg start_passenger;
    wire arm_expired;
    reg start_arm;
    wire sound_expired;
    reg start_sound;

    timer timer_driver(.clock_25mhz(clock_25mhz), .reset_sync(reset_sync), .value(T_DRIVER_DELAY),  
        .expired(driver_expired), .start_timer(start_driver), .output_hex(hex1));
    timer timer_passenger(.clock_25mhz(clock_25mhz), .reset_sync(reset_sync), .value(T_PASSENGER_DELAY),
        .expired(passenger_expired), .start_timer(start_passenger), .output_hex(hex2));
    timer timer_arm(.clock_25mhz(clock_25mhz), .reset_sync(reset_sync), .value(T_ARM_DELAY),
        .expired(arm_expired), .start_timer(start_arm), .output_hex(hex3));
    timer timer_sound(.clock_25mhz(clock_25mhz), .reset_sync(reset_sync), .value(T_ALARM_DELAY),
            .expired(sound_expired), .start_timer(start_sound), .output_hex(hex4));

    reg [3:0] state, next_state;
    always @(*) begin
      case (state)
        S_armed: begin
            next_state <= ignition_switch ? S_disarmed : (driver_door ? S_armed1 : (passenger_door ? S_armed2 : S_armed));
        end
        S_armed1: begin
            start_driver <= 1;  // start countdown on driver
            next_state <= ignition_switch ? S_disarmed : S_armed1_triggered;
        end
        S_armed1_triggered: begin
            start_driver <= 0;
            next_state <= ignition_switch ? S_disarmed : (driver_expired ? S_sound : S_armed1_triggered);
        end
        S_armed2: begin
            start_passenger <= 1;  // start countdown on passenger
            next_state <= ignition_switch ? S_disarmed : S_armed2_triggered; 
        end
        S_armed2_triggered: begin
            start_passenger <= 0;
            next_state <= ignition_switch ? S_disarmed : (passenger_expired ? S_sound : S_armed2_triggered);
        end
        S_sound: begin
            next_state <= ignition_switch ? S_disarmed : ((driver_door || passenger_door) ? S_sound : S_sound1);
        end
        S_sound1: begin
            start_sound <= 1;
            next_state <= ignition_switch ? S_disarmed : S_sound2;
        end
        S_sound2: begin
            start_sound <= 0;
            next_state <= ignition_switch ? S_disarmed : (sound_expired ? S_armed : S_sound2);
        end
        S_disarmed: begin
            next_state <= ignition_switch ? S_disarmed : S_disarmed1;
        end
        S_disarmed1: begin
            next_state <= ignition_switch ? S_disarmed : (driver_door ? S_disarmed2 : S_disarmed1);
        end
        S_disarmed2: begin
            next_state <= ignition_switch ? S_disarmed : (driver_door ? S_disarmed2 : S_disarmed3);
        end
        S_disarmed3: begin
            start_arm <= 1;
            next_state <= (ignition_switch | driver_door) ? S_disarmed : S_disarmed4;
        end
        S_disarmed4: begin
            start_arm <= 0;
            next_state <= (ignition_switch | driver_door) ? S_disarmed : (arm_expired ? S_armed : S_disarmed4);
        end

        default: next_state = S_armed;
      endcase
    end

    always @(posedge clock_25mhz) state <= next_state;
    
    assign status_indicator_led_status[0] = (
        state != S_disarmed &&
        state != S_disarmed1 &&
        state != S_disarmed2 &&
        state != S_disarmed3 &&
        state != S_disarmed4);  // on at all?
    assign status_indicator_led_status[1] = (
        state == S_armed);  // blinking?
    assign sound = S_sound;
    
    assign state_hex = state;

endmodule
