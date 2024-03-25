// +FHDR----------------------------------------------------------------------------
// Copyright (c) 2022 Cygnusemi.
// ALL RIGHTS RESERVED Worldwide
//         
// Author        : zhanglin
// Email         : linn_zh@cygnusemi.com
// Created On    : 2022/08/01 14:55
// Last Modified : 2024/01/29 10:28
// File Name     : clk_glitch_free_switch.v
// Description   :
// 
//                                                                  ______________________
//                                                                  |                    |
//                   ______    _________    _________    _________  |  ________          |  
//   sel------------|      )   |       |    |       |    |       |  |  |       |         |
//       |          |  &    )--|D     Q|----|D     Q|----|D     Q|--i--|D     Q|         |  
//       |        i-|______)   |       |    |       |    |       |     |       |         |
//       |        |            |  CLK  |    |  CLK  |    |  CLK  |     | CLK Qn|-----    |
//       |        |            |___/\__|    |___/\__|    |___/\__|     |___/\__|    |    |
//       |        |                 |            |            |             |       |    |    ______      
//       |        |                 |            |            |             |       |    i---|      ) 
//       |        |                 |            |            |             |       |        | ICG   )----------i
//       |        |                 |            |            |             |       |    i---|______)           |
//       |        |   clk1----------i------------i------------i-------------i-------|----i                      |    
//     __|___   __|_________________________________________________________________|                           |                                        
//     \INV /   | |                                                                                             |    
//      \  /    | |                                                                                             |
//       \/     | |                                                                                             |  
//       |      | |_________________________________________________________________                            |                               
//       |      |                                                   ________________|_____                      |         ______  
//       |      |                                                   |               |     |                     i--------)      ) 
//       |      |  ______      _________    _________    _________  |  ________     |     |                               ) ||   )------------clk_out
//       |      i-|      )     |       |    |       |    |       |  |  |       |    |     |                     i--------)______) 
//       |        |  &    )----|D     Q|----|D     Q|----|D     Q|--i--|D     Q|    |     |                     |
//       i--------|______)     |       |    |       |    |       |     |       |    |     |                     |
//                             |   CLK |    |   CLK |    |   CLK |     | CLK Qn|-----     |                     |
//                             |___/\__|    |___/\__|    |___/\__|     |___/\__|          |                     |
//                                  |            |            |             |             |    ______           |
//                                  |            |            |             |             i---|      )          | 
//                                  |            |            |             |                 | ICG   )----------
//                                  |            |            |             |             i---|______) 
//                     clk0---------i------------i------------i-------------i-------------i                        
//      
// ----------------------------------------------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2022/08/01   zhanglin        1.0                     Original
// -FHDR----------------------------------------------------------------------------
`ifdef  NO_ASIC
`else
	`include "std_cell_def.h"
`endif

module clk_glitch_free_switch(
    input   se       ,
    input   sel      ,  //1 - clk1  0 - clk0 
    input   clk1     , 
    input   clk0     , 
    input   rst0_n   ,
    input   rst1_n   ,
    output  clk_out  ,
    output  clk0_sel ,
    output  clk1_sel ,
    output  sel_done
); 
 
/***************************************************/ 
reg         q1      ; 
reg         q2      ;
reg         q3      ;
reg         q4      ;
reg         q5      ; 
reg         q6      ;
reg         q7      ;
reg         q8      ; 
wire        clk0_out;
wire        clk1_out;
wire        sw0;
wire        sw1;

always@(posedge clk1 or negedge rst1_n) begin 
    if(!rst1_n) 
        q1 <= 1'b0; 
    else 
        q1 <= (~q8) & (sel); 
end 

/***************************/ 
always@(posedge clk1 or negedge rst1_n) begin 
    if(!rst1_n) 
        q2 <= 1'b0; 
    else 
        q2 <= q1; 
end 

always@(posedge clk1 or negedge rst1_n) begin 
    if(!rst1_n) 
        q3 <= 1'b0; 
    else 
        q3 <= q2; 
end 

always@(posedge clk1 or negedge rst1_n) begin 
    if(!rst1_n) 
        q4 <= 1'b0; 
    else 
        q4 <= q3; 
end 


 
/***************************************************/ 
 always@(posedge clk0 or negedge rst0_n) begin 
    if(!rst0_n) 
        q5 <= 1'b1; 
    else 
        q5 <= (~q4) & (~sel); 
end 
/***************************/ 
always@(posedge clk0 or negedge rst0_n) begin 
    if(!rst0_n)
        q6 <= 1'b1;  
    else 
        q6 <= q5; 
end 

/***************************/ 
always@(posedge clk0 or negedge rst0_n) begin 
    if(!rst0_n)
        q7 <= 1'b1;  
    else 
        q7 <= q6; 
end 

/***************************/ 
always@(posedge clk0 or negedge rst0_n) begin 
    if(!rst0_n)
        q8 <= 1'b1; 
    else 
        q8 <= q7; 
end 


/**************************************************/ 

assign sw1 = q3 | se;
assign sw0 = q7 & !se;

icg icg_u0(
    .clkin  ( clk0   ),
    .enable ( sw0    ),
    .se     ( sw0    ),
    .clkout (clk0_out)
);

icg icg_u1(
    .clkin  ( clk1   ),
    .enable ( sw1    ),
    .se     ( sw1    ),
    .clkout (clk1_out)
);

`ifdef  NO_ASIC
    assign clk_out = clk0_out | clk1_out; 
`else
  `ifdef EVEREST2     
    `STD_CLK_OR_CELL u_clk_out(
        .A1     (clk0_out       ),
        .A2     (clk1_out       ),
        .Z      (clk_out        )
    );
   `else
      `ifdef OLYMPUS2
         `STD_CLK_OR_CELL u_clk_out(
             .A     (clk0_out       ),
             .B     (clk1_out       ),
             .Y     (clk_out        )
         );
      `else   
         `ifdef SKY
            `STD_CLK_OR_CELL u_clk_out(
                .A1     (clk0_out       ),
                .A2     (clk1_out       ),
                .Z      (clk_out        )
            );
        `endif         
     `endif
   `endif      
`endif

assign clk0_sel = ~sel & q8;
assign clk1_sel =  sel & q4;

assign sel_done = ~((sel ^ q4) | (~sel ^ q8));
 
endmodule
