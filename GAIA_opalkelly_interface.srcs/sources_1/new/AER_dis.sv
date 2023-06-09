// Module given by Nicoletta risi and Alessandro Aimar

module AER_dis#(
    parameter DATA_NUM_BITS = 32,
    parameter NUM_AER = 3
)(
    input logic clk,
    input logic reset, //Active-High Synchronous Reset    
    
    // NOTE: in this case I have as many input valid and output enable
    // as many input DVS
    input logic[NUM_AER-1:0]                    aer_dis_valid,
    input logic[NUM_AER-1:0][DATA_NUM_BITS-1:0] aer_dis_data,
    output logic[NUM_AER-1:0]                   aer_dis_enable,

    output logic                    dis_fifo_valid,
    output logic[DATA_NUM_BITS-1:0]  dis_fifo_data,
    input logic                     dis_fifo_enable
);


    logic[NUM_AER-1-1:0] r_round_robin_mask, n_round_robin_mask;
    // register for the round robin mask. NOTE: 1 less bit then the number of DVS!!!!! 
    // See below why
    
    logic[DATA_NUM_BITS-1:0]  n_arbitered_data, r_arbitered_data;
    logic                     n_arbitered_valid, r_arbitered_valid, arbitered_unmasked_valid, arbitered_masked_valid; 
    logic[NUM_AER-1:0] unmasked_enable, masked_enable, masked_valid, gated_valid;    // gated_valid = unmasked_valid
    logic[DATA_NUM_BITS-1:0]  arbitered_unmasked_data, arbitered_masked_data;
    logic reset_mask;
    logic enable_or_not_valid;

    always_comb dis_fifo_valid = r_arbitered_valid; // the output of this module is valid if at least one of the two arbiters has an output valid
    always_comb dis_fifo_data = r_arbitered_data; //old tested line. commented for debug purposes
 
 //   logic [31:0]r_counter_dis, n_counter_dis;
   
  //  always_ff @(posedge  clk) begin
  //      if (reset ==1) begin
 //           r_counter_dis <= 0;
 //       end else begin
 //           r_counter_dis <= n_counter_dis;
 //           end
 //   end 
    
  //  always_comb n_counter_dis = ( (|aer_dis_valid) & enable_or_not_valid) ? r_counter_dis+1 : r_counter_dis;
  // everytime an event gets generated  and fifo is ready to get a new event

   // always_comb dis_fifo_data = r_counter_dis;



    always_comb gated_valid = enable_or_not_valid ? aer_dis_valid : 0; // and the input valid to the arbiters depend on the input enable coming from the next module
    // gated valid is set to the actual input valid only if the next module in the pipeline
    // has asserted the enable. Otherwise, i.e gated valid = 0: 
    // - the unmasked abiter valid is zero (gated valid is the input valid of the unmasked arbiter): the unmasked arbiter is inactive
    // - the masked valid is set to 0 (i.e. the valid of the masked arbiter): the masked arbiter is inactive
    

    always_comb n_arbitered_valid = arbitered_unmasked_valid | arbitered_masked_valid;
    // the output valid will be one as long as one of the arbier is valid. 

    always_comb begin
        masked_valid = gated_valid & {1'b1, r_round_robin_mask}; // the masked valid depends on the round robin masks that shifts at every clock cycles
        // Add one bit in the end to avoid that the camera 0 has two conditions in which it
        // is always the selected one (for 11111 or 00000). This way, both cameras have 50% of
        // probability of being selected
        
        // If gated_valid = 1, i.e. if dis_aer_enable=1 (if the next module has asserted the enable). 
        // the masked_valid is equal to the aer_dis_valid
        
        // This implements the round robin priority   
        if (|masked_valid == 1) begin 
            // If there is at least one valid input among the masked input, 
            // the selected data will be those of the masked arbiter
            // Same for the enable
            n_arbitered_data = arbitered_masked_data; // output data of the masked arbiter
            aer_dis_enable = masked_enable; // output enable of the masked arbiter
        end else begin
            // else one valid input could be in the unmasked ones, 
            // so the output data will be the one generated by the unmasked arbiter/
            // Same for the enable
            n_arbitered_data = arbitered_unmasked_data; // output data of the unmasked arbiter
            aer_dis_enable = unmasked_enable; // output enable of the unmasked arbiter
        end
    end


    always_comb begin
        // The most significant requestor is always 1
        reset_mask = ~|r_round_robin_mask;
        // at the last shift (if gated_valid=1):
        // masked_valid = 1 | 0 0 0 .... : as many zeros as NUM_AER-1 (i.e. the r_round_robin_mask) + 1 (the added bit)
        // -> reset_mask =  not(bitwise_or(r_round_robin_mask)) = 1 -> n_round_robin_mask = 1 (see next line) 
        // This avoids the case masked_valid = 0 0 0 0 ...
        // Because 1 1 1 1 and 0 0 0 0 would both give priority to the input 0 (which will be selected if its valid is 1), 
        // in one case via the unmasked arbiter and in another case via the masked arbiter. 
        // To give both camera the same probability of being selected we use this trick of adding one bit to the r_round_robin_mask
        
        n_round_robin_mask = ((r_round_robin_mask << 1) | {(NUM_AER-1){reset_mask}}); // replicate operator:
        // repeat the reset_mask value (1 bit) as many times as the number of DAVIS
        // the mask will be either the mask shifted by one or the replicated reset_mask. i.e. if 
        // I have to reset the mask (i.e. no input is masked, so all bits are set to one), the next_round_robin_mask
        // will be the or between the shifted mask and the string of all ones -> all ones.
    end
   // always_comb enable_or_not_valid = dis_fifo_enable == 1; // take the input data only if the next module is ready to take my current stoered data or if the register is empty

    always_comb enable_or_not_valid = dis_fifo_enable == 1 || r_arbitered_valid == 0; // take the input data only if the next module is ready to take my current stoered data or if the register is empty
//    always_comb enable_or_not_valid = dis_fifo_enable == 1 && r_arbitered_valid == 0; // take the input data only if the next module is ready to take my current stoered data AND if the register is empty

    always_ff@(posedge clk) begin
        if (reset == 1) begin
            r_arbitered_valid  <= '0; // deassert the output valid
            r_round_robin_mask <= '1; // no bit is masked
        end else begin
            if (enable_or_not_valid) begin
                r_arbitered_valid  <= n_arbitered_valid;
                r_arbitered_data  <= n_arbitered_data;

                if (|n_arbitered_valid) begin // if there is at least one valid input
                    r_round_robin_mask <= n_round_robin_mask; // shift the mask 
                    // else, the r_round_robin_mask will not change so the n_round_robin_mask at the next posedge will be the same
                end
            end
        end
    end

    // unmasked arbiter    
    AER_arb#(
        .NUM_AER(NUM_AER),
        .DATA_NUM_BITS(DATA_NUM_BITS)
    ) i_unmasked_arbiter(
        .clk(clk),
        .reset(reset),

        .data(aer_dis_data),

        .valid(gated_valid),
        .enable(unmasked_enable),

        .arbitered_data(arbitered_unmasked_data),
        .arbitered_valid(arbitered_unmasked_valid)
    );

    
    // masked arbiter
    AER_arb#(
        .NUM_AER(NUM_AER),
        .DATA_NUM_BITS(DATA_NUM_BITS)
    ) i_masked_arbiter(
        .clk(clk),
        .reset(reset),

        .data(aer_dis_data),

        .valid(masked_valid),
        .enable(masked_enable),

        .arbitered_data(arbitered_masked_data),
        .arbitered_valid(arbitered_masked_valid)
    );

endmodule

