///////////////////////////////////////
// object lifting    			       //
// Noa Malul & Idan Peassach 			 //	
// Gold Miner								 //
// Created: 6.12.25						 //
// Last Modified: 7.12.25				 //
///////////////////////////////////////

module objectLifting (
	input		logic				clk,
	input		logic				resetN,
	input		logic 			hook_retrieved,
	input 	logic [2:0]		collision_id,
	input		logic	[10:0]	offsetX,
	input 	logic [10:0]	offsetY,
	input		logic				insideRectangle,
	
	output	logic [7:0]		liftedObj_RGB,
	output	logic 			liftedObj_drawingReq
);

//---------------------------------------------------------------------------------
// ROM INSTANTIATION FOR MIF FILES
localparam int ROM_ADDR_W = 10;
localparam int OBJ_W = 32;

logic [ROM_ADDR_W-1:0] rom_addr;
logic [7:0] gold_q;
logic [7:0] rock_q;
logic [7:0] purp_diamond_q;
logic [7:0] dynamite_q;
logic [7:0] clock_q;

assign rom_addr = offsetY * OBJ_W + offsetX;

// GOLD MIF
lpm_rom #(
    .LPM_WIDTH      (8),
    .LPM_WIDTHAD    (ROM_ADDR_W),
    .LPM_NUMWORDS   (1024),
    .LPM_ADDRESS_CONTROL("REGISTERED"),
    .LPM_OUTDATA    ("REGISTERED"),
    .LPM_FILE       ("RTL/VGA/gold_icon_MIF.mif"),
    .DEVICE_FAMILY  ("Cyclone V")
) gold_rom (
    .address (rom_addr),
    .inclock (clk),
    .outclock(clk),
    .memenab (1'b1),
    .q       (gold_q)
);

// ROCK MIF
lpm_rom #(
    .LPM_WIDTH      (8),
    .LPM_WIDTHAD    (ROM_ADDR_W),
    .LPM_NUMWORDS   (1024),
    .LPM_ADDRESS_CONTROL("REGISTERED"),
    .LPM_OUTDATA    ("REGISTERED"),
    .LPM_FILE       ("RTL/VGA/rock_icon_MIF.mif"),
    .DEVICE_FAMILY  ("Cyclone V")
) rock_rom (
    .address (rom_addr),
    .inclock (clk),
    .outclock(clk),
    .memenab (1'b1),
    .q       (rock_q)
);

// PURPLE DIAMOND MIF
lpm_rom #(
    .LPM_WIDTH      (8),
    .LPM_WIDTHAD    (ROM_ADDR_W),
    .LPM_NUMWORDS   (1024),
    .LPM_ADDRESS_CONTROL("REGISTERED"),
    .LPM_OUTDATA    ("REGISTERED"),
    .LPM_FILE       ("RTL/VGA/purpleDiamond_MIF.mif"),
    .DEVICE_FAMILY  ("Cyclone V")
) purp_diamond_rom (
    .address (rom_addr),
    .inclock (clk),
    .outclock(clk),
    .memenab (1'b1),
    .q       (purp_diamond_q)
);

// DYNAMITE MIF
lpm_rom #(
    .LPM_WIDTH      (8),
    .LPM_WIDTHAD    (ROM_ADDR_W),
    .LPM_NUMWORDS   (1024),
    .LPM_ADDRESS_CONTROL("REGISTERED"),
    .LPM_OUTDATA    ("REGISTERED"),
    .LPM_FILE       ("RTL/VGA/dynamite_icon_MIF.mif"),
    .DEVICE_FAMILY  ("Cyclone V")
) dynamite_rom (
    .address (rom_addr),
    .inclock (clk),
    .outclock(clk),
    .memenab (1'b1),
    .q       (dynamite_q)
);

// CLOCK MIF
lpm_rom #(
    .LPM_WIDTH      (8),
    .LPM_WIDTHAD    (ROM_ADDR_W),
    .LPM_NUMWORDS   (1024),
    .LPM_ADDRESS_CONTROL("REGISTERED"),
    .LPM_OUTDATA    ("REGISTERED"),
    .LPM_FILE       ("RTL/VGA/clock_icon_MIF.mif"),
    .DEVICE_FAMILY  ("Cyclone V")
) clock_rom (
    .address (rom_addr),
    .inclock (clk),
    .outclock(clk),
    .memenab (1'b1),
    .q       (clock_q)
);
//---------------------------------------------------------------------------------

localparam GOLD = 3'b1;
localparam ROCK = 3'd2;
localparam PURPLE_DIAMOND = 3'd3;
localparam DYNAMITE = 3'd4;
localparam CLOCK = 3'd5;

//---------------------------------------------------------------------------------

always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		liftedObj_RGB <= 7'b0;
		liftedObj_drawingReq <= 1'b0;
	end
	
	else begin
		liftedObj_drawingReq <= 1'b0;
		if (insideRectangle && !hook_retrieved) begin
			case (collision_id)
				GOLD: begin
					if (gold_q != 8'b0) begin
						liftedObj_drawingReq <= 1'b1;
						liftedObj_RGB <= gold_q;
					end
				end
				ROCK: begin
					if (rock_q != 8'b0) begin
						liftedObj_drawingReq <= 1'b1;
						liftedObj_RGB <= rock_q;
					end
				end
				PURPLE_DIAMOND: begin
					if (purp_diamond_q != 8'b0) begin
						liftedObj_drawingReq <= 1'b1;
						liftedObj_RGB <= purp_diamond_q;
					end
				end
				DYNAMITE: begin
					if (dynamite_q != 8'h00) begin
						liftedObj_drawingReq <= 1'b1;
						liftedObj_RGB <= dynamite_q;
					end
				end
				CLOCK: begin
					if (clock_q != 8'b0) begin
						liftedObj_drawingReq <= 1'b1;
						liftedObj_RGB <= clock_q;
					end
				end
				default: begin
					liftedObj_RGB <= 8'hFF;
				end
			endcase	
		end	
	end
end
endmodule