///////////////////////////////////////
// object Drawing     			       //
// Noa Malul & Idan Peassach 			 //	
// Gold Miner								 //
// Created: 6.12.25						 //
// Last Modified: 7.12.25				 //
///////////////////////////////////////

module objectDrawing (
    input  logic        clk,
    input  logic        resetN,
    input  logic [10:0] pixelX,
    input  logic [10:0] pixelY,
    input  logic [7:0]  map_number,
	 input  logic [4:0]  gold_not_taken,
	 input  logic [4:0]  rock_not_taken,
	 input  logic [2:0]	purp_diamond_not_taken,
	 input  logic [3:0]	dynamite_not_taken,
	 input  logic			clock_not_taken,
	 input  logic [3:0]	level,

    output logic        goldDrawingRequest,
    output logic        rockDrawingRequest,
	 output logic        purpDiamondDrawingRequest,
	 output logic        dynamiteDrawingRequest,
	 output logic        clockDrawingRequest,
    output logic [7:0]  ObjectRGB,
	 output logic [3:0]	curr_object_idx
);

import GameMaps::*;

localparam int ROCKS_NUM = 5;
localparam int GOLDS_NUM = 5;
localparam int PURPLE_DIAMOND_NUM = 3;
localparam int DYNAMITE_NUM = 4;

localparam int OBJ_W = 32;
localparam int OBJ_H = 32;
localparam int ROM_ADDR_W = 10;

// ROM SIGNALS FOR MIF
logic [ROM_ADDR_W-1:0] rom_addr;
logic [7:0] gold_q;
logic [7:0] rock_q;
logic [7:0] purp_diamond_q;
logic [7:0] dynamite_q;
logic [7:0] clock_q;

logic hit_gold_d;
logic hit_rock_d;
logic hit_purp_diamond_d;
logic hit_dynamite_d;
logic hit_clock_d;


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

always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
        goldDrawingRequest <= 1'b0;
        rockDrawingRequest <= 1'b0;
		  purpDiamondDrawingRequest <= 1'b0;
		  clockDrawingRequest <= 1'b0;
        ObjectRGB          <= 8'hFF;
        rom_addr           <= 10'b0;
        hit_gold_d         <= 1'b0;
        hit_rock_d         <= 1'b0;
		  hit_clock_d        <= 1'b0;
		  hit_purp_diamond_d <= 1'b0;
		  hit_dynamite_d     <= 1'b0;
		  curr_object_idx		<= 1'b0;
    end
    else begin
        // defaults
        goldDrawingRequest <= 1'b0;
        rockDrawingRequest <= 1'b0;
		  purpDiamondDrawingRequest <= 1'b0;
		  dynamiteDrawingRequest <= 1'b0;
		  clockDrawingRequest <= 1'b0;
        ObjectRGB          <= 8'hFF;
        hit_gold_d         <= 1'b0;
        hit_rock_d         <= 1'b0;
		  hit_purp_diamond_d <= 1'b0;
		  hit_dynamite_d     <= 1'b0;
		  hit_clock_d        <= 1'b0;

        // Cheking if we should draw a gold
        for (int i = 0; i < GOLDS_NUM; i++) begin
            if (gold_not_taken[i] &&
					 pixelX >= gold_maps[map_number][0][i] &&
                pixelX <  gold_maps[map_number][0][i] + OBJ_W &&
                pixelY >= gold_maps[map_number][1][i] &&
                pixelY <  gold_maps[map_number][1][i] + OBJ_H)
            begin
                rom_addr   <= (pixelY - gold_maps[map_number][1][i]) * OBJ_W +
                              (pixelX - gold_maps[map_number][0][i]);
                hit_gold_d <= 1'b1;
					 curr_object_idx <= i;
                break;
            end
         end
			
		  // Cheking if we should draw a rock
		  for (int i = 0; i < ROCKS_NUM; i++) begin
				if (rock_not_taken[i] &&
					 pixelX >= rock_maps[map_number][0][i] &&
					 pixelX <  rock_maps[map_number][0][i] + OBJ_W &&
					 pixelY >= rock_maps[map_number][1][i] &&
					 pixelY <  rock_maps[map_number][1][i] + OBJ_H)
				begin
					 rom_addr   <= (pixelY - rock_maps[map_number][1][i]) * OBJ_W +
										(pixelX - rock_maps[map_number][0][i]);
					 hit_rock_d <= 1'b1;
					 curr_object_idx <= i;
					 break;
				end
		  end
		  
		  if(level > 1) begin
			  // Cheking if we should draw a purple diamnd
			  for (int i = 0; i < PURPLE_DIAMOND_NUM; i++) begin
					if (purp_diamond_not_taken[i] &&
						 pixelX >= purple_diamond_maps[map_number][0][i] &&
						 pixelX <  purple_diamond_maps[map_number][0][i] + OBJ_W &&
						 pixelY >= purple_diamond_maps[map_number][1][i] &&
						 pixelY <  purple_diamond_maps[map_number][1][i] + OBJ_H)
					begin
						 rom_addr   <= (pixelY - purple_diamond_maps[map_number][1][i]) * OBJ_W +
											(pixelX - purple_diamond_maps[map_number][0][i]);
						 hit_purp_diamond_d <= 1'b1;
						 curr_object_idx <= i;
						 break;
					end
				end
			end
			
			if (level > 2) begin
			  // Cheking if we should draw a dynamite
			  for (int i = 0; i < DYNAMITE_NUM; i++) begin
					if (dynamite_not_taken[i] &&
						 pixelX >= dynamite_maps[map_number][0][i] &&
						 pixelX <  dynamite_maps[map_number][0][i] + OBJ_W &&
						 pixelY >= dynamite_maps[map_number][1][i] &&
						 pixelY <  dynamite_maps[map_number][1][i] + OBJ_H)
					begin
						 rom_addr   <= (pixelY - dynamite_maps[map_number][1][i]) * OBJ_W +
											(pixelX - dynamite_maps[map_number][0][i]);
						 hit_dynamite_d <= 1'b1;
						 curr_object_idx <= i;
						 break;
					end
				end
				
				// Checking if we should draw a clock
				if(clock_not_taken &&
					(pixelX >= clock_maps[map_number][0]) &&
					(pixelX <  (clock_maps[map_number][0] + OBJ_W)) &&
					(pixelY >= clock_maps[map_number][1]) &&
					(pixelY <  (clock_maps[map_number][1] + OBJ_H))) begin
					rom_addr   <= (pixelY - clock_maps[map_number][1]) * OBJ_W +
									  (pixelX - clock_maps[map_number][0]);
				   hit_clock_d <= 1'b1;
				end
			end
			

        // updating outputs if we hit an object
        if (hit_gold_d && gold_q != 8'h00) begin
            ObjectRGB          <= gold_q;
            goldDrawingRequest <= 1'b1;
        end
        else if (hit_rock_d && rock_q != 8'h00) begin
            ObjectRGB          <= rock_q;
            rockDrawingRequest <= 1'b1;
        end
		  else if (hit_purp_diamond_d && purp_diamond_q != 8'h00) begin
            ObjectRGB          <= purp_diamond_q;
            purpDiamondDrawingRequest <= 1'b1;
        end
		  else if (hit_dynamite_d && dynamite_q != 8'h00) begin
            ObjectRGB          <= dynamite_q;
            dynamiteDrawingRequest <= 1'b1;
        end
		  else if (hit_clock_d && clock_q != 8'h00) begin
            ObjectRGB          <= clock_q;
            clockDrawingRequest <= 1'b1;
        end
    end
end

endmodule
