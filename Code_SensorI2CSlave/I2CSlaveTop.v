`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:				Stevens Institute of Technology 
// Engineer: 			Amit Bhorania
// 
// Create Date:    	16:50:16 12/16/2015 
// Design Name: 
// Module Name:    	I2CSlaveTop 
// Project Name: 		SensorI2CSlave
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module I2CSlaveTop(
    inout scl,
    inout sda,
	 output [7:0]rx_data_out
    );

reg scl_oen;
//reg sda_out;

// Slave Address Register
reg [7:0] Slave_Address_Reg;

// Receive Data Register
//reg [7:0] Rx_Data_Reg;

// Transmit Data Register
reg [7:0] Tx_Data_Reg;

wire [7:0] rx_data_reg_wire;

wire scl_pad_oen;
wire scl_pad_o;
wire scl_pad_i;
wire sda_pad_oen;
wire sda_pad_o;
wire sda_pad_i;

wire sda_out_slave_controller;
wire sda_out_shifter;
wire start_detected;
wire stop_detected;
wire shifter_load_en;
wire shifter_shift_in_en;
wire shifter_shift_out_en;
wire [7:0] shifter_data_in;
wire [7:0] shifter_data_out;
wire shifter_async_rst;
wire counter_enable;
wire counter_load;
wire [7:0] counter_data_in;
wire [7:0] counter_data_out;
wire counter_signal_count8;
wire counter_async_rst;

initial 
begin
// We dont need to drive the SCL. Therefore make it 0 so that SCL will be only input;
scl_oen = 0;

// Slave Address Reg is choosen as 0x53
Slave_Address_Reg <= 8'h53;

// Data to transmit
Tx_Data_Reg <= 8'hB3;

// Random Value for Received Data
// Rx_Data_Reg <= 8'h29;

end

// Assign the scl_pad_oen from the reg
assign scl_pad_oen = scl_oen;

// Combine the output of slave controller and shifter of sda_out by bitwise AND Operation
assign sda_pad_o = (sda_out_slave_controller & sda_out_shifter);

// Implement the TriState Buffer for the scl and sda
assign scl = scl_pad_oen ? scl_pad_o : 1'bz;
assign sda = sda_pad_oen ? sda_pad_o : 1'bz;
assign scl_pad_i = scl;
assign sda_pad_i = sda;

assign rx_data_out = rx_data_reg_wire;

// Create the instances of the modules
Counter counter_instance(
	.clk(scl_pad_i), 
	.async_rst(counter_async_rst), 
	.enable(counter_enable), 
	.load(counter_load), 
	.data_in(counter_data_in), 
	.data_out(counter_data_out), 
	.signal_count8(counter_signal_count8)
	);

Shifter shifter_instance(
    .clk(scl_pad_i),
    .async_rst(shifter_async_rst),
    .load_en(shifter_load_en),
    .shift_in_en(shifter_shift_in_en),
	 .shift_out_en(shifter_shift_out_en),
    .serial_in(sda_pad_i),
    .data_in(shifter_data_in),
    .serial_out(sda_out_shifter),
    .data_out(shifter_data_out)
    );
	 
Start_Stop_Detector start_stop_detector_instance(
    .scl(scl_pad_i),
    .sda(sda_pad_i),
    .start_detected(start_detected),
    .stop_detected(stop_detected)
    );

SlaveController slaveController_instance(
    .scl(scl_pad_i),
	 .sda_in(sda_pad_i),
	 .sda_out(sda_out_slave_controller),
	 .sda_out_en(sda_pad_oen),
    .start_detected(start_detected),
    .stop_detected(stop_detected),
    .shifter_load_en(shifter_load_en),
    .shifter_shift_in_en(shifter_shift_in_en),
    .shifter_shift_out_en(shifter_shift_out_en),
    .shifter_data_in(shifter_data_in),
    .shifter_data_out(shifter_data_out),
    .shifter_async_rst(shifter_async_rst),
    .counter_enable(counter_enable),
    .counter_load(counter_load),
    .counter_data_in(counter_data_in),
    .counter_data_out(counter_data_out),
    .counter_signal_count8(counter_signal_count8),
    .counter_async_rst(counter_async_rst),
	 .slave_address_reg(Slave_Address_Reg),
	 .txdata_reg(Tx_Data_Reg),
	 .rxdata_reg(rx_data_reg_wire)
    );

endmodule
