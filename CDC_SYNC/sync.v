// +FHDR----------------------------------------------------------------------------
// Copyright (c) 2023 Cygnusemi.
// ALL RIGHTS RESERVED Worldwide
//         
// Author        : ninghechuan
// Email         :  @cygnusemi.com
// Created On    : 2023/03/01 10:12
// Last Modified : 2023/08/03 14:37
// File Name     : sync.v
// Description   :
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2023/03/01   ninghechuan     1.0                     Original
// -FHDR----------------------------------------------------------------------------
module sync
#(
parameter D_WIDTH = 1,
parameter DELAY_2 = 1,
parameter [D_WIDTH-1:0] DATA_DEFAULT = {D_WIDTH{1'b0}}
)
(
    clk_d,
    rst_d_n,
    data_s,
    data_d
);


input                       clk_d       ;
input                       rst_d_n     ;
input   [D_WIDTH-1:0]       data_s      ;
output  [D_WIDTH-1:0]       data_d      ;

generate 
    if (DELAY_2 == 1) begin: DELAY_2_CLK  
       reg     [D_WIDTH-1:0]       data_s_d2   ;
       reg     [D_WIDTH-1:0]       data_s_d1   ;

       always @(posedge clk_d or negedge rst_d_n) begin
           if(!rst_d_n) begin
             data_s_d2 <= DATA_DEFAULT;
             data_s_d1 <= DATA_DEFAULT;
           end
           else begin 
             data_s_d2 <= data_s_d1;
             data_s_d1 <= data_s;
           end
       end
       assign data_d = data_s_d2;
    end    
    else begin: DELAY_3_CLK
       reg     [D_WIDTH-1:0]       data_s_d3   ;
       reg     [D_WIDTH-1:0]       data_s_d2   ;
       reg     [D_WIDTH-1:0]       data_s_d1   ;
        
       always @(posedge clk_d or negedge rst_d_n) begin
           if(!rst_d_n) begin
             data_s_d3 <= DATA_DEFAULT;
             data_s_d2 <= DATA_DEFAULT;
             data_s_d1 <= DATA_DEFAULT;
           end
           else begin 
             data_s_d3 <= data_s_d2;
             data_s_d2 <= data_s_d1;
             data_s_d1 <= data_s;
           end
       end       
       assign data_d = data_s_d3;
    end
endgenerate
endmodule
