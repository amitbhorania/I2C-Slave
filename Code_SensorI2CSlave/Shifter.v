`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 			Stevens Institute of Technology
// Engineer: 			Amit Bhorania
// 
// Create Date:    	13:20:40 11/14/2015 
// Design Name: 
// Module Name:    	Shifter 
// Project Name:		SensorI2CSlave
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
`define	ZERO	8'h00

module Shifter(
    input clk,
    input async_rst,
    input load_en,
    input shift_in_en,
	 input shift_out_en,
    input serial_in,
    input [7:0] data_in,
    output reg serial_out,
    output [7:0] data_out
    );

reg [7:0]data;

initial
begin
serial_out <= 1'b1;
data <= 8'h00;
end

always@(posedge async_rst)
begin
	if(async_rst != 0)
	begin
		// Clear the value stored in Data on the Reset
		data = `ZERO;
	end
	else 
	begin
		// Preserve the data as it is
		data = data;
	end
end

always@(posedge load_en)
begin
	if(load_en != 0)
	begin
		// Load the value into the Data
		data = data_in;
	end

	else 
	begin
		// Preserve the data as it is
		data = data;
	end
end

always@(posedge clk)
begin
	if(shift_in_en != 0)
	begin
		// Shift the data to the left and store the incoming bit into LSB of data
		data = {data[6:0], serial_in};
	end
	
	else 
	begin
		// Preserve the data as it is
		data = data;
	end
end

always@(negedge clk or posedge shift_out_en)
begin
	if(shift_out_en != 0)
	begin
		// Shift the MSB to the Serial Out
		serial_out = data[7];
		// Shift the data to the left and LSB will be 0
		data = {data[6:0], 1'b0};
	end
	
	else 
	begin
		// Preserve the data as it is
		data = data;
		
		// Make the SDA as High
		serial_out = 1'b1;
	end
end

// Assign the data to the Data Out
assign data_out = data;

endmodule
