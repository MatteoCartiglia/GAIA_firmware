`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2021 09:26:43 AM
// Design Name: 
// Module Name: ts_counter_tb
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


module ts_counter_tb();

timeunit 1ns;
timeprecision 1ps;


localparam time CLK_PERIOD = 10ns;
localparam RST_CLK_CYCLES = 5;
localparam CONV_TIME_UNIT_US = 1000;
localparam NUM_BITS_TIME = 16;



logic [15:0]timestamp;

logic clk;
logic reset;

always #(CLK_PERIOD/2) clk = ~clk;

always_comb timestamp = r_time_us;


localparam NUM_CYCLES_PER_TUNIT = CONV_TIME_UNIT_US / CLK_PERIOD;
localparam MAX_TIME_STAMP = 2**(NUM_BITS_TIME)-1;
logic [NUM_BITS_TIME-1:0] n_counter_ns, r_counter_ns, n_time_us, r_time_us,n_time_us_out, r_time_us_out;
logic advance_time;

always_comb advance_time = r_counter_ns == NUM_CYCLES_PER_TUNIT-1;
always_comb n_time_us = advance_time ? r_time_us+1 : r_time_us;
always_comb n_counter_ns = advance_time ? 0 : r_counter_ns +1;

always_ff @(posedge clk) begin

    if (reset) begin
        r_counter_ns <= 0;
        r_counter_ns[0] <= 0;
     end else begin
        r_counter_ns <= n_counter_ns;
      end
     end
     
 always_ff @(posedge clk) begin

    if (reset) begin
        r_time_us <= 0;
     end else begin
        r_time_us <= n_time_us;
     end
  end
         

always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_timestamp_i <= 0;
    end else begin
        r_timestamp_i <= n_timestamp_i;
    end
end    

always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_valid <= 0;
    end else begin
        r_valid <= n_valid;
    end
end        

logic [15:0]r_timestamp_i, n_timestamp_i;
always_comb n_timestamp_i = timestamp;
      
logic enable_i=1, r_valid , n_valid;

always_comb  n_valid = ( n_timestamp_i == 16'hFFFF) ? 1 :( (enable_i == 1 ) ? 0 : r_valid); 




initial begin
    clk = 0;
    reset = 1;
    #(RST_CLK_CYCLES*CLK_PERIOD + CLK_PERIOD/2-1) reset = 0;
end



endmodule
