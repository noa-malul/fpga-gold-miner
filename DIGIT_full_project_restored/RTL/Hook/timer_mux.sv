// ////////////////////////////////////
// timer_mux    	     				    //
// Noa Malul & Idan Peassach 			 //	
// Gold Miner								 //
// Created: 21.12.25						 //
// Last Modified: 21.12.25				 //
///////////////////////////////////////

module timer_mux (
	
	input logic clk, 
	input logic resetN, 
	input logic slow,
	input logic fast,
	input logic veryFast,
	input logic[2:0] speed,
	
	
	output logic timerEnable
);


always_ff @(posedge clk or negedge resetN) 
begin 


	if(!resetN) begin
		timerEnable <= 1'b0; 
	end
	
	else begin
		case(speed)
				
				
				2'd0 : begin
					timerEnable <= 1'b0; 
				end
				
				2'd1 : begin
					timerEnable <= slow; 
				end
				
				2'd2 : begin
					timerEnable <= fast; 
				end
				
				2'd3 : begin
					timerEnable <= veryFast; 
				end
		
		
		endcase
	end
end 
endmodule 








