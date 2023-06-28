`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2021 04:04:17 PM
// Design Name: 
// Module Name: AER_generator
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


module AER_generator#(
    parameter NUM_AER = 3 ,
    parameter DATA_NUM_BITS = 32,
    parameter AER_NUM_BITS = 16,
    parameter DELAY_REQ = 10,
    parameter TS_NUM_BITS = 16
    

)(
        input logic reset,
        input logic clk,

// dis interface

        output logic [NUM_AER-1:0][DATA_NUM_BITS-1:0] aer_dataout_o,
        output logic [NUM_AER-1:0] aer_valid_o,
        input logic [NUM_AER-1:0] aer_enable_i,
        input logic [TS_NUM_BITS-1:0]timestamp_i, 
        
  // DRF redundancy filter between dis and fifo
      
        output logic [NUM_AER-1:0][DATA_NUM_BITS-1:0] dataout_o,
        output logic [NUM_AER-1:0] valid_o,
        input logic [NUM_AER-1:0] enable_i,
     
        
        
 // FIFO interface       
        input logic prog_full, 

        
//MEA interface
        output logic [NUM_AER-1:0] ack_o,        
        input logic [NUM_AER-1:0] req_i,
        input logic [NUM_AER-1:0][AER_NUM_BITS-1:0] addr_i,
        output logic [NUM_AER-1:0]led_status
      );
          


          
    generate
        //Generate per-AER pipeline
        for(genvar aer_idx = 0; aer_idx < (NUM_AER-2); aer_idx++) begin 
        
        // remove ts and trigger hence the -2
            AER_interface  #(
                 .DELAY_REQ(DELAY_REQ),
                  .DATA_NUM_BITS(DATA_NUM_BITS),
                  .AER_NUM_BITS(AER_NUM_BITS),
                  .TS_NUM_BITS(TS_NUM_BITS)
                )AER(
                .clk(clk),
                .reset(reset),
                .ack_o(ack_o[aer_idx]),
                .req_i(req_i[aer_idx]),
                .addr_i(addr_i[aer_idx]),
                .timestamp_i(timestamp_i),
                
                .dataout_o(aer_dataout_o[aer_idx]),     
                .valid_o(aer_valid_o[aer_idx]),
                .enable_i(aer_enable_i[aer_idx])

            );
            // Data redundancy filter between aer and dis

             drf  #(
               .DATA_NUM_BITS(DATA_NUM_BITS)
                     )i_drf(
                .clk(clk),
                .reset(reset),
                .valid_i(aer_valid_o[aer_idx]),
                .data_i(aer_dataout_o[aer_idx]),
                .enable_o(aer_enable_i[aer_idx]),
                
                .valid_o(valid_o[aer_idx]),
                .data_o(dataout_o[aer_idx]),
                .enable_i(enable_i[aer_idx]),
                .led_status(led_status[aer_idx])
            );         
        end
        
    ts_overflow (
                .clk(clk),
                .reset(reset),
                .ack_o(ack_o[NUM_AER-2]),
                .req_i(req_i[NUM_AER-2]),
                .addr_i(addr_i[NUM_AER-2]),
                .timestamp_i(timestamp_i),
                .dataout_o(dataout_o[NUM_AER-2]),
                .valid_o(valid_o[NUM_AER-2]),
                .enable_i(enable_i[NUM_AER-2])
                );
                //valid_o[NUM_AER-1]
                
                
     trigger_AER (
                .clk(clk),
                .reset(reset),
                .ack_o(ack_o[NUM_AER-1]),
                .req_i(req_i[NUM_AER-1]),
                .addr_i(addr_i[NUM_AER-1]),
                .timestamp_i(timestamp_i),
                .dataout_o(dataout_o[NUM_AER-1]),
                .valid_o(valid_o[NUM_AER-1]),
                .enable_i(enable_i[NUM_AER-1])
                //valid_o[NUM_AER-1]
);
    endgenerate
endmodule
