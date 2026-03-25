///////////////////////////////////////
// Mux            						 //
// Noa Malul & Idan Peassach 			 //	
// Gold Miner								 //
// Created: 6.12.25						 //
// Last Modified: 6.12.25				 //
///////////////////////////////////////

module	objects_mux	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
					
		   // Objects
					input		logic	ObjectDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] ObjectRGB,		     

		   // background 
					input		logic	BGDrawingRequest,  
					input		logic	[7:0] backgroundRGB, 
					
			// hook
					input		logic	hookDrawingRequest,
					input		logic	[7:0] hookRGB,
			
			// timer
					input		logic	timerDrawingRequest,
					input		logic [7:0] timerRGB,
					
			// score
					input logic scoreDrawingRequest,
					input logic [7:0] scoreRGB,
					
			// lifting
					input logic liftedObjDrawingRequest,
					input logic [7:0] liftedObjRGB,
					
					
			//target
					input logic targetDrawingRequest,
					input logic [7:0] targetRGB,
					
			//level
					input logic levelDrawingRequest,
					input logic [7:0] levelRGB,
					
			// screens 
					input logic screenDrawingRequest,
					input logic [7:0] screenRGB,
					
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut <= 8'b0;
	end
	
	else begin
	
		if(screenDrawingRequest == 1'b1) begin
			RGBOut <= screenRGB; //first priority 
		end
		
	
		else if (hookDrawingRequest == 1'b1 )  begin
			RGBOut <= hookRGB; 		 	 //second priority 
		end
		 
//---------------------------------------------------------------------------------		
		
		else if(liftedObjDrawingRequest == 1'b1)begin
			RGBOut <= liftedObjRGB;  	// third priority
		end
		
//---------------------------------------------------------------------------------

		else if (ObjectDrawingRequest == 1'b1 )  begin 
			RGBOut <= ObjectRGB; 		 // 4th priority
		end
		
//---------------------------------------------------------------------------------	

		else if (timerDrawingRequest == 1'b1 )  begin 
			RGBOut <= timerRGB; 		 // 5th priority
		end
		
//---------------------------------------------------------------------------------

		else if(scoreDrawingRequest == 1'b1)begin
			RGBOut <= scoreRGB;  	// 6th priority
		end
		
		else if(targetDrawingRequest == 1'b1)begin
			RGBOut <= targetRGB;  	// 7th priority
		end
		
		else if(levelDrawingRequest == 1'b1)begin
			RGBOut <= levelRGB;  	// 8th priority
		end
		
		else begin
			RGBOut <= backgroundRGB ;   // last priority
		end
	end 
end
endmodule


