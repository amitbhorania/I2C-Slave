`timescale 1ns / 1ps

`define ENABLE					1'b1
`define DISABLE				1'b0
`define SDA_HIGH				1'b1
`define SDA_LOW				1'b0

`define ZERO					8'h00

`define STATE_IDLE			4'h0
`define STATE_SLAVEADDR		4'h1
`define STATE_SENDACK		4'h2
`define STATE_SLAVE_READ	4'h3
`define STATE_SLAVE_WRITE	4'h4
`define STATE_READACK		4'h5
`define STATE_WRITEACK		4'h6

`define SLAVE_READ			1'b0
`define SLAVE_WRITE			1'b1

//////////////////////////////////////////////////////////////////////////////////
// Company: 			Stevens Institute of Technology
// Engineer: 			Amit Bhorania
// 
// Create Date:    	15:12:48 12/10/2015 
// Design Name: 
// Module Name:    	SlaveController 
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
module SlaveController(
    input scl,
	 input sda_in,
	 output reg sda_out,
	 output reg sda_out_en,
    input start_detected,
    input stop_detected,
    output reg shifter_load_en,
    output reg shifter_shift_in_en,
    output reg shifter_shift_out_en,
    output reg [7:0] shifter_data_in,
    input [7:0] shifter_data_out,
    output reg shifter_async_rst,
    output reg counter_enable,
    output reg counter_load,
    output reg [7:0] counter_data_in,
    input [7:0] counter_data_out,
    input counter_signal_count8,
    output reg counter_async_rst,
	 input [7:0]slave_address_reg,
	 input [7:0]txdata_reg,
	 output reg [7:0]rxdata_reg
    );

reg [3:0]slave_state;
reg [7:0]recv_data;
reg ack;

// 0 - Write (Slave needs to Read the Data)
// 1 - Read (Slave needs to Write the Data)
reg read_or_write_mode;

initial
begin
// Initial State as IDLE
slave_state <= `STATE_IDLE;

// Disable the SDA Out Enable
sda_out <= `SDA_HIGH;
sda_out_en <= `DISABLE;

shifter_load_en <= `DISABLE;
shifter_shift_in_en <= `DISABLE;
shifter_shift_out_en <= `DISABLE;
shifter_data_in <= `ZERO;
shifter_async_rst <= `DISABLE;
counter_enable <= `DISABLE;
counter_load <= `DISABLE;
counter_data_in <= `ZERO;
counter_async_rst <= `DISABLE;
rxdata_reg <= `ZERO;

// Clear the Internal Registers
recv_data <= `ZERO;
end	// initial begin

always@(posedge start_detected)
begin
	// Start Condition is detected
	// Now Next will be Slave Address of 7 bit and 1 bit R/W
	slave_state = `STATE_SLAVEADDR;
	
	// Enable Shifter to get the data in for 8 bits
	shifter_shift_in_en = `ENABLE;
	shifter_async_rst = `ENABLE;
	
	// Enable the Counter to count for 8 values
	counter_enable = `ENABLE;
	counter_async_rst = `ENABLE;
end

always@(posedge stop_detected)
begin
	// Stop Condition is detected
	// Transmission is over and Slave will be Idle
	
	// Disable Shifter
	shifter_shift_in_en = `DISABLE;
	shifter_shift_out_en = `DISABLE;
	shifter_async_rst = `DISABLE;
	
	// Disable the Counter
	counter_enable = `DISABLE;
	counter_async_rst = `DISABLE;
	
	// Change State to STATE_IDLE
	slave_state = `STATE_IDLE;
end

always@(posedge scl)
begin
	case(slave_state)
	`STATE_WRITEACK:
		begin
			ack = sda_in;
			
			if(ack == `SDA_LOW)
			begin
				// ACK is received from Master
				// Keep the State to STATE_WRITEACK
				// It will further handled at the negedge
				slave_state = `STATE_WRITEACK;
			end
			
			else
			begin
				// Received NACK from Master
				// No further Transmission required
				
				// Change State to STATE_IDLE
				slave_state = `STATE_IDLE;
			end
		end
	endcase
end

always@(negedge scl)
begin
	// Handling the Counter's Clock0 Signal8
	if(counter_signal_count8 == 1'b1)
	begin
		case(slave_state)
		`STATE_SLAVEADDR:
			begin
				// Slave was getting the Slave Address and R/W Bit
				// Now 8 bits are received
				// Stop the Counter
				counter_enable = `DISABLE;		
				counter_async_rst = `DISABLE;
				
				// Stop the Shifter
				shifter_shift_in_en = `DISABLE;
				shifter_async_rst = `DISABLE;
				
				// Get the values from Shifter
				recv_data = shifter_data_out;
			
				// Compare the Slave Address
				if(recv_data[7:1] == slave_address_reg[6:0])
				begin
					// Address Matches
					// save the mode of transfer
					read_or_write_mode = recv_data[0];
					
					// Send Acknowledgement
					// Write 0 to SDA for one clock pulse
					sda_out = `SDA_LOW;
					sda_out_en = `ENABLE;
					
					// Change state to ACK
					slave_state = `STATE_SENDACK;
				end
				else
				begin
					// Address does not match
					// keep the sda on High Impedence - NACK
					sda_out = `SDA_HIGH;
					sda_out_en = `DISABLE;
					
					// Change state to ACK
					slave_state = `STATE_IDLE;
				end
			end
			
		`STATE_SLAVE_READ:
			begin
				// Slave was receiving the Data from Master
				// Now 8 bits are received
				// Stop the Counter
				counter_enable = `DISABLE;		
				counter_async_rst = `DISABLE;
				
				// Stop the Shifter
				shifter_shift_in_en = `DISABLE;
				shifter_async_rst = `DISABLE;
				
				// Get the values from Shifter
				rxdata_reg = shifter_data_out;
				
				// Next Send the ACK to Master
				// Write 0 to SDA for one clock pulse
				sda_out = `SDA_LOW;
				sda_out_en = `ENABLE;
				
				// Change state to ACK
				slave_state = `STATE_READACK;
			end
			
		`STATE_SLAVE_WRITE :
			begin
				// Slave was writing the Data to Master
				// Now 8 bits are sent
				
				// Stop the Shifter
				shifter_shift_out_en = `DISABLE;
				shifter_load_en = `DISABLE;
				shifter_async_rst = `DISABLE;
				
				// Stop the Counter
				counter_enable = `DISABLE;		
				counter_async_rst = `DISABLE;
				
				// Next Wait for the ACK from Master
				sda_out = `SDA_HIGH;
				sda_out_en = `DISABLE;
				
				// Change state to STATE_WRITEACK
				slave_state = `STATE_WRITEACK;
			end
		endcase
	end	// if(counter_signal_count8 == 1'b1)
	
	else
	begin
		case(slave_state)
		`STATE_SENDACK:
			begin
				// by now, ACK will have been sent
				// Disable the sda_out_en
				sda_out = `SDA_HIGH;
				sda_out_en = `DISABLE;
				
				// Check the Mode of the Operation - Read or Write
				if(read_or_write_mode == `SLAVE_READ)
				begin
					// Slave is in the Read Mode
					// Enable the Shifter for receiving the data
					shifter_shift_in_en = `ENABLE;
					shifter_async_rst = `ENABLE;
					
					// Enable the Counter to count for 8 values
					counter_enable = `ENABLE;
					counter_async_rst = `ENABLE;
					
					// Change State to STATE_SLAVE_READ
					slave_state = `STATE_SLAVE_READ;
				end
				else
				begin
					// Slave is in Write Mode
					// Enable the Shifter for sending the data
					shifter_data_in = txdata_reg;
					shifter_load_en = `ENABLE;
					
					// Enable the SDA Buffer for Writing the data
					sda_out = `SDA_HIGH;
					sda_out_en = `ENABLE;
					
					// Enable the Counter to count for 8 values
					counter_enable = `ENABLE;
					counter_async_rst = `ENABLE;
					
					shifter_shift_out_en = `ENABLE;
					
					// Change State to STATE_SLAVE_WRITE
					slave_state = `STATE_SLAVE_WRITE;
				end
			end
		`STATE_READACK	:
			begin
				// by now, ACK will have been sent
				// Disable the sda_out_en
				sda_out = `SDA_HIGH;
				sda_out_en = `DISABLE;
				
				// Slave will continue to receive the Data
				// Enable the Shifter for receiving the data
				shifter_shift_in_en = `ENABLE;
				shifter_async_rst = `ENABLE;
				
				// Enable the Counter to count for 8 values
				counter_enable = `ENABLE;
				counter_async_rst = `ENABLE;
					
				// Change State to STATE_SLAVE_READ
				slave_state = `STATE_SLAVE_READ;
			end
			
		`STATE_WRITEACK:
			begin
				// We have received the ACK from the Master
				// Slave will continue to write the data into the Master
				// Enable the Shifter for sending the data
				shifter_data_in = txdata_reg;
				shifter_load_en = `ENABLE;
				
				// Enable the SDA Buffer for Writing the data
				sda_out = `SDA_HIGH;
				sda_out_en = `ENABLE;
				
				// Enable the Counter to count for 8 values
				counter_enable = `ENABLE;
				counter_async_rst = `ENABLE;
				
				shifter_shift_out_en = `ENABLE;
								
				// Change State to STATE_SLAVE_WRITE
				slave_state = `STATE_SLAVE_WRITE;
			end
		endcase
	end
end

endmodule
