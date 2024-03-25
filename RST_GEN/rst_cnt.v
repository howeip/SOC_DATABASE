// +FHDR----------------------------------------------------------------------------
// Copyright (c) 2023 Cygnusemi.
// ALL RIGHTS RESERVED Worldwide
//         
// Author        : ninghechuan
// Email         :  @cygnusemi.com
// Created On    : 2023/08/15 15:30
// Last Modified : 2023/08/15 15:30
// File Name     : rst_cnt.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2023/08/15   ninghechuan     1.0                     Original
// -FHDR----------------------------------------------------------------------------
module rst_cnt #(
	parameter CNT_WIDTH=16,
	parameter CNT_THRESH=16'hFFFF,
	parameter CNT_AL_THRESH=CNT_THRESH
	) (
	input clk,
	input rst_n,
	input sync_rst,
	output reg cnt_al_done,
	output reg cnt_done
	);

reg [(CNT_WIDTH-1):0] rst_counter;
always @ (posedge clk or negedge rst_n)
begin
	if (~rst_n)
		rst_counter<={CNT_WIDTH{1'b0}};
	else if (sync_rst)
		rst_counter<={CNT_WIDTH{1'b0}};
	else
		rst_counter<=(rst_counter==CNT_THRESH)?rst_counter:(rst_counter+1'b1);
end

always @ (posedge clk or negedge rst_n)
begin
	if (~rst_n)
	begin
		cnt_done   <=1'b0;
		cnt_al_done<=1'b0;
	end
	else
	begin
		cnt_done   <=(rst_counter>=CNT_THRESH);
		cnt_al_done<=(rst_counter>=CNT_AL_THRESH);
	end
end
endmodule
