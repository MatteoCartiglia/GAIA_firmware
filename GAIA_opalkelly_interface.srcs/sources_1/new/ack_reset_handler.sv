`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2022 01:22:05 PM
// Design Name: 
// Module Name: ack_reset_handler
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


module ack_reset_handler #(
    parameter timeout_len = 2000000000 //10ns 

       )(
       input logic reset,
       input logic clk,
        input logic trigger,
       output logic r_trig_flag
        
    );

always_comb n_trig = trigger;


logic n_trig, r_trig, reset_flag;
logic n_trig_flag, r_trig_flag;


always_ff @(posedge  clk) begin
    if ( reset) begin
        r_trig <= 0;
    end else begin
     r_trig <= n_trig;
    end
end 

always_ff @(posedge  clk) begin
    if ( reset) begin
        r_trig_flag <= 0;
    end else begin
     r_trig_flag <= n_trig_flag;
    end
end 

always_comb n_trig_flag = (n_trig ==1 && r_trig==0) ? 1 : (reset_flag) ? 0 : r_trig_flag;
always_comb  reset_flag = (r_counter == timeout_len) ? 1 : 0;     




logic [31:0] n_counter, r_counter;

always_ff @(negedge  clk) begin
    if ( reset || n_trig ) begin
        r_counter <= 0;
    end else begin
     r_counter <= n_counter;
    end
end     


always_comb  n_counter = r_counter +1;     



endmodule
