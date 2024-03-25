// +FHDR----------------------------------------------------------------------------
// Copyright (c) 2022 Cygnusemi.
// ALL RIGHTS RESERVED Worldwide
//         
// Author        : zhanglin
// Email         : linn_zh@cygnusemi.com
// Created On    : 2023/09/12 15:14
// Last Modified : 2023/09/12 14:44
// File Name     : areset_relax.v
// Description   : 
// --areset_relax module supports configurable parameters;
//   Asynchronous reset, Asynchronous release;
//   This technique for solving the high-fanout reset network timing issue employs clock-gating. 
//   This technique also trades resetatency for easier timing convergence. 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2023/09/12   zhanglin        1.0                     Original
// -FHDR----------------------------------------------------------------------------

module areset_relax #(
    parameter  BYPASS   = 1 ,
    parameter  MAX      = 4
)    
(
    input       sync_clock  ,
    input       rstn_n      ,
    output      async_rstn_n,
    output      ce   
);

parameter WIDTH = 2               ;
reg [WIDTH-1:0] sync_rstn         ;
wire            rst_clk_n         ;

// reset synchronizre
always @(posedge sync_clock or negedge rstn_n) begin
    if(1'b0 == rstn_n)
	    sync_rstn <= {WIDTH{1'b0}};
    else 
	    sync_rstn <= {sync_rstn[WIDTH-2:0], 1'b1};
end

assign rst_clk_n = sync_rstn[WIDTH-1]; 

generate 
    if (BYPASS == 1) begin: BYPASS_1
        assign async_rstn_n = rst_clk_n;
        assign ce           = 1'b1     ;
    end
    else begin: BYPASS_0
        reg [2:0]       state              ;
        reg [2:0]       nxt_state          ;
        reg [3:0]       counter            ;
        reg             rst_clk_n_g        ;
        reg             icg_ce             ;

        localparam      RST_ST    = 3'b001 ;
        localparam      COUNT_ST  = 3'b010 ;
        localparam      FINISH_ST = 3'b100 ;  

        //reset fsm
        always @(posedge sync_clock or negedge rst_clk_n) begin
            if(1'b0 == rst_clk_n)
                state <= RST_ST;
            else
                state <= nxt_state;
        end    
        
        always @(*) begin
            case(state)
                RST_ST: begin
                    if(rst_clk_n)
                        nxt_state = COUNT_ST;
                    else
                        nxt_state = RST_ST;
                end
        
                COUNT_ST: begin
                    if(counter == MAX)
                        nxt_state = FINISH_ST;
                    else
                        nxt_state = COUNT_ST;
                end
        
                FINISH_ST: begin
                        nxt_state = FINISH_ST;
                end
                
                default  : nxt_state = RST_ST;
            endcase
        end

        //reset counter
        always @(posedge sync_clock or negedge rst_clk_n) begin
            if(1'b0 == rst_clk_n)
        	    counter <= 4'b0;
            else if(state == RST_ST)
        	    counter <= 4'b0;
            else if(counter == MAX)
                counter <= 4'b0;
            else if(state == COUNT_ST)
                counter <= counter + 4'b1;
        end
        
        always @(posedge sync_clock or negedge rst_clk_n) begin
            if(1'b0 == rst_clk_n) begin
        	    rst_clk_n_g <= 1'b0;
                icg_ce      <= 1'b0;
            end    
            else if(state == RST_ST) begin
        	    rst_clk_n_g <= 1'b0;
                icg_ce      <= 1'b0;
            end    
            else if(state == COUNT_ST) begin
        	    rst_clk_n_g <= 1'b1;
                icg_ce      <= 1'b0;
            end    
            else if(state == FINISH_ST) begin
        	    rst_clk_n_g <= 1'b1;
                icg_ce      <= 1'b1;
            end    
        end

        assign async_rstn_n = rst_clk_n_g;
        assign ce           = icg_ce     ;
    end 
endgenerate

endmodule
