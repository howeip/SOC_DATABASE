// +FHDR----------------------------------------------------------------------------
// Copyright (c) 2022 Cygnusemi.
// ALL RIGHTS RESERVED Worldwide
//         
// Author        : zhanglin
// Email         : linn_zh@cygnusemi.com
// Created On    : 2022/08/01 14:59
// Last Modified : 2023/08/29 09:34
// File Name     : edge_detect.v
// Description   : edge_detect module supports rising edge, falling edge, double edge detection;
//                 level signal
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2022/08/01   zhanglin        1.0                     Original
// -FHDR----------------------------------------------------------------------------

module edge_detect(
    input  clk       ,
    input  signal_in ,
    input  rst_n     ,
    output pos_edge  ,
    output neg_edge  ,
    output both_edge
);

reg   [2:0] signal_in_d ;

always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        signal_in_d[2:0]  <= 3'b0;
    end
    else begin
        signal_in_d[2:0]  <= {signal_in_d[1:0],signal_in};
    end
end

assign pos_edge  = (!signal_in_d[2]) &   signal_in_d[1] ;
assign neg_edge  =   signal_in_d[2]  & (!signal_in_d[1]);
assign both_edge =   signal_in_d[2]  ^   signal_in_d[1] ;

endmodule
