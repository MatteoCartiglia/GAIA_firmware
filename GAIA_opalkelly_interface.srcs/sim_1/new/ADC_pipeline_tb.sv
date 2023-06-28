`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2021 11:31:15 AM
// Design Name: 
// Module Name: ADC_pipeline_tb
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


module ADC_pipeline_tb();

timeunit 1ns;
timeprecision 1ps;

localparam time CLK_PERIOD = 50ns;
localparam  RST_CLK_CYCLES = 5;
localparam ADC_WRITE_LEN = 16;
localparam ADC_DELAY = 2;
localparam CONV_TIME_UNIT_US = 1000;
localparam NUM_BITS_TIME = 16;

initial begin
    clk = 0;
    reset = 1;
    #(RST_CLK_CYCLES*CLK_PERIOD + CLK_PERIOD/2-1) reset = 0;
end

always #(CLK_PERIOD/2) clk = ~clk;

logic [ADC_WRITE_LEN-1:0]ADC_update_values_word3_i;
logic [ADC_WRITE_LEN-1:0] adc_word,ADC_update_values_i;
logic trig_in;

logic reset, clk;
logic adc_cs_n_o;
logic adc_din_o;
logic [15:0]timestamp_i;
logic adc_dout_i;
logic [31:0] ADC_word_o;
logic valid_out;
logic adc_clk_o;
logic [19:0]adc_clock_sampling_cycles = 1000000;

logic EN_ADC = 0;
initial begin 

adc_dout_i = 1;
timestamp_i = 16'hFFFF;

ADC_update_values_word3_i = 16'hFFFF;
trig_in=0;

#(CLK_PERIOD*1000);
adc_dout_i = 0;
trig_in=1;
#(CLK_PERIOD);
trig_in=0;
#(CLK_PERIOD*10);
adc_dout_i = 1;
#(CLK_PERIOD*10);
adc_dout_i = 0;
#(CLK_PERIOD*10);
adc_dout_i = 1;
EN_ADC = 1;
end 


ADC_init 
#( 
)ADC_init(
       .reset(reset),
       .clk(clk),
       
     .adc_cs_n_i (adc_cs_n_o),
    .ADC_update_values_word3_i(ADC_update_values_word3_i),
    .trig_in(trig_in),
    .adc_word_o(adc_word)
       
);
 ADC_reader 
 #( .ADC_word_len (ADC_WRITE_LEN),
     .ADC_DELAY(ADC_DELAY)
     )ADC_reader(
       .reset(reset),
       .clk(clk),
       .EN_ADC(EN_ADC),
       .adc_clock_sampling_cycles(adc_clock_sampling_cycles),

       .adc_cs_n_o(adc_cs_n_o),
        .adc_din_o(adc_din_o),
        .adc_clk_o(adc_clk_o),

       .ADC_update_values_i(adc_word),
        .adc_dout_i(adc_dout_i),
        .timestamp_i(timestamp_i),
       
        .ADC_word_o(ADC_word_o),
        .valid_out(valid_out)

          );
          
endmodule