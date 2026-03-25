///////////////////////////////////////
// hook_draw_req					       //
// Noa Malul & Idan Peassach 			 //	
// Gold Miner								 //
// Created: 6.12.25						 //
// Last Modified: 7.12.25				 //
///////////////////////////////////////

module hook_draw_req(
	input logic clk,
	input logic resetN,
	input logic[10:0] pixelX,
	input logic[10:0] pixelY,
	input logic[10:0] hookCenterX,
	input logic[10:0] hookCenterY,
	input logic[7:0] hookAlpha,
	input logic[10:0] hookRadius,
	
	output logic[10:0] Xend,
	output logic[10:0] Yend,
	output logic [7:0] HOOK_RGB,
	output logic hookDrawingRequest
	
	); 

	

localparam logic [11:0] sinout1024[91] = '{
    12'h000, 12'h012, 12'h024, 12'h036, 12'h047, 12'h059, 12'h06B, 12'h07D,
    12'h08F, 12'h0A0, 12'h0B2, 12'h0C3, 12'h0D5, 12'h0E6, 12'h0F8, 12'h109,
    12'h11A, 12'h12B, 12'h13C, 12'h14D, 12'h15E, 12'h16F, 12'h180, 12'h190,
    12'h1A0, 12'h1B1, 12'h1C1, 12'h1D1, 12'h1E1, 12'h1F0, 12'h200, 12'h20F,
    12'h21F, 12'h22E, 12'h23D, 12'h24B, 12'h25A, 12'h268, 12'h276, 12'h284,
    12'h292, 12'h2A0, 12'h2AD, 12'h2BA, 12'h2C7, 12'h2D4, 12'h2E1, 12'h2ED,
    12'h2F9, 12'h305, 12'h310, 12'h31C, 12'h327, 12'h332, 12'h33C, 12'h347,
    12'h351, 12'h35B, 12'h364, 12'h36E, 12'h377, 12'h380, 12'h388, 12'h390,
    12'h398, 12'h3A0, 12'h3A7, 12'h3AF, 12'h3B5, 12'h3BC, 12'h3C2, 12'h3C8,
    12'h3CE, 12'h3D3, 12'h3D8, 12'h3DD, 12'h3E2, 12'h3E6, 12'h3EA, 12'h3ED,
    12'h3F0, 12'h3F3, 12'h3F6, 12'h3F8, 12'h3FA, 12'h3FC, 12'h3FE, 12'h3FF,
    12'h3FF, 12'h400, 12'h400
};
localparam logic [11:0] cosout1024[91] = '{
    12'h400, 12'h400, 12'h3FF, 12'h3FF, 12'h3FE, 12'h3FC, 12'h3FA, 12'h3F8,
    12'h3F6, 12'h3F3, 12'h3F0, 12'h3ED, 12'h3EA, 12'h3E6, 12'h3E2, 12'h3DD,
    12'h3D8, 12'h3D3, 12'h3CE, 12'h3C8, 12'h3C2, 12'h3BC, 12'h3B5, 12'h3AF,
    12'h3A7, 12'h3A0, 12'h398, 12'h390, 12'h388, 12'h380, 12'h377, 12'h36E,
    12'h364, 12'h35B, 12'h351, 12'h347, 12'h33C, 12'h332, 12'h327, 12'h31C,
    12'h310, 12'h305, 12'h2F9, 12'h2ED, 12'h2E1, 12'h2D4, 12'h2C7, 12'h2BA,
    12'h2AD, 12'h2A0, 12'h292, 12'h284, 12'h276, 12'h268, 12'h25A, 12'h24B,
    12'h23D, 12'h22E, 12'h21F, 12'h20F, 12'h200, 12'h1F0, 12'h1E1, 12'h1D1,
    12'h1C1, 12'h1B1, 12'h1A0, 12'h190, 12'h180, 12'h16F, 12'h15E, 12'h14D,
    12'h13C, 12'h12B, 12'h11A, 12'h109, 12'h0F8, 12'h0E6, 12'h0D5, 12'h0C3,
    12'h0B2, 12'h0A0, 12'h08F, 12'h07D, 12'h06B, 12'h059, 12'h047, 12'h036,
    12'h024, 12'h012, 12'h000
};
parameter int eps_tag = 2;

logic signed[11:0] eps;
logic signed[31:0] a;
logic signed[31:0] b;
logic [10:0] Xtemp;
logic [10:0] Ytemp;
logic [31:0] Xmove;
logic [31:0] Ymove;
logic inSegment;
logic signed[10:0] cy; 

always_comb begin
    if (hookAlpha > 0 && hookAlpha <= 90) begin
        Xmove = (hookRadius * cosout1024[hookAlpha]) >> 10;
        Ymove = (hookRadius * sinout1024[hookAlpha]) >> 10;
    end
    else begin
        Xmove = (hookRadius * cosout1024[180 - hookAlpha]) >> 10;
        Ymove = (hookRadius * sinout1024[180 - hookAlpha]) >> 10;
    end
end
	
	
	assign Xtemp = (hookAlpha > 0 && hookAlpha <= 90) ? hookCenterX + Xmove :  hookCenterX - Xmove;
	assign Ytemp =  hookCenterY + Ymove;
	
	assign Xend = Xtemp;
	assign Yend = Ytemp;
	
	assign eps  =  eps_tag; 
	assign a    = (pixelY - hookCenterY)*(Xtemp - hookCenterX);
	assign bpos    = (Ytemp - hookCenterY)*(pixelX - hookCenterX - eps);
	assign bneg    = (Ytemp - hookCenterY)*(pixelX - hookCenterX + eps);
	assign inSegmentY = (pixelY >= hookCenterY && pixelY <= Yend); 
 
	assign cy = Ytemp - hookCenterY;
	assign inSegmentX = (((a + (cy*(hookCenterX - eps))) < cy*pixelX) && (cy*pixelX < (a + (cy*(hookCenterX + eps)))));

	
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		HOOK_RGB <=	8'b0;
		hookDrawingRequest<=	1'b0;
	end
	
	else begin
			HOOK_RGB <= 8'b11001100 ; 
			hookDrawingRequest <= (inSegmentX && inSegmentY) ;
		
	end
	
end
endmodule
