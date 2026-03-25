// ////////////////////////////////////
// enable_timer	     				    //
// Noa Malul & Idan Peassach 			 //	
// Gold Miner								 //
// Created: 6.12.25						 //
// Last Modified: 6.12.25				 //
///////////////////////////////////////

module enable_timer(
	input logic clk,
	input logic resetN,
	input logic startOfFrame,
	
	output timerDone
);

parameter logic[2:0] countTo = 5; 

logic[2:0] counter; 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			counter	<= 3'b0;
	end
	
	else begin 
		timerDone <= 1'b0;
		if(startOfFrame) begin
			if(counter < countTo) begin 
			counter <= counter + 1;
			timerDone <= 1'b0;
			end
			else if (counter == countTo) begin
					counter <= 3'b0;
					timerDone <= 1'b1;
			end
		end
	end 
end
endmodule