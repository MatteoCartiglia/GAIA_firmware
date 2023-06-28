`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2021 11:11:09 AM
// Design Name: 
// Module Name: top
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

module top        
        #(parameter LED_ON = 0,
        parameter LED_OFF = 1'bz,
        parameter NUM_AER = 1,
        parameter AER_NUM_BITS = 16, 
        parameter TS_NUM_BITS = 16,
        parameter DATA_NUM_BITS = 32

        )(

    input  wire [4:0]   okUH,
	output wire [2:0]   okHU,
	inout wire  [31:0]  okUHU,
	inout  wire         okAA,
    output wire     [7:0]led,
    
    output wire         C0,
    output wire         C1,
    output wire         C2,
    output wire         control_imp,
    output wire         EN_TA,
    output wire         EN_TP,
    output wire         EN_ARRAY,
    output wire         PRst,
    output wire         SRst,
    
    input wire  req_up_tp,
    input wire  req_dn_tp,
    output wire ack_tp
    
);
    
    wire         okClk;
    wire [112:0] okHE;
    wire [64:0]  okEH;

    reg          reset;
    wire         c0_o;
    wire         c1_o;
    wire         c2_o;
    wire         control_imp_o;
    wire         EN_TA_o;
    wire         EN_TP_o;
    wire         EN_ARRAY_o;
    wire         PRst_o;
    wire         SRst_o;
        
    wire ep00wire; // reset
    wire ep01wire; //C0
    wire ep02wire; //c1
    wire ep03wire; //c2
    wire ep04wire; //control_imp
    wire ep05wire; // EN_TA
    wire ep06wire; //EN_TP
    wire ep07wire; //EN_ARRAY
    wire ep08wire; // PRst
    wire ep09wire; // SRst
    
    wire [15:0]timestamp;
    
 assign C0 = c0_o; 
 assign C1 = c1_o;
 assign C2 = c2_o;
 assign control_imp = control_imp_o;
 assign EN_TA = EN_TA_o;
 assign EN_TP = EN_TP_o;
 assign EN_ARRAY = EN_ARRAY_o;
 assign PRst = PRst_o;
 assign SRst = SRst_o;

 assign led[0] = (C0 == 0) ? LED_OFF : LED_ON;
 assign led[1] = (control_imp == 0) ? LED_OFF : LED_ON;
 assign led[2] = (EN_TP == 0) ? LED_OFF : LED_ON;
 assign led[3] = (EN_ARRAY == 0) ? LED_OFF : LED_ON;

 
  assign led[4] = (TEST_ACK == 0) ? LED_OFF : LED_ON;
  assign led[5] = (TEST_REQ == 0) ? LED_OFF : LED_ON;

 
 // FIFO pipes
 wire fifo_full;
 wire fifo_empty;
 wire [12:0]fifo_data_count;
 wire pipe_ep_read;
 wire pipe_ep_datain;
 wire pipe_out_ready;
 wire pipe_out_blockstrobe;
 
 wire TEST_REQ, TEST_ACK;

 
 assign pipe_out_ready = 1;
 
 
always @(posedge  okClk) begin
    reset <= ep00wire;
end





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


wire [NUM_AERwas-1:0] addr_i_packed [AER_NUM_BITS-1:0];
wire [NUM_AER-1:0] req_i;
wire [NUM_AER-1:0] ack_o;

wire [NUM_AER-1:0] DataOut_packed[DATA_NUM_BITS-1:0];
wire [NUM_AER-1:0]DataOut_valid;
wire [NUM_AER-1:0]DataOut_enable;

assign addr_i[0] = 16'b0000000000000000;
assign req_i[0] = TEST_REQ;
assign ack_o[0] = TEST_ACK;

assign addr_i[1] = 16'b0000000000000001;
assign req_i[1] = TEST_REQ_1;
assign ack_o[1] = TEST_ACK_1;


assign addr_i_flat

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
 // Config_control instances   
config_control i_config_control_w1(
    .reset(reset),
    .clk(okClk),
    .toggle_line(ep01wire),
    .output_toggle(c0_o)
);

config_control i_config_control_w2(
    .reset(reset),
    .clk(okClk),
    .toggle_line(ep02wire),
    .output_toggle(c1_o)
);

config_control i_config_control_w3(
    .reset(reset),
    .clk(okClk),
    .toggle_line(ep03wire),
    .output_toggle(c2_o)
);

config_control i_config_control_w4(
    .reset(reset),
    .clk(okClk),
    .toggle_line(ep04wire),
    .output_toggle(control_imp_o)
);
config_control i_config_control_w5(
    .reset(reset),
    .clk(okClk),
    .toggle_line(ep05wire),
    .output_toggle(EN_TA_o)
);

config_control i_config_control_w6(
    .reset(reset),
    .clk(okClk),
    .toggle_line(ep06wire),
    .output_toggle(EN_TP_o)
);
config_control i_config_control_w7(
    .reset(reset),
    .clk(okClk),
    .toggle_line(ep07wire),
    .output_toggle(EN_ARRAY_o)
);

config_control i_config_control_w8(
    .reset(reset),
    .clk(okClk),
    .toggle_line(ep08wire),
    .output_toggle(PRst_o)
);

config_control i_config_control_w9(
    .reset(reset),
    .clk(okClk),
    .toggle_line(ep09wire),
    .output_toggle(SRst_o)
);

c_counter_binary_0 counter(

    .CLK(okClk),
    .SCLR(reset),
    .Q(timestamp)
);

// Opal Kelly- Instantiate the okHost and connect endpoints.
wire [65*10-1:0]  okEHx;
okHost okHI(
	.okUH(okUH),
	.okHU(okHU),
	.okUHU(okUHU),
	.okAA(okAA),
	.okClk(okClk),
	.okHE(okHE), 
	.okEH(okEH)
);

okWireOR # (.N(10)) wireOR (okEH, okEHx);

// Input wires for dig control
okWireIn     wi00(.okHE(okHE),                             .ep_addr(8'h00), .ep_dataout(ep00wire)); 
okWireIn     wi01(.okHE(okHE),                             .ep_addr(8'h01), .ep_dataout(ep01wire));
okWireIn     wi02(.okHE(okHE),                             .ep_addr(8'h02), .ep_dataout(ep02wire));
okWireIn     wi03(.okHE(okHE),                             .ep_addr(8'h03), .ep_dataout(ep03wire));
okWireIn     wi04(.okHE(okHE),                             .ep_addr(8'h04), .ep_dataout(ep04wire));
okWireIn     wi05(.okHE(okHE),                             .ep_addr(8'h05), .ep_dataout(ep05wire));
okWireIn     wi06(.okHE(okHE),                             .ep_addr(8'h06), .ep_dataout(ep06wire));
okWireIn     wi07(.okHE(okHE),                             .ep_addr(8'h07), .ep_dataout(ep07wire));
//okWireIn     wi08(.okHE(okHE),                             .ep_addr(8'h08), .ep_dataout(ep08wire));
//okWireIn     wi09(.okHE(okHE),                             .ep_addr(8'h09), .ep_dataout(ep09wire));


okWireOut    wo20(.okHE(okHE), .okEH(okEHx[ 0*65 +: 65 ]), .ep_addr(8'h20), .ep_datain(c0_o));
okWireOut    wo21(.okHE(okHE), .okEH(okEHx[ 1*65 +: 65 ]), .ep_addr(8'h21), .ep_datain(c1_o));
okWireOut    wo22(.okHE(okHE), .okEH(okEHx[ 2*65 +: 65 ]), .ep_addr(8'h22), .ep_datain(c2_o));
okWireOut    wo23(.okHE(okHE), .okEH(okEHx[ 3*65 +: 65 ]), .ep_addr(8'h23), .ep_datain(control_imp_o));
okWireOut    wo24(.okHE(okHE), .okEH(okEHx[ 4*65 +: 65 ]), .ep_addr(8'h24), .ep_datain(EN_TA_o));
okWireOut    wo25(.okHE(okHE), .okEH(okEHx[ 5*65 +: 65 ]), .ep_addr(8'h25), .ep_datain(EN_TP_o));
okWireOut    wo26(.okHE(okHE), .okEH(okEHx[ 6*65 +: 65 ]), .ep_addr(8'h26), .ep_datain(EN_ARRAY_o));
//okWireOut    wo27(.okHE(okHE), .okEH(okEHx[ 7*65 +: 65 ]), .ep_addr(8'h27), .ep_datain(PRst_o));
//okWireOut    wo28(.okHE(okHE), .okEH(okEHx[ 8*65 +: 65 ]), .ep_addr(8'h28), .ep_datain(SRst_o));
okWireOut    wo28(.okHE(okHE), .okEH(okEHx[ 8*65 +: 65 ]), .ep_addr(8'h28), .ep_datain(dis_fifo_data));


//DAC Communication
//okTriggerIn trigIn53 (.okHE(okHE),.ep_addr(8'h53), .ep_clk(clk2), .ep_trigger(ep53trig));
//okWireIn     wi15(.okHE(okHE),                             .ep_addr(8'h15), .ep_dataout(ep15wire));

// Fifo out
//okBTPipeOut pipeOutA3 (.okHE(okHE), .okEH(okEH),.ep_addr(8'ha3), .ep_datain(pipe_ep_datain), .ep_read(pipe_ep_read),.ep_blockstrobe(pipe_out_blockstrobe), .ep_ready(pipe_out_ready));
//okWireOut    wo29(.okHE(okHE), .okEH(okEHx[ 9*65 +: 65 ]), .ep_addr(8'h29), .ep_datain({fifo_full, fifo_empty, fifo_data_count})); // 1+1+13
okWireIn     wi08(.okHE(okHE),                             .ep_addr(8'h08), .ep_dataout(TEST_REQ_1));
okWireOut    wo27(.okHE(okHE), .okEH(okEHx[ 9*65 +: 65 ]), .ep_addr(8'h27), .ep_datain(TEST_ACK_1)); // 1+1+13

okWireIn     wi09(.okHE(okHE),                             .ep_addr(8'h09), .ep_dataout(TEST_REQ));
okWireOut    wo29(.okHE(okHE), .okEH(okEHx[ 9*65 +: 65 ]), .ep_addr(8'h29), .ep_datain(TEST_ACK)); // 1+1+13


endmodule
