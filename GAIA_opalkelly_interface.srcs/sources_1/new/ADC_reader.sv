`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2021 02:13:05 PM
// Design Name: 
// Module Name: ADC_reader
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


module ADC_reader#(
    parameter ADC_word_len = 16,
                ADC_DELAY = 10,
                CS_CLK = 20
        )(
        input logic reset,
        input logic clk,
        
// OK to ADC - SPI
        output logic adc_cs_n_o,
        output logic adc_clk_o,
        output logic adc_din_o,
       
        input logic EN_ADC,
        input logic [31:0]adc_clock_sampling_cycles,
        input logic [ADC_word_len-1:0]ADC_update_values_i,
  // ADC to PC
        input logic adc_dout_i,
        input logic [15:0]timestamp_i,
        
        output logic [31:0] ADC_word_o,
        output logic valid_out 
        
        );
        
 always_comb  adc_clk_o = clk;
        
logic r_temp_data_i,n_temp_data_i;

always_ff @(negedge  clk) begin
    if ( reset) begin
        r_temp_data_i <= 0;
    end else begin
     r_temp_data_i <= n_temp_data_i;
    end
end     
       
always_comb adc_din_o = r_temp_data_i;
 
enum logic [4:0] {IDLE, TRANSMIT, TMP } r_adc_sdo_state, n_adc_sdo_state;
always_ff @(negedge  clk) begin
     if (reset) begin
        r_adc_sdo_state <= IDLE;
    end else begin
        r_adc_sdo_state <= n_adc_sdo_state ;
        end
end 


 logic [31:0] n_counter, r_counter, n_cs_speed, r_cs_speed;
 logic rst;
always_ff @(negedge  clk) begin
    if ( reset ) begin
        r_counter <= 0;
    end else begin
     r_counter <= n_counter;
    end
end     

always_ff @(negedge  clk) begin
    if ( reset ) begin
        r_cs_speed <= 0;
    end else begin
     r_cs_speed <= n_cs_speed;
    end
end     

always_comb n_cs_speed = (adc_clock_sampling_cycles >  CS_CLK) ? adc_clock_sampling_cycles : CS_CLK ;
always_comb  n_counter = (r_counter == r_cs_speed) ? 0 : r_counter +1;     
             
logic n_adc_cs_n_o, r_adc_cs_n_o; 

always_ff @(negedge  clk) begin
     if (reset) begin
        r_adc_cs_n_o <= 1;
    end else begin
        r_adc_cs_n_o <= n_adc_cs_n_o ;
        end
end       
 
 always_comb adc_cs_n_o =r_adc_cs_n_o;

logic n_ADC_in_o, r_ADC_in_o;
always_ff @(negedge  clk) begin
     if ( reset) begin
        r_ADC_in_o <= 0;
    end else begin
        r_ADC_in_o <= n_ADC_in_o;
        end
end  
 
 
logic [15:0]n_tmp_word,r_tmp_word;

always_ff @(negedge  clk) begin
    if ( reset) begin
        r_tmp_word <= 0;
    end else begin
     r_tmp_word <= n_tmp_word;
    end
end      



logic n_valid_out, r_valid_out ;

always_ff @(negedge  clk) begin
    if (reset ==1) begin
        r_valid_out <= 0;
    end else begin
        r_valid_out <= n_valid_out;
        end
end 
always_comb valid_out = r_valid_out;
always_comb ADC_word_o = {timestamp_i,r_tmp_word};
//always_comb ADC_word_o = 32'hffffffff; 


// FSM governing the output SDO - changes at falling edge, should be read in rising edge of clk!!!
always_comb begin

             n_adc_sdo_state=r_adc_sdo_state;
             //ADC CONTROL
             n_adc_cs_n_o = r_adc_cs_n_o; 
             n_temp_data_i = 0;
             n_tmp_word = r_tmp_word;
             
             n_valid_out = 0;
    
           unique case (r_adc_sdo_state)
            IDLE : begin      
            n_tmp_word =0;
            if (n_counter ==0 && EN_ADC == 1) begin
                
                    n_adc_sdo_state = TRANSMIT;
                    n_adc_cs_n_o = 0;

                    n_temp_data_i = ADC_update_values_i[ADC_word_len-1-n_counter];

            end
           end
           
           TRANSMIT : begin
           
                     n_tmp_word[ADC_word_len-n_counter]=adc_dout_i;
                     
               if (n_counter <ADC_word_len)  begin
                     n_temp_data_i = ADC_update_values_i[ADC_word_len-1-n_counter];
                        end else begin 
                         n_adc_sdo_state = TMP;
                         n_temp_data_i = 0;
                          n_tmp_word[0]=adc_dout_i;

                end
                end

            TMP: begin
            
            if (n_counter ==(ADC_word_len+3))  begin
            
                   n_adc_cs_n_o = 1;
                   n_adc_sdo_state = IDLE;
                   n_valid_out = 1;

                   
               end
          
           end
   endcase

            
    end
endmodule     
        
        
        
 /*       
logic [15:0]r_tmp_data,n_tmp_data;

always_ff @(posedge  clk) begin
    if ( reset) begin
        r_tmp_data <= 0;
    end else begin
     r_tmp_data <= n_tmp_data;
    end
end 


logic [ADC_word_len-1:0]r_tmp_word,n_tmp_word;

always_ff @(posedge  clk) begin
    if ( reset) begin
        r_tmp_word <= 0;
    end else begin
     r_tmp_word <= n_tmp_word;
    end
end 

// Delay between readings 
logic hold_counter_read ;
logic [31:0]n_delay, r_delay;

always_comb n_delay = (r_adc_state==HOLD  )? r_delay+1 : 0;
always_comb hold_counter_read = (r_delay  >= ADC_DELAY);

always_ff @(posedge  clk) begin
    if (reset ==1 ) begin
        r_delay <= 0;
    end else begin
        r_delay <= n_delay;
        end
end 



always_comb adc_cs_n_o = r_adc_cs_n_o;
//r_adc_cs_n_o;

// set 16 bit input register 
logic [15:0] r_ADC_update_values_i, n_ADC_update_values_i; 

always_ff @(negedge  clk) begin
     if (reset) begin
        r_ADC_update_values_i <= 0;
    end else begin
        r_ADC_update_values_i <= n_ADC_update_values_i ;
        end
end 



    enum logic [4:0] {IDLE, TRANSMIT, HOLD, TMP } r_adc_state, n_adc_state;
always_ff @(posedge  clk) begin
     if (reset) begin
        r_adc_state <= IDLE;
    end else begin
        r_adc_state <= n_adc_state ;
        end
end 

logic rst;

logic n_adc_cs_n_o, r_adc_cs_n_o; 

always_ff @(posedge  clk) begin
     if (reset) begin
        r_adc_cs_n_o <= 1;
    end else begin
        r_adc_cs_n_o <= n_adc_cs_n_o ;
        end
end 

//VALUE FROM THE ADC
logic [ADC_word_len-1:0]r_ADC_word_o, n_ADC_word_o;
always_ff @(posedge  clk) begin
     if (reset) begin
        r_ADC_word_o <= 0;
    end else begin
        r_ADC_word_o <= n_ADC_word_o ;
        end
end 



always_comb adc_clk_o = clk;

logic n_ADC_in_o, r_ADC_in_o;
always_ff @(posedge  clk) begin
     if ( reset) begin
        r_ADC_in_o <= 0;
    end else begin
        r_ADC_in_o <= n_ADC_in_o;
        end
end 
always_comb adc_din_o = r_ADC_in_o;

logic[31:0] n_delay_tmp, r_delay_tmp;
logic tmp_counter_read ;

always_comb n_delay_tmp = (r_adc_state==TMP  )? r_delay_tmp+1 : 0;
always_comb tmp_counter_read = (r_delay_tmp  >= ADC_DELAY);

always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_delay_tmp <= 0;
    end else begin
        r_delay_tmp <= n_delay_tmp;
        end
end 
logic[31:0] n_delay_send, r_delay_send;
logic send_counter_read ;

always_comb n_delay_send = (r_adc_state==TRANSMIT  )? r_delay_send+1 : 0;
always_comb send_counter_read = (r_delay_send  >= ADC_DELAY);

always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_delay_send <= 0;
    end else begin
        r_delay_send <= n_delay_send;
        end
end 


logic n_valid_out, r_valid_out ;

always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_valid_out <= 0;
    end else begin
        r_valid_out <= n_valid_out;
        end
end 
always_comb valid_out = r_valid_out;
always_comb ADC_word_o = {timestamp_i,r_tmp_word};

always_comb begin

        n_adc_state=r_adc_state;
        //ADC CONTROL
        n_adc_cs_n_o = r_adc_cs_n_o;
        n_ADC_clk = r_ADC_clk;
        n_ADC_in_o = r_ADC_in_o;
        n_tmp_data = r_tmp_data;
        // READ from ADC
        n_ADC_word_o = r_ADC_word_o;
        n_tmp_word = r_tmp_word;
        n_valid_out = r_valid_out;
        
           unique case (r_adc_state)
            IDLE : begin
                  n_valid_out = 0;
                  n_tmp_word = 0'h0000;
                  n_tmp_data = ADC_update_values_i;

                  n_tmp_word[0]=adc_dout_i;  
                     
                 if  (r_counter == 20 ) begin
                         n_adc_cs_n_o = 0;
                         n_adc_state = TRANSMIT;

                end
               end 
               
          TRANSMIT : begin
          
          
          end     
               
          HOLD : begin

                     if (hold_counter_read) begin
                     // Data gets trasmitted on falling edges of the clock
                                n_ADC_in_o = n_tmp_data[15];
                                n_tmp_word[0]=adc_dout_i;

                            
                     n_adc_state = TRANSMIT;
                            
                     n_ADC_clk = 0;
                     //shift incoming work from device
                      n_tmp_word = r_tmp_word << 1;

                     end
                   
                 end
             
             TRANSMIT : begin
                 if (send_counter_read)begin

                 if  (r_counter == (ADC_word_len-1) ) begin
                    n_adc_state = TMP;
                    n_ADC_clk = 1;

                    n_tmp_word[0]=adc_dout_i;


                   end else begin
                   //transmit word to device
                      n_tmp_data = {r_tmp_data[14:0], 1'b0}; // shift data 
                      n_ADC_in_o = n_tmp_data[15];
                      
                      n_ADC_clk = 1; //counter gets updated here
                      n_adc_state = HOLD;
                      
                  // read word from device
                  
                    n_tmp_word[0]=adc_dout_i;
                    end
                    end 
                end
            TMP : begin
                    n_adc_cs_n_o  = 1;

             if  (tmp_counter_read ) begin
                     n_valid_out = 1;

                     n_adc_state = IDLE;
                     
                end 
             end
             
        endcase
     end
     
     */




