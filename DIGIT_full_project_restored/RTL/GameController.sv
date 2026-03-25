// ////////////////////////////////////
// Game Controller						 //
// Noa Malul & Idan Peassach 			 //	
// Gold Miner								 //
// Created: 5.12.25						 //
// Last Modified: 21.12.25				 //
///////////////////////////////////////


module GameController (
	input logic clk,
	input logic resetN,
	input logic start,
	input logic throw_hook,
	input logic drawing_request_hook,
	input logic drawing_request_gold,
	input logic drawing_request_rock,
	input logic drawing_request_purp_diamond,
	input logic hook_retrieved,
	input logic [7:0] map_num_random,
	input logic [10:0] Xend,
	input logic [10:0] Yend,
	input logic timer_tc,
	input logic [3:0] curr_obj_idx,
	input logic drawing_request_dynamite,
	input logic drawing_request_clock,
	
	output logic[2:0] speed,
	output logic[13:0] score,
	output logic[2:0] collision_id,
	output logic[2:0] fsm_state,
	output logic objectDrawingRequest,
	output logic [7:0] map_num_out,
	output logic enable_timer,
	output logic start_timerN,
	output logic [4:0] gold_not_taken,
	output logic [4:0] rock_not_taken,
	output logic [2:0] purp_diamond_not_taken,
	output logic [3:0] level,
	output logic [13:0] target,
	output logic [3:0] melody_select,
	output logic [3:0] timer_datainM,
	output logic [3:0] timer_datainL, 
	output logic [3:0] dynamite_not_taken,
	output logic		 clock_not_taken
	);
	
	//------------------------------------------------------------------------------------------------------
	// PARAMETERS:
	
	parameter logic[2:0] VERYFAST = 3;
	parameter logic[2:0] FAST = 2;
	parameter logic[2:0] SLOW = 1;
	parameter [13:0] NOTHING_SCORE = 0;
	parameter [13:0] PURPLE_DIAMOND_SCORE = 200; 
	parameter [13:0] GOLD_SCORE = 100;
	parameter [13:0] ROCK_SCORE = 5;
	parameter logic signed [13:0] DYNAMITE_SCORE = -100;
	localparam maxX = 639;
	localparam maxY = 479;
	//------------------------------------------------------------------------------------------------------
	
	enum logic [2:0] {IDLE_ST,
							WAIT_ST,
							HOOK_DOWN_ST,
							HOOK_UP_ST,
							WINNING_ST,
							LOSING_ST} GAME_SM;
							
	enum logic [2:0] {NOTHING,
							GOLD,
							ROCK,
							PURPLE_DIAMOND,
							DYNAMITE,
							CLOCK,
							BOARDERS} COLLISION_ID;
	
	logic [0:6][13:0] scores = '{NOTHING_SCORE, GOLD_SCORE, ROCK_SCORE, PURPLE_DIAMOND_SCORE, DYNAMITE_SCORE, NOTHING_SCORE, NOTHING_SCORE};
	
	logic [0:5][13:0] targets = '{14'd200, 14'd300, 14'd310, 14'd350, 14'd400, 14'd510};
	
	logic [0:5][3:0] level_timerM = '{4'd6, 4'd5, 4'd5, 4'd4, 4'd4, 4'd3};
	logic [0:5][3:0] level_timerL = '{4'd0, 4'd5, 4'd0, 4'd5, 4'd0, 4'd5}; 
	 
	logic game_started;
	
	
	assign collision_id = COLLISION_ID;
	assign fsm_state = GAME_SM;
	assign objectDrawingRequest = drawing_request_rock || drawing_request_gold || drawing_request_purp_diamond 
											|| drawing_request_dynamite || drawing_request_clock;
	assign timer_datainM = level_timerM[level-4'b1];
	assign timer_datainL = level_timerL[level-4'b1];
	assign target = targets[level-4'b1];
	
	//------------------------------------------------------------------------------------------------------
	// FSM LOGIC:
	
	
	always_ff @(posedge clk or negedge resetN) begin : fsm_game_controller
		if (resetN == 1'b0) begin
			GAME_SM <= IDLE_ST;
			score <= 13'b0;
			start_timerN <= 1'b1;
			enable_timer <= 1'b1;
			speed <= VERYFAST;
			COLLISION_ID <= NOTHING;
			map_num_out <= 7'b0;
			gold_not_taken <= 5'b11111;
			rock_not_taken <= 5'b11111;
			purp_diamond_not_taken <= 3'b111;
			dynamite_not_taken <= 4'b1111;
			melody_select <= 4'b0;
			game_started <= 1'b0;
			clock_not_taken <= 1'b1;
			level <= 4'b1;
		end
		
		else begin
			// defaults:
			speed <= VERYFAST;
			enable_timer <= 1'b1;
			start_timerN <= 1'b1;
			
			if (timer_tc && game_started)
				GAME_SM <= LOSING_ST; 
				
			if(score >= target)
				GAME_SM <= WINNING_ST;
				
			case (GAME_SM) 
				IDLE_ST: begin
					game_started <= 1'b0;
					enable_timer <= 1'b0;
					gold_not_taken <= 5'b11111;
					rock_not_taken <= 5'b11111;
					purp_diamond_not_taken <= 3'b111;
					dynamite_not_taken <= 4'b1111;
					clock_not_taken <= 1'b1;
					score <= 13'b0;
					if (start) begin
						GAME_SM <= WAIT_ST;
						game_started <= 1'b1;
						map_num_out <= map_num_random;
						enable_timer <= 1'b1;
						start_timerN <= 1'b0;
					end
				end
				WAIT_ST: begin
					if (throw_hook) begin
						GAME_SM <= HOOK_DOWN_ST;
						speed <= VERYFAST;
					end
				end
				HOOK_DOWN_ST: begin
					if(drawing_request_hook	&& drawing_request_gold) begin
						speed <= FAST;
						COLLISION_ID <= GOLD;
						GAME_SM <= HOOK_UP_ST;
						gold_not_taken[curr_obj_idx] <= 1'b0;
						melody_select <= 4'd1;
					end
					else if (drawing_request_hook	&& drawing_request_rock) begin
						speed <= SLOW;
						GAME_SM <= HOOK_UP_ST;
						COLLISION_ID <= ROCK;
						rock_not_taken[curr_obj_idx] <= 1'b0;
						melody_select <= 4'd2;
					end
					else if (drawing_request_hook	&& drawing_request_purp_diamond) begin
						speed <= SLOW;
						GAME_SM <= HOOK_UP_ST;
						COLLISION_ID <= PURPLE_DIAMOND;
						purp_diamond_not_taken[curr_obj_idx] <= 1'b0;
						melody_select <= 4'd1;
					end
					else if (drawing_request_hook	&& drawing_request_dynamite) begin
						speed <= FAST;
						GAME_SM <= HOOK_UP_ST;
						COLLISION_ID <= DYNAMITE;
						dynamite_not_taken[curr_obj_idx] <= 1'b0;
						melody_select <= 4'd2;
					end
					else if (drawing_request_hook	&& drawing_request_clock) begin
						speed <= SLOW;
						GAME_SM <= HOOK_UP_ST;
						COLLISION_ID <= CLOCK;
						clock_not_taken <= 1'b0;
						melody_select <= 4'd1;
					end
					else if (Xend <= 0 || Xend >= maxX || Yend <= 0 || Yend >= maxY) begin
						speed <= VERYFAST;
						GAME_SM <= HOOK_UP_ST;
						COLLISION_ID <= BOARDERS;
					end
				end
				HOOK_UP_ST: begin
					speed <= speed;
					if (hook_retrieved) begin
						if(COLLISION_ID != CLOCK) begin
							if (COLLISION_ID != DYNAMITE || score > 13'd100) begin
								score <= score + scores[COLLISION_ID];
							end
							else score <= 13'b0;
						end
						if (COLLISION_ID == CLOCK) begin
							start_timerN <= 1'b0;
						end
						if(COLLISION_ID == GOLD || COLLISION_ID == PURPLE_DIAMOND || COLLISION_ID == CLOCK)
							melody_select <= 4'd1;
						else if (COLLISION_ID == ROCK || COLLISION_ID == DYNAMITE)
							melody_select <= 4'd2;
						else 	melody_select <= 4'b0;
						GAME_SM <= WAIT_ST;
						COLLISION_ID <= NOTHING;
					end
				end
				LOSING_ST: begin
					game_started <= 1'b0;
					enable_timer <= 1'b0;
					COLLISION_ID <= NOTHING;
					if (start) begin 						
						gold_not_taken <= 5'b11111;
						rock_not_taken <= 5'b11111;
						purp_diamond_not_taken <= 3'b111;
						dynamite_not_taken <= 4'b1111;
						clock_not_taken <= 1'b1;
						melody_select <= 4'b0;
						score <= 13'b0;
						level <= 4'b1;
						GAME_SM <= WAIT_ST;
						game_started <= 1'b1;
						map_num_out <= map_num_random;
						enable_timer <= 1'b1;
						start_timerN <= 1'b0;
					end
				end
				WINNING_ST: begin
					game_started <= 1'b0;
					enable_timer <= 1'b0;
					COLLISION_ID <= NOTHING;
					if (start) begin 						
						gold_not_taken <= 5'b11111;
						rock_not_taken <= 5'b11111;
						purp_diamond_not_taken <= 3'b111;
						dynamite_not_taken <= 4'b1111;
						clock_not_taken <= 1'b1;
						melody_select <= 4'b0;
						score <= 13'b0;
						if(level <= 4'd5) level <= level + 4'b1;
						else level <= 4'b1;
						GAME_SM <= WAIT_ST;
						game_started <= 1'b1;
						map_num_out <= map_num_random;
						enable_timer <= 1'b1;
						start_timerN <= 1'b0;
					end
				end
			endcase
		end
	end
endmodule
	
	
	

	
