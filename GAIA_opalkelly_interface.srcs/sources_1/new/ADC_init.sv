`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2021 04:50:32 PM
// Design Name: 
// Module Name: ADC_init
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


module ADC_init#(
    parameter ADC_word_len=16,
    parameter word1= 16'h2000,//2000
    parameter word2= 16'h8000 //8000
       )(
        input logic reset,
        input logic clk,
        
        input logic adc_cs_n_i,
        input logic [ADC_word_len-1:0]ADC_update_values_word3_i,
        
        input logic trig_in,
        
        output logic [ADC_word_len-1:0] adc_word_o,
        output logic ack_trig
    );



enum logic [4:0] {IDLE, WORD1, WORD2, WORD3 } r_adc_init_state, n_adc_init_state;
always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_adc_init_state <= IDLE;
    end else begin
        r_adc_init_state <= n_adc_init_state;
        end
end 

logic [ADC_word_len-1:0] n_adc_word, r_adc_word;

always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_adc_word <= 0;
    end else begin
        r_adc_word <= n_adc_word;
        end
end
always_comb adc_word_o = r_adc_word;

always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_input_trig_set <= 0;
    end else begin
        r_input_trig_set <= n_input_trig_set;
        end
end
always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_input_set <= 0;
    end else begin
        r_input_set <= n_input_set;
        end
end
logic n_input_set, r_input_set, n_input_trig_set, r_input_trig_set;
always_comb n_input_set = trig_in;


 always_comb n_input_trig_set =(r_input_set==0 && n_input_set==1 )? 1: (r_adc_init_state==IDLE) ?r_input_trig_set :0;



logic n_adc_cs_n_i, r_adc_cs_n_i;
always_ff @(posedge  clk) begin
    if (reset ==1 ) begin
        r_adc_cs_n_i <= 0;
    end else begin
        r_adc_cs_n_i <= n_adc_cs_n_i;
        end
end 


always_comb n_adc_cs_n_i = adc_cs_n_i;
always_comb begin

      n_adc_init_state = r_adc_init_state;
      n_adc_word =r_adc_word;
      ack_trig = 0;
        
           unique case (r_adc_init_state)
            IDLE : begin
             n_adc_word = 16'h0000;
                if (adc_cs_n_i && r_input_trig_set) begin
                n_adc_init_state = WORD1;
                ack_trig =1;
                    end 
                end
            WORD1 : begin
                n_adc_word = word1;
                if (n_adc_cs_n_i == 1 && r_adc_cs_n_i==0) n_adc_init_state = WORD2;
                end
            
            WORD2 : begin
                n_adc_word = word2;
                if (n_adc_cs_n_i == 1 && r_adc_cs_n_i==0) n_adc_init_state = WORD3;
    
                end
   
           WORD3 : begin
                 n_adc_word = ADC_update_values_word3_i;
                 if (n_adc_cs_n_i == 1 && r_adc_cs_n_i==0) n_adc_init_state = IDLE;
    
                end         
            endcase
            end
endmodule
