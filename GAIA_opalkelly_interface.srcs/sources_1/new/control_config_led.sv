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

// sets an LED 
 

module config_control_led
        (input logic reset,
        input logic clk,
        input logic toggle_line,
        output logic output_toggle
        );
        
    logic n_output_toggle;
    logic r_output_toggle;

    
always_ff @(posedge  clk) begin
    if (reset ==1) begin
        r_output_toggle <= LED_OFF;
    end else begin
        r_output_toggle <= toggle_line;
    end
   end  
   
 // Question: Why does it work with assign and not with always_comb?
   
always_comb output_toggle = r_output_toggle;

endmodule

