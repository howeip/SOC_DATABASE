// +FHDR----------------------------------------------------------------------------
// Copyright (c) 2022 Cygnusemi.
// ALL RIGHTS RESERVED Worldwide
//         
// Author        : zhanglin
// Email         : linn_zh@cygnusemi.com
// Created On    : 2022/08/01 15:11
// Last Modified : 2023/09/05 14:03
// File Name     : pulse_sync.v
// Description   :
//   pulse_sync module supports high clock to slow clock and slow clock to high clock;
//   handshaking mechanism;
//   The handshake mechanism keeps the pulse intervals small;  
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2022/08/01   zhanglin        1.0                     Original
// -FHDR----------------------------------------------------------------------------

module pulse_sync 
#(
        parameter DELAY_2 = 1
)
( 
        src_clk         , //source clock  
        src_rst_n       , //source clock reset (0: reset) 
        src_pulse       , //source clock pulse in 
        src_sync_fail   , //source clock sync state: 1 clock pulse if sync fail. 
        dst_clk         , //destination clock  
        dst_rst_n       , //destination clock reset (0:reset) 
        dst_pulse       //destination pulse out 
); 
  
//PARA   DECLARATION 
 
 
//INPUT  DECLARATION 
input               src_clk     ; //source clock  
input               src_rst_n   ; //source clock reset (0: reset) 
input               src_pulse   ; //source clock pulse in 
 
input               dst_clk     ; //destination clock  
input               dst_rst_n   ; //destination clock reset (0:reset) 
 
//OUTPUT DECLARATION 
output              src_sync_fail   ; //source clock sync state: 1 clock pulse if sync fail. 
output              dst_pulse       ; //destination pulse out 
 
 
//INTER  DECLARATION 
wire                dst_pulse       ; 
wire                src_sync_idle   ; 
reg                 src_sync_fail   ; 
reg                 src_sync_req    ; 
wire                src_sync_ack    ; 
//reg                 ack_state_dly1  ; 
//reg                 ack_state_dly2  ; 
reg                 req_state_dly1  ; 
reg                 req_state_dly2  ; 
reg                 dst_req_state   ; 
reg                 dst_sync_ack    ; 
 
//--========================MODULE SOURCE CODE==========================-- 
 
 
//--=========================================-- 
// DST Clock : 
// 1. generate src_sync_fail;  
// 2. generate sync req  
// 3. sync dst_sync_ack 
//--=========================================-- 
assign src_sync_idle = ~(src_sync_req | src_sync_ack ); 
 
//report an error if src_pulse when sync busy ; 
always @(posedge src_clk or negedge src_rst_n) 
begin 
    if(src_rst_n == 1'b0) 
        src_sync_fail   <= 1'b0 ; 
    else if (src_pulse & (~src_sync_idle))  
        src_sync_fail   <= 1'b1 ; 
    else  
        src_sync_fail   <= 1'b0 ; 
end 
 
//set sync req if src_pulse when sync idle ; 
always @(posedge src_clk or negedge src_rst_n) 
begin 
    if(src_rst_n == 1'b0) 
        src_sync_req    <= 1'b0 ; 
    else if (src_pulse & src_sync_idle)  
        src_sync_req    <= 1'b1 ; 
    else if (src_sync_ack) 
        src_sync_req    <= 1'b0 ; 
end 

sync #(
    .D_WIDTH      ( 1       ),
    .DELAY_2      ( DELAY_2 ),
    .DATA_DEFAULT ( 0       )
) u_sync(
    .clk_d   ( src_clk      ),
    .rst_d_n ( src_rst_n    ),
    .data_s  ( dst_sync_ack ),
    .data_d  ( src_sync_ack )
);    

//always @(posedge src_clk or negedge src_rst_n) 
//begin 
//    if(src_rst_n == 1'b0) 
//        begin 
//            ack_state_dly1  <= 1'b0 ; 
//            ack_state_dly2  <= 1'b0 ; 
//            src_sync_ack    <= 1'b0 ;          
//        end 
//        else 
//        begin 
//            ack_state_dly1  <= dst_sync_ack     ; 
//            ack_state_dly2  <= ack_state_dly1   ; 
//            src_sync_ack    <= ack_state_dly2   ;          
//        end         
//end 
 
//--=========================================-- 
// DST Clock : 
// 1. sync src sync req  
// 2. generate dst pulse 
// 3. generate sync ack 
//--=========================================-- 
always @(posedge dst_clk or negedge dst_rst_n) 
begin 
    if(dst_rst_n == 1'b0) 
        begin 
            req_state_dly1  <= 1'b0 ; 
            req_state_dly2  <= 1'b0 ; 
            dst_req_state   <= 1'b0 ; 
        end 
    else 
        begin 
            req_state_dly1  <= src_sync_req     ; 
            req_state_dly2  <= req_state_dly1   ; 
            dst_req_state   <= req_state_dly2   ; 
        end 
end 
 
//Rising Edge of dst_state generate a dst_pulse; 
assign dst_pulse = (~dst_req_state) & req_state_dly2 ;  
 
//set sync ack when src_req = 1 , clear it when src_req = 0 ; 
always @(posedge dst_clk or negedge dst_rst_n) 
begin 
    if(dst_rst_n == 1'b0) 
        dst_sync_ack    <= 1'b0; 
    else if (req_state_dly2)   
        dst_sync_ack    <= 1'b1; 
    else   
        dst_sync_ack    <= 1'b0; 
end 
 
 
endmodule
