//
// (c) Technion IIT, The Faculty of Electrical and Computer Engineering, 2025
//
//
//  PRELIMINARY VERSION  -  06 April 2025
//


module JukeBox1

    (
    // Declare wires and regs :
 
 input logic [3:0] melodySelect ,     // selector of one melody  
 input logic [4:0] noteIndex,         // serial number of current note. ( maximum 31 ). noteIndex determines freqIndex and note_length, via JueBox
 
 output logic [3:0] tone,        // index to toneDecoder
 output logic [3:0] note_length,      // length of notes, in beats
 output logic silenceOutN ) ;         //  a silence note: disable sound
 

 localparam MaxMelodyLength = 6'h32;  // maximum melody length, in notes. 
 
 localparam GOLD = 4'b1;
 localparam ROCK = 4'd2;


// ************** frequencies: *************************************************************************************************
    typedef enum logic [3:0] {do_, doD, re, reD, mi, fa, faD, sol, solD, la, laD, si, do_H, doDH, re_H, silence } musicNote ;//*
//              Hex value:     0    1    2   3   4    5   6    7     8    9   A   B    C      D    E      F                  //*
// *****************************************************************************************************************************
      
   // type of frequency is musicNote   (enum)  
   // Frequency index is 0....15   
   // length is in beats ( 1 to 15 )
   // length = 0 means end of melody		

musicNote frq[(MaxMelodyLength-1'b1):0]  ;     // frq is the array of frequency indices of the melody. it includes up to 32 notes.  
logic [3:0] len[(MaxMelodyLength-1'b1):0] ;   // len is the array of note lengths , in terms of beats. it includes up to 32 notes.		

assign silenceOutN = !( tone == silence ) ; // disable sound if note is "silence"	 
	 
	 
	 
always_comb begin	 
    frq = '{default: 0};
	 len = '{default: 0};
	 
	 case (melodySelect)
		GOLD: begin // getting gold
//			frq[0]  = sol ;     len[0]  = 7 ;
//			frq[1]  = la  ;     len[1]  = 7 ;
//			frq[2]  = do_H;     len[2]  = 7 ;
//			frq[3]  = silence;  len[3]  = 0 ;
// Sheet Music of melody: SFX - COIN COLLECT (Bling!)
		// Rhythm: Very fast transition (Low -> High)
		// Notes:  A -> High D (Perfect 4th interval to match the original feel)
		//**********************************
			 
			 // The initial "Bl-"
			 frq[0]  =  la ;      len[0]  = 1 ;    // A (Short entry)
			 
			 // The ring "-ing!"
			 frq[1]  =  re_H ;    len[1]  = 4 ;    // High D (Sustain slightly)
			 
			 // Cutoff
 			 frq[2] = do_ ;       len[2] = 0 ;     // End of melody
		end
		
		ROCK: begin // getting rock
//			frq[0]  = mi ;      len[0]  = 7 ;
//			frq[1]  = re ;      len[1]  = 7 ;
//			frq[2]  = do_;      len[2]  = 7 ;
//			frq[3]  = silence;  len[3]  = 0 ;
			frq[0]  =  fa  ;       len[0]  = 2  ;   
	 		frq[1] =   do_ ;       len[1]  = 0 ;    // length = 0 means end of melody
		end
		
		default: begin
			frq[0] = silence; len[0] = 0 ;
			//**********************************************************************
			// Sheet Music of song:  PIRATES OF THE CARIBBEAN (He's a Pirate)
			// Simplified version – up to 32 notes
			//**********************************************************************

//         frq[0]  = mi ;     len[0]  = 2 ;
//         frq[1]  = sol;     len[1]  = 2 ;
//         frq[2]  = la ;     len[2]  = 2 ;
//         frq[3]  = la ;     len[3]  = 4 ;
//
//         frq[4]  = la ;     len[4]  = 2 ;
//         frq[5]  = si ;     len[5]  = 2 ;
//         frq[6]  = do_H;     len[6]  = 2 ;
//         frq[7]  = do_H;     len[7]  = 4 ;
//
//         frq[8]  = do_H;     len[8]  = 2 ;
//         frq[9]  = re_H;     len[9]  = 2 ;
//         frq[10] = si ;     len[10] = 2 ;
//         frq[11] = la ;     len[11] = 4 ;
//
//         frq[12] = sol;     len[12] = 2 ;
//         frq[13] = mi ;     len[13] = 2 ;
//         frq[14] = sol;     len[14] = 4 ;
//
//         frq[15] = la ;     len[15] = 2 ;
//         frq[16] = si ;     len[16] = 2 ;
//         frq[17] = do_H;     len[17] = 4 ;
//
//         frq[18] = mi ;     len[18] = 2 ;
//         frq[19] = sol;     len[19] = 2 ;
//         frq[20] = la ;     len[20] = 2 ;
//         frq[21] = la ;     len[21] = 4 ;
//
//         frq[22] = la ;     len[22] = 2 ;
//         frq[23] = si ;     len[23] = 2 ;
//         frq[24] = do_H;     len[24] = 2 ;
//         frq[25] = do_H;     len[25] = 4 ;
//
//         frq[26] = re_H;     len[26] = 2 ;
//         frq[27] = re_H;     len[27] = 2 ;
//         frq[28] = re_H;     len[28] = 2 ;
//         frq[29] = do_H;     len[29] = 4 ;
//
//         frq[30] = si ;     len[30] = 2 ;
//
//         frq[31] = silence;     len[31] = 0 ;   // end of melody

		end // case
	endcase
end // always 
 
//***********************************************************************
//     Extract outputs of specific note from sheet music :                                                        *
//***********************************************************************

assign tone   = frq[noteIndex] ;
assign note_length = len[noteIndex] ; 

 
 
endmodule