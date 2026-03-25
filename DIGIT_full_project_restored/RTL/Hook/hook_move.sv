// ////////////////////////////////////
// hook_move		     				    //
// Noa Malul & Idan Peassach 			 //	
// Gold Miner								 //
// Created: 6.12.25						 //
// Last Modified: 7.12.25				 //
///////////////////////////////////////


module hook_move(
	input logic clk,
	input logic resetN,
	input logic enableAlpha,
	input logic enableHook,
	input logic[2:0] hook_state, 
	input logic[3:0] level,
	
	
	output logic hookRetrieved,
	output logic[10:0] hookCenterX,
	output logic[10:0] hookCenterY,
	output logic[10:0] radius,
	output logic[7:0] alpha
); 

parameter int CenterX = 320; 
parameter int CenterY = 130 ;
parameter int InitRadius = 32;

parameter logic[7:0] initAlpha = 45;
parameter logic[7:0] maxAlpha = 150;
parameter logic[7:0] minAlpha = 30;

assign hookCenterX = CenterX; 
assign hookCenterY = CenterY;

logic [2:0] IDLE_ST = 3'd0;
logic [2:0] WAIT_ST = 3'd1;
logic [2:0] HOOK_DOWN_ST = 3'd2;
logic [2:0] HOOK_UP_ST = 3'd3;
logic [0:5][3:0] alphaMove = '{4'd1 , 4'd2, 4'd2, 4'd3, 4'd3, 4'd3};

logic left = 1'b0 ;

always_ff @(posedge clk or negedge resetN) 
begin 
	
	if(!resetN) begin
			radius <= InitRadius ; 
			alpha <= initAlpha ; 
			hookRetrieved <= 1'b0;
	end
	else begin
		hookRetrieved <= 1'b0;

		case(hook_state)
			
			IDLE_ST: begin 
						radius <= InitRadius ; 
						alpha <= initAlpha ;  
			end
			WAIT_ST: begin
				if(enableAlpha) begin
					if(left) begin 
						if(alpha < maxAlpha) begin
							alpha <= alpha + alphaMove[level-1];
						end
						else begin
							alpha <= alpha - alphaMove[level-1];
							left <= 1'b0;
						end
					end
					else begin
							if(alpha > minAlpha) begin
								alpha <= alpha - alphaMove[level-1];
							end
							else begin
								alpha <= alpha + alphaMove[level-1];
								left <= 1'b1;
							end
					end
				end
						
			end
	
			HOOK_DOWN_ST: begin
					if (enableHook) radius <= radius + 4; 
			end
			
			HOOK_UP_ST: begin
					if (enableHook) radius <= radius - 4; 
					if (radius <= 1) begin
						hookRetrieved <= 1'b1;
						radius <= InitRadius; 
					end
			end
			
			default: begin
					radius <= InitRadius ; 
					alpha <= initAlpha ; 
					hookRetrieved <= 1'b0;
			end
			
		endcase
	end
end
endmodule