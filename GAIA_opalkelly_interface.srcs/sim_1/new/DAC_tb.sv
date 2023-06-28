`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2021 03:51:59 PM
// Design Name: 
// Module Name: DAC_tb
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


module DAC_tb();

timeunit 1ns;
timeprecision 1ps;

localparam time CLK_PERIOD = 10ns;
localparam  RST_CLK_CYCLES = 5;

localparam  DAC_DELAY = 2;
localparam  WRITE_LEN = 24;


        logic reset;
        logic clk;
// PC to OK
         logic DAC_ValidIn_i;
         logic [23:0]DAC_update_values_i;
        
// OK to DAC - SPI
         logic DAC_SYNC_o;
         logic DAC_clk_o;
         logic DAC_in_o;


always #(CLK_PERIOD/2) clk = ~clk;

initial begin
    clk = 0;
    reset = 1;
    #(RST_CLK_CYCLES*CLK_PERIOD + CLK_PERIOD/2-1) reset = 0;
end


initial begin 
DAC_ValidIn_i = 0;

wait(~reset);
#(10*CLK_PERIOD);

DAC_ValidIn_i = 1;
DAC_update_values_i = 24'h000000;

#(CLK_PERIOD);
DAC_ValidIn_i = 0;

end 

 DAC_SPI_handler 
 #( .WRITE_LEN (WRITE_LEN),
   .HOLD_DELAY (DAC_DELAY)
     )DAC_SPI_handler(
       .reset(reset),
       .clk(clk),
// PC to OK
       .DAC_ValidIn_i(DAC_ValidIn_i),
        .DAC_update_values_i(DAC_update_values_i),
// OK to DAC - SPI
       .DAC_SYNC_o(DAC_SYNC_o),
        .DAC_clk_o(DAC_clk_o),
        .DAC_in_o(DAC_in_o)

          );
          
endmodule