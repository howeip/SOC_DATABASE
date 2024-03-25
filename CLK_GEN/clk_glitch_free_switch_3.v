// +FHDR----------------------------------------------------------------------------
// Copyright (c) 2022 Cygnusemi.
// ALL RIGHTS RESERVED Worldwide
//         
// Author        : zhanglin
// Email         : linn_zh@cygnusemi.com
// Created On    : 2022/08/01 14:57
// Last Modified : 2023/11/14 09:58
// File Name     : clk_glitch_free_switch_3.v
// Description   :
//   clk_glitch_free_switch_3 module support 3 to 1;
//   alone hot code; 3'b001 - clk0; 3'b010 - clk1; 3`b100 - clk2
//  
//  sel[2] sel[1] sel[0]
//     |    |        |       _________    _________   
//     |    |        |       |       |    |       | 
//     |    |        i-------|D     Q|----|D     Q|---i
//     |    |                |       |    |       |   | 
//     |    |                |  CLK  |    |  CLK  |   |
//     |    |                |___/\__|    |___/\__|   |
//     |    |     ________________|____________|      |
//     |    |    i                                    |
//     |    |    |           _________    _________   |
//     |    |    |           |       |    |       |   |
//     |    |    |    i------|D     Q|----|D     Q|   |      ______       _________
//CLK0-|----|----i    |      |       |    |       |   i-----|      )      |       |
//     |    |    |    |      |  CLK  |    |CLK  Qn|---------|  &    )-----|D     Q|----i--------------------i
//     |    |    |    |      |___/\__|    |___/\__|    i----|______)      |       |    |                    |
//     |    |    |____|___________|____________|       |                  |  CLK  |    |                    |
//     |    |    |    |                                |                  |___/\__|    |                    |    ______    
//     |    |    |    |                                |                       |       |                    i---|      ) 
//     |    |    |    |      _________    _________    |                       |       |  _________             | ICG   )-------i
//     |    |    |    |      |       |    |       |    |                       |       |  |       |         i---|______)        |
//     |    |    | i--|------|D     Q|----|D     Q|    |                       |       i--|D     Q|---i     |                   |
//     |    |    | |  |      |       |    |       |    |                       |          |       |   |     |                   |
//     |    |    | |  |      |  CLK  |    |CLK  Qn|----i                       |          |  CLK  |   |     |                   |
//     |    |    | |  |      |___/\__|    |___/\__|                            |          |___/\__|   |     |                   |
//     |    |    i_|__|___________|____________|_______________________________|_______________|______|_____|                   |
//     |    |      |  | ______________________________________________________________________________|                         |                                            
//     |    |      |  i_i__i___________________________________________________________________________                         |
//     |    |      |  | |  |                                                                          |                         |
//     |    |      |  | |  | _________    _________                                                   |                         |
//     |    |      |  | |  | |       |    |       |                                                   |                         |
//     |    i------|--|-|--|-|D     Q|----|D     Q|---i                                               |                         |
//     |           |  | |  | |       |    |       |   |                                               |                         |
//     |           |  | |  | |  CLK  |    |  CLK  |   |                                               |                         |
//     |           |  | |  | |___/\__|    |___/\__|   |                                               |                         |
//     |          _|__|_|__|______|____________|      |                                               |                         |
//     |         i |  | |  |                          |                                               |                         |
//     |         | |  | |  | _________    _________   |                                               |                         |     
//     |         | |  | |  | |       |    |       |   |                                               |                         |
//     |         | |  | |  i-|D     Q|----|D     Q|   |      ______       _________                   |                         |
//CLK1-|---------i |  | |    |       |    |       |   i-----|      )      |       |                   |                         |
//     |         | |  | |    |  CLK  |    |CLK  Qn|---------|  &    )-----|D     Q|----i--------------|-----i                   |
//     |         | |  | |    |___/\__|    |___/\__|    i----|______)      |       |    |              |     |                   |
//     |         i_|__|_|_________|____________|       |                  |  CLK  |    |              |     |                   |
//     |         | |  | |                              |                  |___/\__|    |              |     |    ______         |   ______    
//     |         | |  | |                              |                       |       |              |     i---|      )        i--)      ) 
//     |         | |  | |    _________    _________    |                       |       |  _________   |         | ICG   )-----------) ||   )
//     |         | |  | |    |       |    |       |    |                       |       |  |       |   |     i---|______)        i--)______) 
//     |         | i--|-|----|D     Q|----|D     Q|    |                       |       i--|D     Q|---i     |                   |
//     |         | |  | |    |       |    |       |    |                       |          |       |         |                   |
//     |         | |  | |    |  CLK  |    |CLK  Qn|----i                       |          |  CLK  |         |                   |
//     |         | |  | |    |___/\__|    |___/\__|                            |          |___/\__|         |                   |
//     |         i_|__|_|_________|____________|_______________________________|_______________|____________|                   |
//     |           |  | |                                                                                                       |
//     |           |  | |                                                                                                       |
//     |           |  | |                                                                                                       |
//     |           i__|_|______________________________________________________________________________                         |
//     |              | |                                                                             |                         |
//     |              | |    _________    _________                                                   |                         |
//     |              | |    |       |    |       |                                                   |                         |
//     i--------------|-|----|D     Q|----|D     Q|---i                                               |                         |
//                    | |    |       |    |       |   |                                               |                         |
//                    | |    |  CLK  |    |  CLK  |   |                                               |                         |
//                    | |    |___/\__|    |___/\__|   |                                               |                         |
//                ____|_|_________|____________|      |                                               |                         |
//               i    | |                             |                                               |                         |
//               |    | |    _________    _________   |                                               |                         |
//               |    | |    |       |    |       |   |                                               |                         |
//               |    | i----|D     Q|----|D     Q|   |      ______       _________                   |                         |
//CLK2- ---------i    |      |       |    |       |   i-----|      )      |       |                   |                         |
//               |    |      |  CLK  |    |CLK  Qn|---------|  &    )-----|D     Q|----i--------------|-----i                   |
//               |    |      |___/\__|    |___/\__|    -----|______)      |       |    |              |     |                   |
//               i____|___________|____________|       |                  |  CLK  |    |              |     |                   |
//               |    |                                |                  |___/\__|    |              |     |    ______         |
//               |    |                                |                       |       |              |     i---|      )        |
//               |    |      _________    _________    |                       |       |  _________   |         | ICG   )-------i
//               |    |      |       |    |       |    |                       |       |  |       |   |     i---|______)   
//               |    i------|D     Q|----|D     Q|    |                       |       i--|D     Q|---i     |              
//               |           |       |    |       |    |                       |          |       |         |  
//               |           |  CLK  |    |CLK  Qn|----i                       |          |  CLK  |         |
//               |           |___/\__|    |___/\__|                            |          |___/\__|         | 
//               i________________|____________|_______________________________|_______________|____________|
//                                                                                         
//                             
// ----------------------------------------------------------------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2022/08/01   zhanglin        1.0                     Original
// -FHDR----------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------------------------------------------------
`ifdef  NO_ASIC
`else
	`include "std_cell_def.h"
`endif
module clk_glitch_free_switch_3(
    input       se       ,
    input [2:0] sel      ,  // alone hot code; 3'b001 - clk0; 3'b010 - clk1; 3`b100 - clk2; 
    input       clk0     ,
    input       clk1     , 
    input       clk2     , 
    input       rst_n    , 
    output      clk_out  ,
    output      clk0_sel ,
    output      clk1_sel ,
    output      clk2_sel ,
    output      sel_done     
); 

/**************************************************/ 
reg  sel0_d1           ;
reg  sel0_d2           ;
reg  clk0_on           ;
reg  clk0_on_d         ;   
reg  clk10_on_d1       ;
reg  clk10_on_d2       ;
reg  clk12_on_d1       ;
reg  clk12_on_d2       ;


reg  sel1_d1           ;
reg  sel1_d2           ;
reg  clk1_on           ;
reg  clk1_on_d         ;    
reg  clk01_on_d1       ;
reg  clk01_on_d2       ;
reg  clk02_on_d1       ;
reg  clk02_on_d2       ;


reg  sel2_d1           ;
reg  sel2_d2           ;
reg  clk2_on           ;
reg  clk2_on_d         ;   
reg  clk20_on_d1       ;
reg  clk20_on_d2       ;
reg  clk21_on_d1       ;
reg  clk21_on_d2       ;

wire clk0_out          ;
wire clk1_out          ;
wire clk2_out          ;

/**************************************************/ 
always@(posedge clk0 or negedge rst_n) begin 
    if(!rst_n)begin 
        sel0_d1 <= 1'd0;
        sel0_d2 <= 1'd0; 
    end 
    else begin 
        sel0_d1 <= sel[0] ;
        sel0_d2 <= sel0_d1; 
    end    
end 

always@(posedge clk0 or negedge rst_n) begin 
    if(!rst_n)begin 
        clk01_on_d1 <= 1'd0;
        clk01_on_d2 <= 1'd0; 
    end 
    else begin
        clk01_on_d1 <= clk1_on_d   ;
        clk01_on_d2 <= clk01_on_d1 ;
    end    
end 

always@(posedge clk0 or negedge rst_n) begin 
    if(!rst_n)begin 
        clk02_on_d1 <= 1'd0;
        clk02_on_d2 <= 1'd0; 
    end 
    else begin
        clk02_on_d1 <= clk2_on_d   ;
        clk02_on_d2 <= clk02_on_d1 ; 
    end    
end 

always@(posedge clk0 or negedge rst_n) begin 
    if(!rst_n)
        clk0_on <= 1'd0; 
    else 
        clk0_on <= sel0_d2 & (~clk01_on_d2) & (~clk02_on_d2);
end 
 
always@(posedge clk0 or negedge rst_n) begin 
    if(!rst_n)
        clk0_on_d <= 1'd0;
    else 
        clk0_on_d <= clk0_on;
end 


icg icg_u0(
    .clkin  ( clk0    ),
    .enable ( clk0_on ),
    .se     ( se      ),
    .clkout (clk0_out )
);

/**************************************************/ 

always@(posedge clk1 or negedge rst_n) begin 
    if(!rst_n)begin 
        sel1_d1 <= 1'd0;
        sel1_d2 <= 1'd0; 
    end 
    else begin 
        sel1_d1 <= sel[1] ;
        sel1_d2 <= sel1_d1; 
    end    
end 

always@(posedge clk1 or negedge rst_n) begin 
    if(!rst_n)begin 
        clk10_on_d1 <= 1'd0;
        clk10_on_d2 <= 1'd0; 
    end 
    else begin 
        clk10_on_d1 <= clk0_on_d   ;
        clk10_on_d2 <= clk10_on_d1 ;
    end    
end 

always@(posedge clk1 or negedge rst_n) begin 
    if(!rst_n)begin 
        clk12_on_d1 <= 1'd0;
        clk12_on_d2 <= 1'd0; 
    end 
    else begin
        clk12_on_d1 <= clk2_on_d   ;
        clk12_on_d2 <= clk12_on_d1 ; 
    end    
end 

always@(posedge clk1 or negedge rst_n) begin 
    if(!rst_n)
        clk1_on <= 1'd0;
    else 
        clk1_on <= sel1_d2 & (~clk10_on_d2) & (~clk12_on_d2);
end 
 
always@(posedge clk1 or negedge rst_n) begin 
    if(!rst_n)
        clk1_on_d <= 1'd0;
    else 
        clk1_on_d <= clk1_on;
end 

icg icg_u1(
    .clkin  ( clk1    ),
    .enable ( clk1_on ),
    .se     ( se      ),
    .clkout (clk1_out )
);

/**************************************************/ 

always@(posedge clk2 or negedge rst_n) begin 
    if(!rst_n) begin 
        sel2_d1 <= 1'd0;
        sel2_d2 <= 1'd0; 
    end 
    else begin
        sel2_d1 <= sel[2] ;
        sel2_d2 <= sel2_d1; 
    end    
end 

always@(posedge clk2 or negedge rst_n) begin 
    if(!rst_n) begin 
        clk20_on_d1 <= 1'd0;
        clk20_on_d2 <= 1'd0; 
    end 
    else begin
        clk20_on_d1 <= clk0_on_d   ;
        clk20_on_d2 <= clk20_on_d1 ; 
    end    
end 

always@(posedge clk2 or negedge rst_n) begin 
    if(!rst_n) begin 
        clk21_on_d1 <= 1'd0;
        clk21_on_d2 <= 1'd0; 
    end 
    else begin
        clk21_on_d1 <= clk1_on_d   ;
        clk21_on_d2 <= clk21_on_d1 ; 
    end    
end 

always@(posedge clk2 or negedge rst_n) begin 
    if(!rst_n) 
        clk2_on <= 1'd0;
    else 
        clk2_on <= sel2_d2 & (~clk20_on_d2) & (~clk21_on_d2);
end 
 
always@(posedge clk2 or negedge rst_n) begin 
    if(!rst_n) 
        clk2_on_d <= 1'd0;
    else 
        clk2_on_d <= clk2_on;
end 

icg icg_u2(
    .clkin  ( clk2    ),
    .enable ( clk2_on ),
    .se     ( se      ),
    .clkout (clk2_out )
);

`ifdef  NO_ASIC
assign  clk_out = clk0_out | clk1_out | clk2_out;
`else
  `ifdef EVEREST2  
   wire    clk01_out;    
    `STD_CLK_OR_CELL u0_clk_out(
        .A1     (clk0_out       ),
        .A2     (clk1_out       ),
        .Z      (clk01_out      )
    );

    `STD_CLK_OR_CELL u1_clk_out(
        .A1     (clk01_out      ),
        .A2     (clk2_out       ),
        .Z      (clk_out        )
    );
   `else
      `ifdef OLYMPUS2
       wire    clk01_out;    
         `STD_CLK_OR_CELL u0_clk_out(
            .A     (clk0_out       ),
            .B     (clk1_out       ),
            .Y     (clk01_out      )
         );

         `STD_CLK_OR_CELL u1_clk_out(
            .A     (clk01_out      ),
            .B     (clk2_out       ),
            .Y     (clk_out        )
          );
      `else
         `ifdef SKY
          wire    clk01_out;    
            `STD_CLK_OR_CELL u0_clk_out(
               .A1     (clk0_out       ),
               .A2     (clk1_out       ),
               .Z      (clk01_out      )
            );
   
            `STD_CLK_OR_CELL u1_clk_out(
               .A1     (clk01_out      ),
               .A2     (clk2_out       ),
               .Z      (clk_out        )
             );
        `endif
      `endif
   `endif   
`endif
    
assign clk0_sel = clk0_on_d & (sel == 3'b001);
assign clk1_sel = clk1_on_d & (sel == 3'b010);
assign clk2_sel = clk2_on_d & (sel == 3'b100);

assign sel_done = clk0_sel | clk1_sel | clk2_sel;
  
endmodule
