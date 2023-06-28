`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2021 04:53:23 PM
// Design Name: 
// Module Name: config_control
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

// Resets the register low 
module config_control(
        input logic reset,
        input logic clk,
        input logic [31:0]toggle_line,
        output logic output_toggle
        
        );
        
    logic r_output_toggle;
    
always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_output_toggle <= 0;
    end else begin
        r_output_toggle <= toggle_line[0];
    end
   end  
   
 always_comb output_toggle = r_output_toggle;
   
endmodule

