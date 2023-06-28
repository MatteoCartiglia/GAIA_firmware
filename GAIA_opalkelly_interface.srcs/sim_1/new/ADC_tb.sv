`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2021 03:43:04 PM
// Design Name: 
// Module Name: ADC_tb
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
module ADC_tb();

timeunit 1ns;
timeprecision 1ps;

localparam time CLK_PERIOD = 10ns;
localparam  RST_CLK_CYCLES = 5;
localparam ADC_WRITE_LEN = 16;

initial begin
    clk = 0;
    reset = 1;
    #(RST_CLK_CYCLES*CLK_PERIOD + CLK_PERIOD/2-1) reset = 0;
end

always #(CLK_PERIOD/2) clk = ~clk;

initial begin 

adc_dout_i = 1;
timestamp_i = 16'hFFFF;
ADC_update_values_i = 16'hF00F;

#(CLK_PERIOD*100);
adc_dout_i = 0;
#(CLK_PERIOD*100);
adc_dout_i = 1;
#(CLK_PERIOD*100);
adc_dout_i = 0;
#(CLK_PERIOD*100);
adc_dout_i = 1;

end 


logic reset, clk;
logic adc_cs_n_o;
logic adc_din_o;
logic [15:0]timestamp_i;
logic adc_dout_i;
logic [15:0]ADC_update_values_i;
logic [31:0] ADC_word_o;
logic valid_out;
logic adc_clk_o;


 ADC_reader 
 #( .ADC_word_len (ADC_WRITE_LEN)
     )ADC_reader(
       .reset(reset),
       .clk(clk),
       
       .adc_cs_n_o(adc_cs_n_o),
        .adc_din_o(adc_din_o),
        .adc_clk_o(adc_clk_o),

       .ADC_update_values_i(ADC_update_values_i),
        .adc_dout_i(adc_dout_i),
        .timestamp_i(timestamp_i),
       
        .ADC_word_o(ADC_word_o),
        .valid_out(valid_out)

          );
          



endmodule