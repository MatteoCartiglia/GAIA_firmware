`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2021 03:28:20 PM
// Design Name: 
// Module Name: AER_arb
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


module AER_arb #(
    parameter DATA_NUM_BITS = 32,
    parameter NUM_AER = 2

)(
    input logic clk,
    input logic reset, //Active-High Synchronous Reset    


    input logic[NUM_AER-1:0][DATA_NUM_BITS-1:0] data, // Unpacked
    input logic[NUM_AER-1:0]       valid, 
    // valid is the masked valid if it is the masked arbiter or the fifo_dis_valid if it is the unmasked valid

    output logic[NUM_AER-1:0]       enable,
    output logic[DATA_NUM_BITS-1:0]  arbitered_data,
    output logic                    arbitered_valid

);
    
    // It goes through all the inputs one by one and as soon as it finds one valid input:
    // - it outputs its data and the valid to the next module (dis_hss_valid and dis_hss_data of the top module)
    // - it sends back the enable to the previous camera (fifo_dis_enable) of the top module
    
    // Fixed priority: agent 0 has always priority over agent 1, because it comes first
    always_comb begin
        //arbitered_data = 'x; // don't care value. If none of the input is valid, the output data will be X
        arbitered_data = '1;

        //                arbitered_data[3:0]     = 4'b1111;  
        //arbitered_valid = 0; // Why do I need both of them?
        arbitered_valid = |valid;

        for(int aer_idx = 0; aer_idx < NUM_AER; aer_idx++) begin
            if (valid[aer_idx] == 1) begin

                arbitered_data = data[aer_idx];
               
                break; // As soon as I find one valid the for breaks 
            end
        end
    end

    generate 
        always_comb enable[0] = valid[0]; // if the the input valid is at one this will be the selected camera
        
        // genvar is a variable used in a generate for loop. It can 
        // be assigned values and changed during compilation time
        // must be declared in the module where is is used but it can be decalred
        // either inside or outdife the generate loop
        for (genvar requestor_idx = 1; requestor_idx < NUM_AER; requestor_idx++) begin
            always_comb enable[requestor_idx] = valid[requestor_idx] & ~(|valid[requestor_idx-1:0]);
            // it is enough that one of the previous valid was at one for the enable of the 
            // current one to be at zero. Only one of the input channels is enabled at a time
        end

    endgenerate



endmodule