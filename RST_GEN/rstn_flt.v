// +FHDR----------------------------------------------------------------------------
// Copyright (c) 2022 Cygnusemi.
// ALL RIGHTS RESERVED Worldwide
//         
// Author        : zhanglin
// Email         : linn_zh@cygnusemi.com
// Created On    : 2022/08/01 15:13
// Last Modified : 2022/11/01 16:48
// File Name     : rstn_flt.v
// Description   : internal reset signal with glitch elimination
//                 external clock input for reset filtering usage
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2022/08/01   zhanglin        1.0                     Original
// -FHDR----------------------------------------------------------------------------
module rstn_flt(
    output reg  flt_rst_n                   , //internal reset signal with glitch elimination
    input       clk                         , //external clock input for reset filtering usage
    input       rst_n                       , //external reset input
    input       por_n                       , //only por reset input
    input       test_md                     
);

reg         rst_sync1                   ;
reg         rst_sync2                   ;
reg         rst_sync3                   ;
reg         rst_sync4                   ;
reg         rst_sync5                   ;
reg         rst_sync6                   ;
reg         rst_sync7                   ;
reg         rst_sync8                   ;

wire        rst_with_pos_glitch         ;
wire        ini_rst_n                   ;
reg [8:0]   rst_cnt                     ;
wire        rst_cnt_not_full            ;

/******************************************************/
/*  3-Stage Synchonizer for POR           */    
/******************************************************/

always @(posedge clk or negedge por_n)
begin
    if(1'b0 == por_n) begin
        rst_sync1 <= 1'b0;
        rst_sync2 <= 1'b0;
        rst_sync3 <= 1'b0;
        rst_sync4 <= 1'b0;
    end
    else begin
        rst_sync1 <= rst_n;
        rst_sync2 <= rst_sync1;
        rst_sync3 <= rst_sync2;
        rst_sync4 <= rst_sync3;
    end
end

assign  rst_with_pos_glitch = rst_n | rst_sync1 | rst_sync2 | rst_sync3 | rst_sync4;

// make sure power on reset is available from time 0
// only one of por_sync5~8 is active 0 at time 0, sys reset will be active.

always @(posedge clk or negedge por_n)
begin
    if(1'b0 == por_n) begin
      rst_sync5 <= 1'b0;
      rst_sync6 <= 1'b0;
      rst_sync7 <= 1'b0;
      rst_sync8 <= 1'b0;
    end
    else begin
      rst_sync5 <= rst_with_pos_glitch;
      rst_sync6 <= rst_sync5;
      rst_sync7 <= rst_sync6;
      rst_sync8 <= rst_sync7;
    end
end

assign ini_rst_n = test_md ? rst_n : rst_sync5 & rst_sync6 & rst_sync7 & rst_sync8;

//9 bit negative glitch counter
`ifdef SIM_ON
assign rst_cnt_not_full = (rst_cnt < 9'd15);
`else
assign rst_cnt_not_full = (rst_cnt < 9'd511);
`endif

always @(posedge clk or negedge ini_rst_n) begin
    if(1'b0 == ini_rst_n) 
        rst_cnt <= 9'h0;
    else if(1'b1 == rst_cnt_not_full) 
        rst_cnt <= rst_cnt + 1;
end
//--end


//registered clean & extended reset signal for internal chip usage
wire rst_cnt_full = ~rst_cnt_not_full;
always@(posedge clk or negedge ini_rst_n) begin
    if(1'b0 == ini_rst_n)
        flt_rst_n <= 1'b0;
    else if (rst_cnt_full) 
        flt_rst_n <= 1'b1;
    else
        flt_rst_n <= 1'b0;
end

endmodule
