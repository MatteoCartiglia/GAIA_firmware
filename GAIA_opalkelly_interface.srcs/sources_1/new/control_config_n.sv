`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2021 11:18:36 AM
// Design Name: 
// Module Name: control_config_n
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


// Resets the register high 
module config_control_n(
        input logic reset,
        input logic clk,
        input logic [31:0]toggle_line,
        output logic r_output_toggle
        
        );
    
always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_output_toggle <= 1;
    end else begin
        r_output_toggle <= toggle_line[0];
    end
   end
    
   
endmodule
