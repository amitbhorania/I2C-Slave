`timescale 100ns / 10ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    04:30:19 12/13/2015 
// Design Name: 
// Module Name:    Clockgen 
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
module Clockgen(
    output reg Clk
    );

initial
begin
Clk = 0; // Keep the Clock as Low for Initial State
end
always
begin
#50
Clk = ~Clk; // At every 5 us Clock will toggle
end // Time Period of Clock = 10 us => 100 KHz Freq for I2C

endmodule
