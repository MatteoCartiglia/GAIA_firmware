`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2022 11:04:22 AM
// Design Name: 
// Module Name: trigger_AER
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


module trigger_AER(

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
  
logic n_trigger, r_trigger;  
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


// valid          
always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_trigger <= 0;
    end else begin
        r_trigger <= n_trigger;
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
  


always_comb n_trigger = req_i;
      
always_comb valid_o = r_valid;
always_comb dataout_o = r_dataout;


always_comb  n_valid = ( n_trigger == 1 && r_trigger== 1) ? 1 :( (enable_i == 1 ) ? 0 : r_valid); 


always_comb  n_dataout = 32'hFFFEFFFE ; 


endmodule
