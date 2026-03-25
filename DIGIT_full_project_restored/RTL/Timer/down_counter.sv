// (c) Technion IIT, Department of Electrical Engineering 2022 
// Updated by Mor Dahan - January 2022

// Implements a 4 bits down counter 9 down to 0 with several enable inputs and loadN data.
// It outputs count and asynchronous terminal count, tc, signal 

module down_counter
	(
	input logic clk, 
	input logic resetN, 
	input logic loadN, 
	input logic enable_timer,
	input logic enable_one_sec, 
	input logic enable_counter, 
	input logic [3:0] datain,
	
	output logic [3:0] count,
	output logic tc
   );

// Down counter
always_ff @(posedge clk or negedge resetN)
   begin
	      
      if ( !resetN )	begin// Asynchronic reset
			
			count <= 4'h0;
			
		end
				
      else 	begin		// Synchronic logic	

			if (!loadN) count <= datain;
			else if (enable_timer && enable_one_sec && enable_counter) begin
				if (count == 4'h0) count <= 4'h9;
				else count <= count - 4'h1;
			end
				
		end //Synch
	end //always

	
	// Asynchronic tc

	assign tc = (count == 4'h0);

endmodule
