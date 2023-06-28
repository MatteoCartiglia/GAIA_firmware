`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2021 03:46:58 PM
// Design Name: 
// Module Name: top_sv
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
module top_sv    
       #(parameter LED_ON = 0,
        parameter LED_OFF = 1'bz,
        parameter NUM_AER = 13, // 9+2 +1 + 1 ts + trigger
        parameter AER_NUM_BITS = 16, 
        parameter TS_NUM_BITS = 16,
        parameter DATA_NUM_BITS = 32,
        parameter WRITE_LEN = 24,
        parameter DAC_DELAY = 100,
        parameter DELAY_REQ = 10,
        parameter CLK_PERIOD = 10,//ns
        parameter CONV_TIME_UNIT_US = 10000, //from ns to 10us in ts ///// was1000
        parameter ADC_WRITE_LEN = 16,
        parameter ADC_DELAY = 5,
        parameter ACK_TIMEOUT = 2000000000

        )(

// okClk is 10 ns
    input  logic [4:0]   okUH,
	output logic [2:0]   okHU,
	inout logic  [31:0]  okUHU,
	inout  logic         okAA,
    output logic     [7:0]led,
    
    output logic         C0,
    output logic         C1,
    output logic         C2,
    output logic         control_imp,
    output logic         EN_TA,
    output logic         EN_TP,
    output logic         EN_ARRAY,
    output logic         PRst,
    output logic         SRst,
    
    output logic DAC_sync, DAC_clk , DAC_reset, DAC_din,
    
    input logic  req_up_tp,req_dn_tp,
    output logic ack_tp,
    
    input logic REQ,
    output logic ACK,
    input logic Add_0, Add_1,Add_2,Add_3,Add_4, Add_5, Add_6,Add_7,Add_8,Add_9, Add_10, Add_11,Add_12,

    input logic  req_0,req_1,req_2,req_3,req_4,req_5,req_6,req_7,req_8,
    output logic ack_0,ack_1,ack_2,ack_3,ack_4,ack_5,ack_6,ack_7,ack_8,
   
    output logic ADC_SERIAL_DATA_IN, ADC_SPI_CLK, ADC_chip_select_n,
    input logic ADC_SERIAL_DATA_OUT,    
    input logic  Trigger

);
 /* 
 assign ADC_chip_select_n =  triggers[2]; 
 assign ADC_SPI_CLK =  triggers[1]; 
  assign  ADC_SERIAL_DATA_IN =triggers[3];


 assign ADC_SPI_CLK =  DAC_IN_trig; 
 assign ADC_SERIAL_DATA_IN =  ep08wire; 
 assign ADC_SERIAL_DATA_OUT =  ep09wire; 
*/
logic         okClk;
logic [112:0] okHE;
logic [64:0]  okEH;

logic         reset;
logic         c0_o;
logic         c1_o;
logic         c2_o;
logic         control_imp_o;
logic         EN_TA_o;
logic         EN_TP_o;
logic         EN_ARRAY_o;
logic         PRst_o;
logic         SRst_o;
    
logic ep00wire; // reset
logic ep01wire; //C0
logic ep02wire; //c1
logic ep03wire; //c2
logic ep04wire; //control_imp
logic ep05wire; // EN_TA
logic ep06wire; //EN_TP
logic ep07wire; //EN_ARRAY
logic ep08wire; // PRst
logic ep09wire; // SRst

logic [15:0]timestamp;

assign C0 = c0_o; 
assign C1 = c1_o;
assign C2 = c2_o;
assign control_imp = control_imp_o;
assign EN_TA = EN_TA_o;
assign EN_TP = EN_TP_o;
assign EN_ARRAY = EN_ARRAY_o;
assign PRst = PRst_o;
assign SRst = SRst_o;

logic [NUM_AER-1:0]led_drf;
assign led[7] = (REQ == 0) ? LED_OFF : LED_ON;
assign led[6] = (req_up_tp == 0) ? LED_OFF : LED_ON;
assign led[5] = (ack_tp == 0) ? LED_OFF : LED_ON;

assign led[4] = (ack_proxy  == 0) ? LED_OFF : LED_ON;
assign led[3] = (ack_flag == 0) ? LED_OFF : LED_ON;
assign led[2] = (ACK == 0) ? LED_OFF : LED_ON;

assign led[1] = (fifo_adc_full == 0) ? LED_OFF : LED_ON;
assign led[0] = (fifo_full == 0) ? LED_OFF : LED_ON;

logic [31:0]triggers;


logic [WRITE_LEN-1:0]DAC_input_values;
logic DAC_sync_r;
logic DAC_clk_r;
logic DAC_din_r;

assign DAC_sync = DAC_sync_r; 
assign DAC_clk = DAC_clk_r; 
assign DAC_din = DAC_din_r; 


always_comb DAC_reset = ~reset;
 
 DAC_SPI_handler 
 #( .WRITE_LEN (WRITE_LEN),
   .HOLD_DELAY (DAC_DELAY)
     )DAC_SPI_handler(
       .reset(reset),
       .clk(okClk),
// PC to OK
       .DAC_ValidIn_i(triggers[1]),
        .DAC_update_values_i(DAC_input_values),
// OK to DAC - SPI
       .DAC_SYNC_o(DAC_sync_r),
        .DAC_clk_o(DAC_clk_r),
        .DAC_in_o(DAC_din_r)

          ); 

 
logic TEST_REQ, TEST_ACK;
logic TEST_REQ_1, TEST_ACK_1;

 always_ff @(posedge  okClk) begin
    pipe_out_ready <= 1; 
end 
 
always_ff @(posedge  okClk) begin
    reset <= ep00wire;
end

//always_comb ack_tp = 0;

always_comb ack_tp = ack_tp_up | ack_tp_dn;
always_comb ACK = ack_proxy | ack_flag;


logic ack_proxy;

logic ack_flag;

 ack_reset_handler #(
     .timeout_len(ACK_TIMEOUT) //10ns 
       )ack_reset_handler(
       .reset(reset),
        .clk(okClk),
         .trigger(triggers[3]),
          .r_trig_flag(ack_flag)        
    );



logic ack_tp_up, ack_tp_dn;
logic [NUM_AER-1:0] power_EN_i; // not used

logic [NUM_AER-1:0][AER_NUM_BITS-1:0] addr_i ;
logic [NUM_AER-1:0] req_i;
logic [NUM_AER-1:0] ack_o;

logic [NUM_AER-1:0] [DATA_NUM_BITS-1:0] DataOut;
logic [NUM_AER-1:0]DataOut_valid;
logic [NUM_AER-1:0]DataOut_enable;

// test pixel AER
assign addr_i[0] = 16'hC000;
assign req_i[0] = req_dn_tp;
assign ack_tp_up = ack_o[0];

assign addr_i[1] = 16'hC001;
assign req_i[1] = req_up_tp;
assign ack_tp_dn = ack_o[1];

//ARRAY AER
assign addr_i[2]={3'b0,Add_0, Add_1,Add_2,Add_3,Add_4, Add_5, Add_6,Add_7,Add_8,Add_9, Add_10, Add_11,Add_12};
assign req_i[2] = REQ;
assign ack_proxy = ack_o[2];

//Test array
assign addr_i[3] = 16'hC002 ;
assign req_i[3] = req_0;
assign ack_0 = ack_o[3];

assign addr_i[4] = 6'hC003;
assign req_i[4] = req_1;
assign ack_1 = ack_o[4];

assign addr_i[5] = 16'hC004;
assign req_i[5] = req_2;
assign ack_2 = ack_o[5];

assign addr_i[6] = 16'hC005;
assign req_i[6] = req_3;
assign ack_3 = ack_o[6];

assign addr_i[7] = 16'hC006;
assign req_i[7] = req_4;
assign ack_4 = ack_o[7];

assign addr_i[8] = 16'hC007;
assign req_i[8] = req_5;
assign ack_5 = ack_o[8];

assign addr_i[9] = 16'hC008;
assign req_i[9] = req_6;
assign ack_6 = ack_o[9];

assign addr_i[10] = 16'hC009;
assign req_i[10] = req_7;
assign ack_7 = ack_o[10];

assign addr_i[11] = 16'hC00A;
assign req_i[11] = req_8;
assign ack_8 = ack_o[11];

//Dummy AER used for TS OVERFLOW
logic dummy1, dummy2;
assign addr_i[12] = 16'hFFFF;
assign req_i[12] = dummy1;
assign dummy2 = ack_o[12];

// Dummy AER for external trigger 
//logic dummy3;
//assign addr_i[13] = 16'hFFFE;
//assign req_i[13] = Trigger;
//assign dummy3 = ack_o[13];

AER_generator #(
    .NUM_AER (NUM_AER),
    .DATA_NUM_BITS(DATA_NUM_BITS),
    .AER_NUM_BITS(AER_NUM_BITS),
    .DELAY_REQ(DELAY_REQ)

    )i_AER_generator(
     .clk(okClk),
    .reset(reset),
    .req_i(req_i),
    .ack_o(ack_o),
    .addr_i(addr_i),
    .timestamp_i(timestamp),
    .dataout_o (DataOut),
    .valid_o(DataOut_valid),
    .enable_i(DataOut_enable),
    .led_status(led_drf)
);

logic dis_fifo_valid, dis_fifo_enable;
logic [DATA_NUM_BITS-1:0] dis_fifo_data;

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
    .dis_fifo_enable(fifo_full_n),
    .dis_fifo_data(dis_fifo_data)
);


logic fifo_full_n;
always_comb fifo_full_n = ~fifo_full;

// FIFO pipes
logic fifo_full;
logic fifo_empty;
logic [31:0]fifo_data_count;
logic pipe_read;
logic [DATA_NUM_BITS-1:0]pipe_datain;
logic pipe_out_ready;
logic pipe_out_blockstrobe;
logic pipe_out_blockstrobe;

logic prog_full, prog_full_n;
logic prog_empty;
always_comb prog_full_n = ~prog_full;
// prog full should not 

logic gated_valid;
always_comb gated_valid = dis_fifo_valid & prog_full_n;

//FIFO initialization 

fifo_generator_1 fifo_32_132768(
    .clk(okClk),
    .srst(triggers[3]),
    .din(dis_fifo_data),
    .wr_en(dis_fifo_valid),
    .rd_en(pipe_read),
    .dout(pipe_datain),
    .full(fifo_full),
    .empty(fifo_empty),
    .data_count(fifo_data_count),
    .prog_full(prog_full),
    .prog_empty(prog_empty)
);


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

// ADC modules
logic [15:0] adcinit_adc_word_i;
logic [DATA_NUM_BITS-1:0] ADC_word_o;
logic [DATA_NUM_BITS-1:0] pipe_datain_adc;    
logic adc_fifo_valid;    
logic pipe_read_adc,fifo_adc_full,fifo_adc_empty;
logic [15:0]fifo_adc_data_count;
logic pipe_out_blockstrobe_adc;
logic [31:0]ADC_update_values_word3_i;

logic n_trig , r_trig;
always_comb n_trig = triggers[2];


always_ff @(posedge  okClk) begin
    if ( reset) begin
        r_trig <= 0;
    end else begin
     r_trig <= n_trig;
    end
end 

always_comb n_trig_adc_flag = (n_trig ==1 && r_trig==0) ? 1 : (ack_trig) ? 0 : r_trig_adc_flag;
 
logic n_trig_adc_flag, r_trig_adc_flag;
always_ff @(posedge  okClk) begin
    if ( reset) begin
        r_trig_adc_flag <= 0;
    end else begin
     r_trig_adc_flag <= n_trig_adc_flag;
    end
end 
logic ack_trig;
logic EN_ADC;

ADC_init 
#( 
)ADC_init(
       .reset(reset),
       .clk(clk_adc),
 
     .adc_cs_n_i (ADC_chip_select_n),
    .ADC_update_values_word3_i(ADC_update_values_word3_i),
    .trig_in(r_trig_adc_flag),
    .adc_word_o(adcinit_adc_word_i),
    .ack_trig(ack_trig)
       
);
logic [31:0]adc_clock_sampling_cycles;




 ADC_reader 
 #( .ADC_word_len (ADC_WRITE_LEN),
    .ADC_DELAY(ADC_DELAY)
     )ADC_reader(
       .reset(reset),
       .EN_ADC(EN_ADC),
         .clk(clk_adc),
        .adc_clock_sampling_cycles(adc_clock_sampling_cycles),
       .adc_cs_n_o(ADC_chip_select_n),
        .adc_din_o(ADC_SERIAL_DATA_IN),
        .adc_clk_o(ADC_SPI_CLK),
        .adc_dout_i(ADC_SERIAL_DATA_OUT),
       .ADC_update_values_i(adcinit_adc_word_i),
        .timestamp_i(timestamp),
        .ADC_word_o(ADC_word_o),
        .valid_out(adc_fifo_valid)
          );
//TODO: adc, ts dis to FIFO

logic prog_full_adc, prog_full_adc_n;
always_comb prog_full_adc_n = ~prog_full_adc; 

fifo_generator_0 fifo_32_32768_adc( // similar to aer fifo, except writing/reading different clocks!
    .wr_clk(clk_adc),
    .rd_clk(okClk),
    .rst(triggers[3]), //CHANGEE!!!!!
    .din(ADC_word_o),
    .wr_en(adc_fifo_valid),
    .rd_en(pipe_read_adc),
    .dout(pipe_datain_adc),
    .full(fifo_adc_full),
    .empty(fifo_adc_empty),
    .wr_data_count(fifo_adc_data_count),
    .wr_rst_busy(),
    .rd_rst_busy(),
    .prog_empty(),
    .prog_full(prog_full_adc)
);



logic clk_adc;
clk_wiz_1 clk_wiz_adc(
.clk_in1(okClk),
.clk_out1(clk_adc)
);


// TIMESTAMP IN US

//Pass to ts of 32 bits + 10us resolution. CHange ts res, fifos dimension, ts generation

always_comb timestamp = r_time_us;


localparam NUM_CYCLES_PER_TUNIT = CONV_TIME_UNIT_US / CLK_PERIOD;
localparam MAX_TIME_STAMP = 2**(TS_NUM_BITS)-1;
logic [TS_NUM_BITS-1:0] n_counter_ns, r_counter_ns, n_time_us, r_time_us;
logic advance_time;

always_comb advance_time = r_counter_ns == NUM_CYCLES_PER_TUNIT-1;
always_comb n_time_us = advance_time ? r_time_us+1 : r_time_us;
always_comb n_counter_ns = advance_time ? 0 : r_counter_ns +1;

always_ff @(posedge okClk) begin

    if (reset) begin
        r_counter_ns <= 0;
        r_counter_ns[0] <= 0;
     end else begin
        r_counter_ns <= n_counter_ns;
      end
     end
     
 always_ff @(posedge okClk) begin

    if (reset) begin
        r_time_us <= 0;
     end else begin
        r_time_us <= n_time_us;
     end
  end
        
         
/*

//OLD implementation of ts
logic [22:0]timestamp_tmp;
always_comb timestamp = timestamp_tmp[22:7]; // ts 1.27us 

c_counter_binary_0 counter(

    .CLK(okClk),
    .SCLR(reset),
    .Q(timestamp_tmp)
);
*/

// Opal Kelly- Instantiate the okHost and connect endpoints.
logic [65*20-1:0]  okEHx;
okHost okHI(
	.okUH(okUH),
	.okHU(okHU),
	.okUHU(okUHU),
	.okAA(okAA),
	.okClk(okClk),
	.okHE(okHE), 
	.okEH(okEH)
);

okWireOR # (.N(30)) wireOR (okEH, okEHx);

// Input wires for dig control
okWireIn     wi00(.okHE(okHE),                             .ep_addr(8'h00), .ep_dataout(ep00wire)); 
okWireIn     wi01(.okHE(okHE),                             .ep_addr(8'h01), .ep_dataout(ep01wire));
okWireIn     wi02(.okHE(okHE),                             .ep_addr(8'h02), .ep_dataout(ep02wire));
okWireIn     wi03(.okHE(okHE),                             .ep_addr(8'h03), .ep_dataout(ep03wire));
okWireIn     wi04(.okHE(okHE),                             .ep_addr(8'h04), .ep_dataout(ep04wire));
okWireIn     wi05(.okHE(okHE),                             .ep_addr(8'h05), .ep_dataout(ep05wire));
okWireIn     wi06(.okHE(okHE),                             .ep_addr(8'h06), .ep_dataout(ep06wire));
okWireIn     wi07(.okHE(okHE),                             .ep_addr(8'h07), .ep_dataout(ep07wire));
okWireIn     wi08(.okHE(okHE),                             .ep_addr(8'h08), .ep_dataout(ep08wire));
okWireIn     wi09(.okHE(okHE),                             .ep_addr(8'h09), .ep_dataout(ep09wire));

okWireOut    wo20(.okHE(okHE), .okEH(okEHx[ 0*65 +: 65 ]), .ep_addr(8'h20), .ep_datain(c0_o));
okWireOut    wo21(.okHE(okHE), .okEH(okEHx[ 1*65 +: 65 ]), .ep_addr(8'h21), .ep_datain(c1_o));
okWireOut    wo22(.okHE(okHE), .okEH(okEHx[ 2*65 +: 65 ]), .ep_addr(8'h22), .ep_datain(c2_o));
okWireOut    wo23(.okHE(okHE), .okEH(okEHx[ 3*65 +: 65 ]), .ep_addr(8'h23), .ep_datain(control_imp_o));
okWireOut    wo24(.okHE(okHE), .okEH(okEHx[ 4*65 +: 65 ]), .ep_addr(8'h24), .ep_datain(EN_TA_o));
okWireOut    wo25(.okHE(okHE), .okEH(okEHx[ 5*65 +: 65 ]), .ep_addr(8'h25), .ep_datain(EN_TP_o));
okWireOut    wo26(.okHE(okHE), .okEH(okEHx[ 6*65 +: 65 ]), .ep_addr(8'h26), .ep_datain(EN_ARRAY_o));
okWireOut    wo27(.okHE(okHE), .okEH(okEHx[ 7*65 +: 65 ]), .ep_addr(8'h27), .ep_datain(PRst_o));
okWireOut    wo28(.okHE(okHE), .okEH(okEHx[ 8*65 +: 65 ]), .ep_addr(8'h28), .ep_datain(SRst_o));

okTriggerIn trigIn40(.okHE(okHE),.ep_addr(8'h40), .ep_clk(okClk), .ep_trigger(triggers));

//DAC Communication
okWireIn     wi0C(.okHE(okHE),                             .ep_addr(8'h0C), .ep_dataout(DAC_input_values));

// AER Fifo out
okWireOut    wo2A(.okHE(okHE), .okEH(okEHx[ 10*65 +: 65 ]), .ep_addr(8'h2A), .ep_datain({ fifo_empty})); // 1+1+13
okWireOut    wo2B(.okHE(okHE), .okEH(okEHx[ 11*65 +: 65 ]), .ep_addr(8'h2B), .ep_datain({ fifo_full})); // 1+1+13
okWireOut    wo2C(.okHE(okHE), .okEH(okEHx[ 12*65 +: 65 ]), .ep_addr(8'h2C), .ep_datain({fifo_data_count})); // 1+1+13

okBTPipeOut pipeOutA3 (.okHE(okHE), .okEH(okEHx[ 14*65 +: 65 ]),.ep_addr(8'ha3), .ep_datain(pipe_datain), .ep_read(pipe_read),.ep_blockstrobe(pipe_out_blockstrobe), .ep_ready(1));


//ADC_FIFO out
okBTPipeOut pipeOutA4 (.okHE(okHE), .okEH(okEHx[ 15*65 +: 65 ]),.ep_addr(8'ha4), .ep_datain(pipe_datain_adc), .ep_read(pipe_read_adc),.ep_blockstrobe(pipe_out_blockstrobe_adc), .ep_ready(1));
okWireIn     wi0D(.okHE(okHE),                             .ep_addr(8'h0D), .ep_dataout(ADC_update_values_word3_i));
okWireIn     wi0E(.okHE(okHE),                             .ep_addr(8'h0E), .ep_dataout(adc_clock_sampling_cycles));
okWireIn     wi0F(.okHE(okHE),                             .ep_addr(8'h0F), .ep_dataout(EN_ADC));


okWireOut    wo2E(.okHE(okHE), .okEH(okEHx[ 16*65 +: 65 ]), .ep_addr(8'h2E), .ep_datain({ fifo_adc_empty})); // 1+1+13
okWireOut    wo2F(.okHE(okHE), .okEH(okEHx[ 17*65 +: 65 ]), .ep_addr(8'h2F), .ep_datain({ fifo_adc_full})); // 1+1+13
okWireOut    wo30(.okHE(okHE), .okEH(okEHx[ 18*65 +: 65 ]), .ep_addr(8'h30), .ep_datain({fifo_adc_data_count})); // 1+1+13
//okWireOut    wo31(.okHE(okHE), .okEH(okEHx[ 1*65 +: 65 ]), .ep_addr(8'h31), .ep_datain({ADC_word_o})); // 1+1+13


//Testing
okWireIn     wi0A(.okHE(okHE),                             .ep_addr(8'h0A), .ep_dataout(TEST_REQ_1));
okWireOut    wo2D(.okHE(okHE), .okEH(okEHx[ 13*65 +: 65 ]), .ep_addr(8'h2D), .ep_datain(TEST_ACK_1)); // 1+1+13

okWireIn     wi0B(.okHE(okHE),                             .ep_addr(8'h0B), .ep_dataout(TEST_REQ));
okWireOut    wo29(.okHE(okHE), .okEH(okEHx[ 9*65 +: 65 ]), .ep_addr(8'h29), .ep_datain(TEST_ACK)); // 1+1+13

endmodule
