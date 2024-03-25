// +FHDR----------------------------------------------------------------------------
// Copyright (c) 2022 Cygnusemi.
// ALL RIGHTS RESERVED Worldwide
//         
// Author        : zhanglin
// Email         : linn_zh@cygnusemi.com
// Created On    : 2022/08/01 15:11
// Last Modified : 2023/08/29 11:51
// File Name     : pulse_sync_h2s.v
// Description   :
//   pulse_sync_h2s module supports configurable parameters;
//   The signal is transmitted from the fast clock domain to the slow clock domain;
//   expand the signal;
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2022/08/01   zhanglin        1.0                     Original
// -FHDR----------------------------------------------------------------------------

module pulse_sync_h2s 
#(
parameter DELAY_2 = 1
)    
( 
    src_clk         , //source clock  
    src_rst_n       , //source clock reset (0: reset) 
    src_pulse       , //source clock pulse in 
    dst_clk         , //destination clock  
    dst_rst_n       , //destination clock reset (0:reset) 
    dst_pulse       //destination pulse out 
); 
input        src_clk           ; //source clock  
input        src_rst_n         ; //source clock reset (0: reset) 
input        src_pulse         ; //source clock pulse in 

input        dst_clk           ; //destination clock  
input        dst_rst_n         ; //destination clock reset (0:reset) 

//OUTPUT DECLARATION 
output       dst_pulse         ; //destination pulse out 

reg          ext_pulse_src     ;
wire         ext_pulse_dst     ;
reg [1 : 0]  ext_pulse_src_dst ;
reg [1 :0]   pos_pulse_dst     ;  

//src_clk woden  src_pulse signal    
always @(posedge src_clk or negedge src_rst_n) begin
    if(!src_rst_n) 
        ext_pulse_src <= 1'b0;
    else if(src_pulse) 
        ext_pulse_src <= 1'b1;
    else if(ext_pulse_src_dst[1]) 
        ext_pulse_src <= 1'b0;
    else 
        ext_pulse_src <= ext_pulse_src;  
end

// ext_pulse_src signal synchronizes to dst_clk

sync #(
    .D_WIDTH      ( 1       ),
    .DELAY_2      ( DELAY_2 ),
    .DATA_DEFAULT ( 0       )
) u_sync(
    .clk_d   ( dst_clk       ),
    .rst_d_n ( dst_rst_n     ),
    .data_s  ( ext_pulse_src ),
    .data_d  ( ext_pulse_dst )
);       
    
//always @(posedge dst_clk or negedge dst_rst_n) begin
//    if(!dst_rst_n) 
//        ext_pulse_dst <= 2'b0;
//    else 
//        ext_pulse_dst <= {ext_pulse_dst[0],ext_pulse_src};
//end

//ext_pulse_dst signal synchronizes to src_clk
always @(posedge src_clk or negedge src_rst_n) begin
    if(!src_rst_n)
        ext_pulse_src_dst <= 2'b0;   
    else
        ext_pulse_src_dst <= {ext_pulse_src_dst[0],ext_pulse_dst};
end

//Check the rising edge of signal ext_pulse_dst 
always @(posedge dst_clk or negedge dst_rst_n) begin
    if(!dst_rst_n) 
        pos_pulse_dst <= 2'b0;
    else
        pos_pulse_dst <= {pos_pulse_dst[0],ext_pulse_dst};
end
   

assign dst_pulse = pos_pulse_dst[0] & (~pos_pulse_dst[1]); 

endmodule
