`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:25:13 12/11/2015 
// Design Name: 
// Module Name:    Start_Stop_Detector 
// Project Name: 
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
module Start_Stop_Detector(
    input scl,
    input sda,
    output reg start_detected,
    output reg stop_detected
    );

reg sda_shadow;
reg start_or_stop;

initial
begin
// Clear the Output and internal Registers
start_or_stop = 0;
start_detected = 0;
stop_detected = 0;
end

always@(scl or sda)
begin
	// Add the code for Start Stop bit Detector
	sda_shadow = (~scl | start_or_stop) ? sda : sda_shadow;
	start_or_stop = ~scl ? 1'b0 : (sda ^ sda_shadow);
	
	if(start_or_stop == 1'b1)
	begin
		// Start or Stop Condition is detected
		// Therefore two possibilities are there
		//	sda_shadow = 0 & sda = 1	=> Stop Condition
		//	sda_shadow = 1 & sda = 0	=> Start Condition
		if(sda_shadow == 1'b0 && sda == 1'b1)
		begin
			// Stop Condition
			stop_detected = 1'b1;
		end

		else if(sda_shadow == 1'b1 && sda == 1'b0)
		begin
			// Start Condition
			start_detected = 1'b1;
		end
	end
	else
	begin
		// Clear the both condition
		start_detected = 1'b0;
		stop_detected = 1'b0;
	end
end	// always end

endmodule
