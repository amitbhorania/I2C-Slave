`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 			Stevens Institute of Technology
// Engineer: 			Amit Bhorania
// 
// Create Date:    	14:12:38 11/16/2015 
// Design Name: 
// Module Name:    	Counter 
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
module Counter(
    input clk,
    input async_rst,
    input enable,
    input load,
    input [7:0] data_in,
    output [7:0] data_out,
	 output signal_count8
    );

reg [7:0]data;
reg signal;

initial
begin
data <= 8'h00;
signal <= 1'b0;
end

always@(posedge async_rst)
begin
	if(async_rst != 0)
	begin
		// Clear the Data Value
		data = 8'h00;
	end
	
	else 
	begin
		// Preserve the data
		data = data;
	end
end

always@(posedge clk or posedge load)
begin
	if(load != 0)
	begin
		// Store the new value to the data register
		data = data_in;
	end
	
	else if(enable != 0)
	begin
		// Increment the data by 1
		data = data + 1'b1;
	end
	
	else 
	begin
		// Preserve the data
		data = data;
	end
	
	// Check if the Count is 8?
	if(data == 8'h8)
	begin
		// make the signal for count8 as 1
		signal = 1'b1;
		
		// Clear the Data to 0
		data = 0;
	end
	else
	begin
		// make the signal for count8 as 0
		signal = 1'b0;
	end
end

assign data_out = data;
assign signal_count8 = signal;

endmodule
