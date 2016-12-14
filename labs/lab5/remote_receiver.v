`timescale 1ns / 1ps

module remote_receiver(input clock_27mhz, reset,
                       input ir_in,
                       input btn_0, btn_1, btn_2, btn_3,
                       output[6:0] receive_command,
                       output[6:0] transmit_command,
                       output[4:0] receive_address,
                       output[4:0] transmit_address,
                       output transmit_enable,
                       output[27:0] debug_display);

    parameter S_IDLE = 2'd0;
    parameter S_BUTTON = 2'd1;
    parameter S_TX = 2'd2;
    parameter S_RX = 2'd3;

    reg [1:0] which_btn;
    reg [1:0] state, next_state;
    wire [2:0] learn_fsm_state;

    wire [4:0] addresses[3:0] = 0;
    wire [6:0] commands[3:0] = 0;

    wire [4:0] cur_rec_address = 0;
    wire [6:0] cur_rec_command = 0;
    reg [4:0] transmit_address_reg = 0;
    reg [6:0] transmit_command_reg = 0;

    wire start_btn_timer, btn_timer_expired, btn_long_press;
    timer t_btn (.clk(clock_27mhz),
                 .reset(reset),
                 .start_timer(start_btn_timer),
                 .length(16'd1333),  // 100 ms
                 .expired(btn_timer_expired));

    timer tx_delay (.clk(clock_27mhz),
                    .reset(reset),
                    .start_timer(start_tx_timer),
                    .length(16'd2666),  // 200 ms
                    .expired(tx_done));



    learn_fsm lfsm(.clock_27mhz(clock_27mhz),
                   .reset      (reset),
                   .ir_in      (ir_in),
                   .start_learn(start_learn),
                   .out_ready  (receive_ready),
                   .command    (cur_rec_command),
                   .address    (cur_rec_address),
                   .debug_state(learn_fsm_state));

    always @(posedge clock_27mhz) begin
        if (reset) begin
            state <= S_IDLE;
            addresses <= 0;
            commands <= 0;
        end
        else if (state == S_IDLE && next_state == S_BUTTON) begin
            start_btn_timer <= 1;
        end
        else if (state == S_BUTTON && next_state == S_BUTTON) begin
            start_btn_timer <= 0;
            if (btn_timer_expired) begin
                btn_long_press <= 1;
            end

            if (~btn_0) begin
                which_btn <= 2'b00;
            end else if (~btn_1) begin
                which_btn <= 2'b01;
            end else if (~btn_2) begin
                which_btn <= 2'b10;
            end else if (~btn_3) begin
                which_btn <= 2'b11;
            end else begin
                which_btn <= 2'b00; // go ahead and set it to something
            end
        end else if (state == S_BUTTON && next_state == S_TX) begin
            transmit_enable <= 1;
            transmit_command_reg <= commands[which_btn];
            transmit_address_reg <= addresses[which_btn];
            start_tx_timer <= 1;
        end else if (state = S_TX && next_state == S_IDLE) begin
            start_tx_timer <= 0;
        end else if (state == S_BUTTON && next_state == S_RX) begin
            start_learn <= 1;
        end else if (state == S_RX && next_state == S_RX) begin
            start_learn <= 0;
        end else if (state == S_RX && next_state == S_IDLE) begin
            commands[which_btn] <= cur_rec_command;
            addresses[which_btn] <= cur_rec_address;
        end


        state <= next_state;
    end

    always @(*) begin
        case (state)
            S_IDLE: next_state <= (~btn_0 || ~btn_1 || ~btn_2 || ~btn_3) ? S_BUTTON : S_IDLE;
            S_BUTTON: next_state <= (~btn_0 || ~btn_1 || ~btn_2 || ~btn_3) ? S_BUTTON : (btn_long_press ? S_RX : S_TX);
            S_TX: next_state <= (tx_done) ? S_IDLE : S_TX;
            S_RX: next_state <= (receive_ready) ? S_IDLE : S_RX;
            default: next_state <= S_IDLE;
        endcase // state
    end

    assign transmit_command = transmit_command_reg;
    assign transmit_address = transmit_address_reg;
    assign receive_command = cur_rec_command;
    assign receive_address = cur_rec_address;


    assign debug_display[27:8] = 0;
    assign debug_display[7] = 1'btn_0;
    assign debug_display[6:4] = learn_fsm_state;
    assign debug_display[3:2] = 2'btn_0;
    assign debug_display[1:0] = state;
    
endmodule // remote_receiver