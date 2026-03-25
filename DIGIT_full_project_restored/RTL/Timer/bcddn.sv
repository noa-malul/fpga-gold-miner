// (c) Technion IIT, Department of Electrical Engineering 2022 
// Written By Liat Schwartz August 2018 
// Updated by Mor Dahan - January 2022

// Implements a BCD down counter 99 down to 0 with several enable inputs and loadN data
// having countL, countH and tc outputs
// by instantiating two one bit down-counters


module bcddn
	(
	input  logic clk, 
	input  logic resetN, 
	input  logic loadN, 
	input  logic enable_timer,
	input  logic enable_one_sec, 
	input	 logic [3:0] datainL,
	input	 logic [3:0] datainM,	
	
	output logic [3:0] countL, 
	output logic [3:0] countM,
	output logic tc
   );
	

	logic  tclow, tcmiddle, tchigh;// internal variables terminal count 
	
// Low counter instantiation
	down_counter lowc(.clk(clk), 
							.resetN(resetN),
							.loadN(loadN),	
							.enable_timer(enable_timer), 
							.enable_one_sec(enable_one_sec),
							.enable_counter(1'b1), 	
							.datain(datainL), 
							.count(countL), 
							.tc(tclow) );
			
// Middle counter instantiation
	down_counter midddlec(.clk(clk), 
							.resetN(resetN),
							.loadN(loadN),	
							.enable_timer(enable_timer), 
							.enable_one_sec(enable_one_sec),
							.enable_counter(tclow), 	
							.datain(datainM), 
							.count(countM), 
							.tc(tcmiddle) );
							
//------------------------------------------------------------------------------------------ 
 assign tc =  (tcmiddle && tclow);				

endmodule