`timescale 100ns / 10ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    04:37:16 12/13/2015 
// Design Name: 
// Module Name:    testbench 
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
`define SLAVE_ADDR				7'h53
`define INVALID_SLAVE_ADDR		7'h60

module testbench(
    );

wire Clk;

// Bidirs
tri1 sda;
	
wire [7:0] rx_data_out;

// 8 bit number received via I2C bus from slave
integer serial_recv_data;
reg received_ack;

// Unit Instances
Clockgen clockgen_instance(.Clk(Clk));

I2CSlaveTop I2CSlaveTop_instance(.scl(Clk), .sda(sda), .rx_data_out(rx_data_out));

// Initialization
initial
begin
	release sda;
	
	serial_recv_data = 8'h00;
	// Wait 200 ns for global reset to finish
	#2;
	
	// Start a sequence
	// Master Writes 1 Bytes
	$display("1. Starting I2C Operation - Master Sends 1 Byte");
	
	start;
	
	send_slave_address_with_WRITE(`SLAVE_ADDR);

	wait_for_ACK(received_ack);
	
	if(received_ack == 1'b0)
	begin
		// ACK Received
		send_DATA(8'h26);
		
		wait_for_ACK(received_ack);
		
		stop;
		
		$display("Serial data sent to the slave");
	end
	else
	begin
		// NegACK Received
		stop;
		
		$display("No Slave available at address: %h", `SLAVE_ADDR);
	end
	
	$display("I2C Operation Over");
	
	#500;
	
	// Start a sequence
	// Master Reads 1 Byte
	$display("2. Starting I2C Operation - Master reads 1 Byte");
	
	start;
	
	send_slave_address_with_READ(`SLAVE_ADDR);

	wait_for_ACK(received_ack);
	
	if(received_ack == 1'b0)
	begin
		// ACK Received
		recv_DATA(serial_recv_data);
	
		Send_NegACK;
		
		stop;
		
		$display("Serial data received from slave: %h" , serial_recv_data);
	end
	else
	begin
		// NegACK Received
		stop;
		
		$display("No Slave available at address: %h", `SLAVE_ADDR);
	end
	
	$display("I2C Operation Over");
	
	#500;
	
	// Start a sequence
	// Master Reads 1 Byte
	$display("3. Starting I2C Operation - Invalid Slave Address");
	
	start;
	
	send_slave_address_with_READ(`INVALID_SLAVE_ADDR);

	wait_for_ACK(received_ack);
	
	if(received_ack == 1'b0)
	begin
		// ACK Received
		recv_DATA(serial_recv_data);
	
		Send_NegACK;
		
		stop;
		
		$display("Serial data received from slave: %h" , serial_recv_data);
	end
	else
	begin
		// NegACK Received
		stop;
		
		$display("No Slave available at address: %h", `INVALID_SLAVE_ADDR);
	end
	
	$display("I2C Operation Over");
	
	#500;
	
	// Start a sequence
	// Master Writes multiple Bytes
	$display("4. Starting I2C Operation - Master Sends Multiple Bytes");
	
	start;
	
	send_slave_address_with_WRITE(`SLAVE_ADDR);

	wait_for_ACK(received_ack);
	
	if(received_ack == 1'b0)
	begin
		// ACK Received
		send_DATA(8'h1A);
		
		wait_for_ACK(received_ack);
		
		if(received_ack == 1'b0)
		begin
			$display("Serial data sent to the slave");
			
			send_DATA(8'h2B);
		
			wait_for_ACK(received_ack);
			
			if(received_ack == 1'b0)
			begin
				stop;
				
				$display("Serial data sent to the slave");
			end
			else
			begin
				stop;
		
				$display("No ACK Received from Slave");
			end
		end
		
		else
		begin
			stop;
		
			$display("No ACK Received from Slave");
		end
	end
	else
	begin
		// NegACK Received
		stop;
		
		$display("No Slave available at address: %h", `SLAVE_ADDR);
	end
	
	$display("I2C Operation Over");
	
 	#500;
end

	task start;
	begin
		@(posedge Clk)
		begin
			#20 force sda = 0;
			#40;
		end
	end
	endtask
	
	task stop;
	begin
		begin
			#10 force sda = 0;
			#50 force sda = 1;
			#40;
		end
	end
	endtask
	
	task send_slave_address_with_WRITE;
	input integer slave_address;
	integer count;
	integer bit_ptr;
	begin
		for(count = 0 , bit_ptr = 7 ; count < 7 ; count = count + 1)
		begin
			#20 force sda = slave_address[bit_ptr];
			bit_ptr = bit_ptr - 1; // be ready for next address bit
			#80;
		end
		#20 force sda = 0;	// Master WRITE - Slave Read
		#80 release sda;
	end
	endtask
	
	task send_slave_address_with_READ;
	input integer slave_address;
	integer count;
	integer bit_ptr;
	begin
		for(count = 0 , bit_ptr = 7 ; count < 7 ; count = count + 1)
		begin
			#20 force sda = slave_address[bit_ptr];
			bit_ptr = bit_ptr - 1; // be ready for next address bit
			#80;
		end
		#20 force sda = 1;	// Master READ - Slave Write
		#80 release sda;
	end
	endtask
	
	task send_DATA;
	input integer data;
	integer count;
	integer bit_ptr;
	begin
		for(count = 0 , bit_ptr = 8 ; count < 8 ; count = count + 1)
		begin
			#20 force sda = data[bit_ptr];
			bit_ptr = bit_ptr - 1; // be ready for next address bit
			#80;
		end
	end
	endtask
	
	task recv_DATA;
	output [7:0]received_data;
	integer count;
	integer bit_ptr;
	begin
		for(count = 0 , bit_ptr = 7 ; count < 8 ; count = count + 1)
		begin
			#60 received_data[bit_ptr] = sda;
			bit_ptr = bit_ptr - 1; // be ready for next address bit
			#40;
		end
	end
	endtask
	
	task wait_for_ACK;
	output recv_ack;
	begin
		release sda;
		#60 recv_ack = sda;
		#40;
	end
	endtask
	
	task Send_ACK;
	begin
		#20 force sda = 0;
		#80 release sda;
	end
	endtask
	
	task Send_NegACK;
	begin
		#20 force sda = 1;
		#80 release sda;
	end
	endtask
	
endmodule
