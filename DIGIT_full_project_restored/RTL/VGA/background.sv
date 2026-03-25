module background (
    input  logic        clk,
    input  logic        resetN,
    input  logic [10:0] pixelX,
    input  logic [10:0] pixelY, 
    input  logic [2:0]  fsm_state,

    output logic [7:0]  screen_rgb,
	 output logic 			screen_dr
);


localparam int SCREEN_W = 640;
localparam int SCREEN_H = 480;

localparam int MIF_W = 256;
localparam int MIF_H = 256;
localparam int ROM_ADDR_W = 16;  

localparam logic [2:0] IDLE_ST = 0;
localparam logic [2:0] WINNING_ST = 4;
localparam logic [2:0] LOSING_ST = 5;

// Signals
logic [ROM_ADDR_W-1:0] rom_addr;
logic [7:0] win_q;
logic [7:0] lose_q;
logic [7:0] open_q;

logic [8:0] calcX;
logic [7:0] calcY;

// WINNING SCREEN
lpm_rom #(
    .LPM_WIDTH      (8),
    .LPM_WIDTHAD    (ROM_ADDR_W),
    .LPM_NUMWORDS   (MIF_W * MIF_H),
    .LPM_ADDRESS_CONTROL("REGISTERED"),
    .LPM_OUTDATA    ("REGISTERED"),
    .LPM_FILE       ("RTL/VGA/winning_screen_MIF.mif"),
    .DEVICE_FAMILY  ("Cyclone V")
) win_rom (
    .address (rom_addr),
    .inclock (clk),
    .outclock(clk),
    .memenab (1'b1),
    .q       (win_q)
);

// LOSING SCREEN
lpm_rom #(
    .LPM_WIDTH      (8),
    .LPM_WIDTHAD    (ROM_ADDR_W),
    .LPM_NUMWORDS   (MIF_W * MIF_H),
    .LPM_ADDRESS_CONTROL("REGISTERED"),
    .LPM_OUTDATA    ("REGISTERED"),
    .LPM_FILE       ("RTL/VGA/losing_screen_MIF.mif"),
    .DEVICE_FAMILY  ("Cyclone V")
) lose_rom (
    .address (rom_addr),
    .inclock (clk),
    .outclock(clk),
    .memenab (1'b1),
    .q       (lose_q)
);

// OPENING SCREEN
lpm_rom #(
    .LPM_WIDTH      (8),
    .LPM_WIDTHAD    (ROM_ADDR_W),
    .LPM_NUMWORDS   (MIF_W * MIF_H),
    .LPM_ADDRESS_CONTROL("REGISTERED"),
    .LPM_OUTDATA    ("REGISTERED"),
    .LPM_FILE       ("RTL/VGA/opening_screen_MIF.mif"),
    .DEVICE_FAMILY  ("Cyclone V")
) open_rom (
    .address (rom_addr),
    .inclock (clk),
    .outclock(clk),
    .memenab (1'b1),
    .q       (open_q)
);

always_comb begin
    calcX = (pixelX * MIF_W) / SCREEN_W;
    calcY = (pixelY * MIF_H) / SCREEN_H;
end


// ROM address generation
always_ff @(posedge clk) begin
    rom_addr <= calcY * MIF_W + calcX;
end


always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
        screen_rgb <= 8'b0;
		  screen_dr <= 1'b0;
    end
    else begin
		  screen_dr <= 1'b0;
		  screen_rgb <= 8'b0;
        if (fsm_state == WINNING_ST) begin
            screen_rgb <= win_q;
				screen_dr <= 1'b1;
		  end
		  else if (fsm_state == LOSING_ST) begin
            screen_rgb <= lose_q;
				screen_dr <= 1'b1;
		  end
		  else if (fsm_state == IDLE_ST) begin
				screen_rgb <= open_q;
				screen_dr <= 1'b1;
		  end
    end
end

endmodule
