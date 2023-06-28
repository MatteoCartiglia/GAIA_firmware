`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2022 04:34:02 PM
// Design Name: 
// Module Name: ack_reset_handler_tb
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


module ack_reset_handler_tb();

timeunit 1ns;
timeprecision 1ps;

localparam time CLK_PERIOD = 10ns;
localparam  RST_CLK_CYCLES = 5;
localparam  ACK_TIMEOUT = 20;


initial begin
    clk = 0;
    reset = 1;
    #(RST_CLK_CYCLES*CLK_PERIOD + CLK_PERIOD/2-1) reset = 0;
end

always #(CLK_PERIOD/2) clk = ~clk;

logic trig,clk;

initial begin 

#(CLK_PERIOD*1000);
trig=1;
#(CLK_PERIOD);
trig=0;
#(CLK_PERIOD*1000);
trig=1;
#(CLK_PERIOD);
trig=0;

end 


logic ack_flag,reset;

 ack_reset_handler #(
     .timeout_len(ACK_TIMEOUT) //10ns 
       )ack_reset_handler(
       .reset(reset),
        .clk(clk),
         .trigger(trig),
          .r_trig_flag(ack_flag)        
    );


endmodule
