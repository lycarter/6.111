///////////////////////////////////////////////////////////////////////////////
//
// 6.111 Remote Control Transmitter Module
//
// Outputs a 12-bit Sony remote control signal based on the Sony Infrared Command 
// (SIRC) specification. signal_out can be used to control a TSKS400S Infrared 
// Emitting Diode, using a BJT to produce a stronger driving signal.
// SIRC uses pulse-width modulation to encode the 10-bit signal, with a 600us 
// base frequency modulated by a 40kHz square wave with 25% duty cycle.
//
// Created: February 29, 2009
// Author: Adam Lerer,
// Updated October 4, 2010 - fixed 40Khz modulation, inserted 45ms between commands
//
///////////////////////////////////////////////////////////////////////////////
module remote_transmitter (input wire clk, //27 mhz clock
                                    input wire reset, //FPGA reset
                                    input wire [4:0] address, // 5-bit signal address
                                    input wire [6:0] command, // 7-bit signal command
                                    input wire transmit, // transmission occurs when transmit is asserted
                                    output wire signal_out); //output to IR transmitter

  wire [11:0] value = {address, command}; //the value to be transmitted
  
  ///////////////////////////////////////////////////////////////////////////////////////
  //
  // here we count the number of "ones" in the signal, subtract from wait time
  // and pad the wait state to start the next command sequence exactly 45ms later. 
  wire [3:0] sum_ones = address[4] + address[3] + address[2] + address[1] + address[0] +
                command[6] + command[5] + command[4] + command[3] + command[2] + command[1] + command[0];
  wire[9:0] WAIT_TO_45MS = 10'd376 - (sum_ones*8);
  //
  ///////////////////////////////////////////////////////////////////////////////////////
  
  reg [2:0] next_state;
  // cur_value latches the value input when the transmission begins,
  // and gets right shifted in order to transmit each successive bit
  reg [11:0] cur_value;
  // cur_bit keeps track of how many bits have been transmitted
  reg [3:0] cur_bit;
  reg [2:0] state;
  
  wire [9:0] timer_length;  // large number of future options
  
  localparam IDLE =  3'd0;
  localparam WAIT =  3'd1;
  localparam START = 3'd2;
  localparam TRANS = 3'd3;
  localparam BIT =   3'd4;
  
  // this counter is used to modulate the transmitted signal 
  // by a 40kHz 25% duty cycle square wave  gph 10/2/2010
  reg [10:0] mod_count;  
  
  wire start_timer;
  wire expired;
  
  timer t (.clk(clk),
           .reset(reset),
              .start_timer(start_timer),
              .length(timer_length),
              .expired(expired));
              
  always@(posedge clk) 
  begin
    // signal modulation
     mod_count <= (mod_count == 674) ? 0 : mod_count + 1;   // was 1349 
    if (reset)
       state <= IDLE;
     else begin
       if (state == START) 
        begin
          cur_bit <= 0;
          cur_value <= value;
        end
        // when a bit finishes being transmitted, left shift cur_value
        // so that the next bit can be transmitted, and increment cur_bit
       if (state == BIT && next_state == TRANS) 
        begin
          cur_bit <= cur_bit + 1;
          cur_value <= {1'b0, cur_value[11:1]};
        end
      state <= next_state;
    end
  end
  
  always@* 
  begin
    case(state)
       IDLE:  next_state = transmit  ? WAIT : IDLE;
        WAIT:  next_state = expired ? (transmit ? START : IDLE) : WAIT;
        START: next_state = expired ? TRANS : START;
        TRANS: next_state = expired ? BIT : TRANS;
        BIT :  next_state = expired ? (cur_bit == 11 ? WAIT : TRANS) : BIT;
        default: next_state = IDLE;
     endcase 
  end
  // always start the timer on a state transition
  assign start_timer = (state != next_state);
  assign timer_length = (next_state == WAIT) ? WAIT_TO_45MS :  // was 63; 600-4-24-6 = 566
                        (next_state == START) ? 10'd32 :
                                (next_state == TRANS) ? 10'd8 :
                                (next_state == BIT ) ? (cur_value[0] ? 10'd16 : 10'd8 ) : 10'd0;
  assign signal_out = ((state == START) || (state == BIT)) && (mod_count < 169);    // was 338  gph                 
endmodule

