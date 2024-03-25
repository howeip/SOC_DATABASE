// +FHDR----------------------------------------------------------------------------
// Copyright (c) 2022 Cygnusemi.
// ALL RIGHTS RESERVED Worldwide
//         
// Author        : zhanglin
// Email         : linn_zh@cygnusemi.com
// Created On    : 2022/08/01 15:14
// Last Modified : 2022/11/01 16:49
// File Name     : rstn_sync.v
// Description   : 
// --rstn_sync module supports configurable parameters;
//   Asynchronous reset, synchronous release;
//   Synchronous reset;
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2022/08/01   zhanglin        1.0                     Original
// -FHDR----------------------------------------------------------------------------

module rstn_sync(
    input       sync_clock  ,
    input       rstn_n      ,
    output      async_rstn_n,
    output      sync_rstn_n    
);

parameter WIDTH = 4;
reg [WIDTH-1:0] sync_rstn   ;

always @(posedge sync_clock or negedge rstn_n) begin
    if(1'b0 == rstn_n)
	    sync_rstn <= {WIDTH{1'b0}};
    else 
	    sync_rstn <= {sync_rstn[WIDTH-2:0], 1'b1};
end

assign async_rstn_n = sync_rstn[WIDTH-2];
assign sync_rstn_n  = sync_rstn[WIDTH-1] || (~sync_rstn[WIDTH-2]);

endmodule
