`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2021 02:25:38 PM
// Design Name: 
// Module Name: AER_sv_wrap
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


module AER_sv_wrap(

    );
endmodule




wire ack_dn_tp, ack_up_tp, TEST_REQ_1, TEST_ACK_1;

/*
 
[0]addr_i = 16'b0000000000000000;
[0]req_i = req<0>;
[0]ack_o = ack<0>;

[1]addr_i = 16'b0000000000000001;
[1]req_i = req<1>;
[1]ack_o = ack<1>;

[2]addr_i = 16'b0000000000000010;
[2]req_i = req<2>;
[2]ack_o = ack<2>;

[2]addr_i = 16'b0000000000000011;
[2]req_i = req<2>;
[2]ack_o = ack<2>;

[9]addr_i = 16'b1111111100001111;
[9]req_i = req_dn_tp;
[9]ack_o = ack_dn_tp;

[10]addr_i = 16'b1111000011111111;
[10]req_i = req_up_tp;
[10]ack_o = ack_up_tp;

ack_tp = ack_dn_tp | ack_up_tp;

[11]addr_i = {Addr<0>,Addr<1>, [12], 0 ,0 ,0}
addr_i[11][0]
addr_i[11][1]

*/
wire [NUM_AER-1:0] power_EN_i;


wire [NUM_AER-1:0][AER_NUM_BITS-1:0] addr_i;
wire [NUM_AER-1:0] req_i;
wire [NUM_AER-1:0] ack_o;

wire [NUM_AER-1:0][DATA_NUM_BITS-1:0] DataOut;
wire [NUM_AER-1:0]DataOut_valid;
wire [NUM_AER-1:0]DataOut_enable;

assign addr_i[0] = 16'b0000000000000000;
assign req_i[0] = TEST_REQ;
assign ack_o[0] = TEST_ACK;

assign addr_i[1] = 16'b0000000000000001;
assign req_i[1] = TEST_REQ_1;
assign ack_o[1] = TEST_ACK_1;

AER_generator #(
    .NUM_AER (NUM_AER),
    .DATA_NUM_BITS(DATA_NUM_BITS),
    .AER_NUM_BITS(AER_NUM_BITS)

    )i_AER_generator(
     .clk(okClk),
    .reset(reset),
    .req_i(req_i),
    .ack_o(ack_o),
    .addr_i(addr_i),
    .timestamp_i(timestamp),
    .dataout_o (DataOut),
    .valid_o(DataOut_valid),
    .enable_i(DataOut_enable)

);
wire dis_fifo_valid, dis_fifo_enable;
wire [DATA_NUM_BITS-1:0] dis_fifo_data;

AER_dis#(
    .NUM_AER(NUM_AER),
    .DATA_NUM_BITS(DATA_NUM_BITS)
) i_aer_dis(
    .clk(okClk),
    .reset(reset),

    .aer_dis_valid(DataOut_valid),
    .aer_dis_data(DataOut),
    .aer_dis_enable(DataOut_enable),

    .dis_fifo_valid(dis_fifo_valid),
    .dis_fifo_enable(dis_fifo_enable),
    .dis_fifo_data(dis_fifo_data)
);


    
//FIFO initialization 
/*
fifo_generator_0 fifo_32_8192(
    .clk(okClk),
    .srst(reset),
    .din(DataOut),
    .wr_en(DataOut_valid),
    .rd_en(pipe_ep_read),
    .dout(pipe_ep_datain),
    .full(fifo_full),
    .empty(fifo_empty),
    .data_count(fifo_data_count)
);
*/