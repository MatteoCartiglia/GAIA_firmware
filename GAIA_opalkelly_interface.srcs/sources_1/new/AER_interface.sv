`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/11/2021 01:04:59 PM
// Design Name:
// Module Name: AER_interface
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


// Mealy FSM with one-hot encoding of state for a 1 bit address 4-phase handshake

module AER_interface
        #(
          parameter DELAY_REQ = 100, //10 ns clk
          parameter DATA_NUM_BITS = 32,
          parameter AER_NUM_BITS = 16, 
        parameter TS_NUM_BITS = 16
        )(
        input logic reset,
        input logic clk,

// fifo interface

        output logic [DATA_NUM_BITS-1:0] dataout_o,
        output logic valid_o,
        input logic enable_i,

        
        input logic [TS_NUM_BITS-1:0]timestamp_i, 

//MEA interface
        output logic ack_o,        
        input logic req_i,
        input logic [AER_NUM_BITS-1:0]addr_i
          );


 enum logic [3:0] {IDLE, ACK_HIGH,READY_TO_READ ,REQ_LOW} r_aer_state, n_aer_state;

 logic [DATA_NUM_BITS-1:0] n_delay_ack , r_delay_ack;
 logic [DATA_NUM_BITS-1:0] n_delay_req , r_delay_req;
 logic n_valid = 0, r_valid;
 logic [DATA_NUM_BITS-1:0]n_dataout, r_dataout;  
 logic ready_to_store;

always_comb ready_to_store = (r_valid == 0 || enable_i == 1);
 
always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_aer_state <= IDLE;
    end else begin
        r_aer_state <= n_aer_state;
    end
end 
   
always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_dataout <= 0;
    end else begin
        r_dataout <= n_dataout;
    end
end 
   
always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_valid <= 0;
    end else begin
        r_valid <= n_valid;
        end
end 

 always_comb dataout_o = r_dataout;
 always_comb valid_o = r_valid;


// Counter between req high and bringing the ack high to make the lines settle

logic reset_counter_req_data ;
always_comb n_delay_req = (r_aer_state==READY_TO_READ)? r_delay_req+1 : 0;
always_comb reset_counter_req_data = (r_delay_req  >= DELAY_REQ);

always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_delay_req <= 0;
    end else begin
        r_delay_req <= n_delay_req;
    end
end 

//----------------
 // logic [15:0]r_counter_dis, n_counter_dis;
   
   // always_ff @(posedge  clk) begin
   //     if (reset ==1) begin
   //         r_counter_dis <= 0;
   //     end else begin
  //          r_counter_dis <= n_counter_dis;
  //          end
  //  end 
    
  //  always_comb n_counter_dis = ( (req_i == 1 & ready_to_store == 1) ) ? r_counter_dis+1 : r_counter_dis;
 //  everytime an event gets generated  and fifo is ready to get a new event (req_i == 1 & ready_to_store == 1)


//---
always_comb begin

         n_aer_state = r_aer_state;
         n_valid = 0;
         n_dataout = r_dataout;
         ack_o = 0;
         

         unique case (r_aer_state)
            IDLE : begin

                 if (req_i == 1 & ready_to_store == 1) begin                    
                  n_dataout = {timestamp_i, addr_i};

                   n_aer_state = ACK_HIGH;
                    
                    end
                end
               
            READY_TO_READ : begin

                  n_dataout = {timestamp_i, addr_i};

                if (reset_counter_req_data) begin
                  n_aer_state = ACK_HIGH;
                  end

            end

            ACK_HIGH : begin
                  n_valid = 1;
                  ack_o = 1;
                  n_aer_state = REQ_LOW;

            end

            REQ_LOW  : begin

               if (req_i == 0) begin
                    ack_o = 0;
                    n_aer_state = IDLE;
                end else begin 
                    ack_o = 1;

                end
              end 
           endcase
end
endmodule