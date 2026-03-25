// ////////////////////////////////////
// score_split   	     				    //
// Noa Malul & Idan Peassach 			 //	
// Gold Miner								 //
// Created: 6.12.25						 //
// Last Modified: 6.12.25				 //
///////////////////////////////////////

module score_split (

//	input logic clk,
//	input logic resetN,
	input logic[13:0] score,
//	input logic hookRetrieved,
	
	output logic[3:0] score_ones,
	output logic[3:0] score_tens,
	output logic[3:0] score_hundreds,
	output logic[3:0] score_thousands
);



//logic[3:0] temp_ones;
//logic[3:0] temp_tens;
//logic[3:0] temp_hundreds;
//logic[3:0] temp_thousands;
logic[31:0] temp_score; 
//logic finish;
//always_ff@(posedge clk or negedge resetN)
//begin
//		if(!resetN) begin
//			score_ones <= 3'b0;
//			score_tens <= 3'b0;
//			score_hundreds <= 3'b0;
//			score_thousands <= 3'b0;
//			temp_ones <= 3'b0;
//			temp_tens <= 3'b0;
//			temp_hundreds <= 3'b0;
//			temp_thousands <= 3'b0;
//			temp_score <= score; 
//			finish <= 1'b0;
//		end
//		
//		else begin
//				if(hookRetrieved) begin
//					temp_ones <= 3'b0;
//					temp_tens <= 3'b0;
//					temp_hundreds <= 3'b0;
//					temp_thousands <= 3'b0;
//					temp_score <= score; 
//					finish <= 1'b0;
//				end
//				
//				if(temp_score >= 1000)begin
//					temp_thousands <= temp_thousands + 1; 
//					temp_score <= temp_score - 1000; 
//				end
//				if(temp_score >= 100)begin
//					temp_hundreds <= temp_hundreds + 1; 
//					temp_score <= temp_score - 100; 
//				end
//				if(temp_score >= 10)begin
//					temp_tens <= temp_tens + 1; 
//					temp_score <= temp_score - 10; 
//				end	
//				if(temp_score >= 1)begin
//					temp_ones <= temp_ones + 1; 
//					temp_score <= temp_score - 1; 
//				end
//				
//				if(temp_score == 0 ) begin
//					score_thousands <= temp_thousands;
//					score_hundreds <= temp_hundreds;
//					score_tens <= temp_tens;
//					score_ones <= temp_ones;
//				end

always_comb begin
				temp_score = score;
				
				score_thousands = temp_score / 1000 ;
				temp_score = temp_score % 1000; 
				
				score_hundreds = temp_score / 100 ;
				temp_score = temp_score % 100; 
				
				score_tens = temp_score / 10;
				temp_score = temp_score % 10; 
				
				score_ones = temp_score % 10;
				
		//end
end
endmodule 


