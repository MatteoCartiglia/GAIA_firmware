`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2021 04:05:33 PM
// Design Name: 
// Module Name: DAC_SPI_handler
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


module DAC_SPI_handler
        #(parameter WRITE_LEN = 24,
          parameter HOLD_DELAY = 100
        )(
        input logic reset,
        input logic clk,

// PC to OK
        input logic DAC_ValidIn_i,
        input logic [23:0]DAC_update_values_i,
        
// OK to DAC - SPI
        output logic DAC_SYNC_o,
        output logic DAC_clk_o,
        output logic DAC_in_o

          );
          
 enum logic [4:0] {IDLE ,HOLD , SEND ,TMP} r_dac_state, n_dac_state;
                     
logic [23:0]n_tmp_data, r_tmp_data;
logic n_DAC_SYNC, r_DAC_SYNC;
logic n_DAC_clk, r_DAC_clk;
logic [31:0] n_counter, r_counter;


logic n_DAC_in_o, r_DAC_in_o;

always_comb DAC_in_o = r_DAC_in_o;// TODO: MSB or LSB..
always_comb DAC_SYNC_o = r_DAC_SYNC;
always_comb DAC_clk_o = r_DAC_clk;


always_ff @(posedge  clk) begin
     if ( reset) begin
        r_DAC_in_o <= 0;
    end else begin
        r_DAC_in_o <= n_DAC_in_o;
        end
end 



always_ff @(posedge  clk) begin
     if (reset) begin
        r_counter <= 0;
    end else begin
        r_counter <= n_counter;
        end
end 

always_ff @(posedge  clk) begin
     if ( reset) begin
        r_DAC_clk <= 0;
    end else begin
        r_DAC_clk <= n_DAC_clk;
        
        end
      
end 

always_ff @(posedge  clk) begin
     if ( reset) begin
        r_DAC_SYNC <= 1;
    end else begin
        r_DAC_SYNC <= n_DAC_SYNC;
        end
end 


always_ff @(posedge  clk) begin
     if ( reset) begin
        r_tmp_data <= 0;
    end else begin
        r_tmp_data <= n_tmp_data;
        end
end 

// Delay between readings 
logic hold_counter_read ;
logic [31:0]n_delay, r_delay;

always_comb n_delay = (r_dac_state==HOLD  )? r_delay+1 : 0;
always_comb hold_counter_read = (r_delay  >= HOLD_DELAY);

always_ff @(posedge  clk) begin
    if (reset ==1 ) begin
        r_delay <= 0;
    end else begin
        r_delay <= n_delay;
        end
end 

logic[31:0] n_delay_send, r_delay_send;
logic send_counter_read ;

always_comb n_delay_send = (r_dac_state==SEND  )? r_delay_send+1 : 0;
always_comb send_counter_read = (r_delay_send  >= HOLD_DELAY);

always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_delay_send <= 0;
    end else begin
        r_delay_send <= n_delay_send;
        end
end 

logic[31:0] n_delay_tmp, r_delay_tmp;
logic tmp_counter_read ;

always_comb n_delay_tmp = (r_dac_state==TMP  )? r_delay_tmp+1 : 0;
always_comb tmp_counter_read = (r_delay_tmp  >= HOLD_DELAY);

always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_delay_tmp <= 0;
    end else begin
        r_delay_tmp <= n_delay_tmp;
        end
end 


always_ff @(posedge  clk) begin
    if (reset ==1 ) begin
        r_dac_state <= IDLE;
    end else begin
        r_dac_state <= n_dac_state;
        end
end 
always_comb n_counter = (r_DAC_clk==0 && n_DAC_clk==1 ) ? r_counter+1 : ( (r_dac_state == TMP) ? 0: r_counter ) ;

always_comb begin
         
         n_dac_state = r_dac_state;
         n_DAC_clk  = r_DAC_clk;
         n_DAC_SYNC  = r_DAC_SYNC;
         n_tmp_data = r_tmp_data;
         n_DAC_in_o = r_DAC_in_o;

                  
           unique case (r_dac_state)
            IDLE : begin
            n_DAC_SYNC = 1;
            n_DAC_clk = 0;
        
                if (DAC_ValidIn_i) begin
                     n_DAC_SYNC = 0;
                     n_tmp_data = DAC_update_values_i;
                     n_dac_state = HOLD;
                     n_DAC_in_o = n_tmp_data[23];
                     n_DAC_clk = 1;

                     end else begin
                     n_DAC_clk = 0;
                 
                    end
                end
            HOLD : begin
        
               if (hold_counter_read) begin
                     // Data gets trasmitted on falling edges of the clock
                     n_DAC_clk = 0;
                     n_dac_state = SEND;
                     end
                end
            SEND : begin
                if (send_counter_read)begin
                    if (r_counter == (WRITE_LEN) ) begin //  transmission finished
                          n_dac_state = TMP;
                          n_DAC_SYNC = 1;

                          end else begin
                          n_tmp_data = {r_tmp_data[22:0], 1'b0}; // shift data 
                          n_DAC_clk = 1;
                          n_dac_state = HOLD;
                          n_DAC_in_o = n_tmp_data[23];
                         end
                        end
                      end
                    
            TMP : begin
               if (tmp_counter_read) begin
                   n_dac_state <= IDLE;
                    end
                end      
           endcase
end
endmodule