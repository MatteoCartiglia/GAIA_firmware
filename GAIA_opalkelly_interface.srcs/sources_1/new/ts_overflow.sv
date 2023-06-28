`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2021 04:29:49 PM
// Design Name: 
// Module Name: ts_overflow
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


module ts_overflow
      (
        input logic reset,
        input logic clk,

// fifo interface

        output logic [31:0] dataout_o,
        output logic valid_o,
        input logic enable_i,
        
        input logic [15:0]timestamp_i, 

//MEA interface
        output logic ack_o,        
        input logic req_i,
        input logic [15:0]addr_i
          );
  
logic n_valid, r_valid;
logic [31:0] n_dataout, r_dataout;

// valid          
always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_valid <= 0;
    end else begin
        r_valid <= n_valid;
    end
end          
//dataout
always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_dataout <= 0;
    end else begin
        r_dataout <= n_dataout;
    end
end    
always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_timestamp_i <= 0;
    end else begin
        r_timestamp_i <= n_timestamp_i;
    end
end    


logic [15:0]r_timestamp_i, n_timestamp_i;
always_comb n_timestamp_i = timestamp_i;
      
always_comb valid_o = r_valid;
always_comb dataout_o = r_dataout;


always_comb  n_valid = ( n_timestamp_i == 16'hFFFF&& r_timestamp_i== 16'hFFFE) ? 1 :( (enable_i == 1 ) ? 0 : r_valid); 


always_comb  n_dataout = 32'hFFFFFFFF ; 

endmodule

