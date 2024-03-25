// +FHDR----------------------------------------------------------------------------
// Copyright (c) 2022 Cygnusemi.
// ALL RIGHTS RESERVED Worldwide
//         
// Author        : zhanglin
// Email         : linn_zh@cygnusemi.com
// Created On    : 2022/08/01 14:58
// Last Modified : 2023/08/29 10:14
// File Name     : dmux_sync.v
// Description   :
//   dmux_sync module supports datawidth configurable parameters( parameter DATA_WIDTH) ;  
//   enable Signal synchronization beat number can be configured (SYN_WIDTH);
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2022/08/01   zhanglin        1.0                     Original
// -FHDR----------------------------------------------------------------------------


module dmux_sync #(
    parameter  DATA_WIDTH    = 32,
    parameter  DELAY_2       = 1 ,
    parameter  DEFAULT_VALUE = 0
)(
    input                       clk_src   ,
    input                       rstn_src  ,
    input      [DATA_WIDTH-1:0] data_in   ,
    input                       datain_en ,
    input                       clk_dst   ,
    input                       rstn_dst  ,
    output reg [DATA_WIDTH-1:0] data_out  ,
    output reg                  dataout_en
);

    reg                   datain_en_src;
    reg  [DATA_WIDTH-1:0] data_in_src  ;
//    reg  [2:0]            datain_en_dst;

    always @(posedge clk_src or negedge rstn_src) begin
       if (1'b0 == rstn_src) begin
           datain_en_src <= 1'b0;
       end
       else if(datain_en) begin
           datain_en_src <= ~datain_en_src;
       end
    end

    always @(posedge clk_src or negedge rstn_src) begin
       if (1'b0 == rstn_src) begin
           data_in_src <= DEFAULT_VALUE;
       end
       else if (datain_en) begin
           data_in_src <= data_in;
       end
    end

generate 
    if (DELAY_2 == 1) begin: DELAY_2_CLK  
      reg  [2:0]            datain_en_dst;
      always @(posedge clk_dst or negedge rstn_dst) begin
         if (1'b0 == rstn_dst) begin
             datain_en_dst <= 3'b0;
         end
         else begin
             datain_en_dst <= {datain_en_dst[1:0], datain_en_src};
         end
      end

      always @(posedge clk_dst or negedge rstn_dst) begin
         if (1'b0 == rstn_dst) begin
             data_out   <= DEFAULT_VALUE;
             dataout_en <= 1'b0;
         end
         else if (datain_en_dst[2] ^ datain_en_dst[1]) begin
              data_out   <= data_in_src;
              dataout_en <= 1'b1;
         end
         else begin
             dataout_en <= 1'b0;
         end    
      end
    end    
    else begin: DELAY_3_CLK
      reg  [3:0]            datain_en_dst;
      always @(posedge clk_dst or negedge rstn_dst) begin
         if (1'b0 == rstn_dst) begin
             datain_en_dst <= 4'b0;
         end
         else begin
             datain_en_dst <= {datain_en_dst[2:0], datain_en_src};
         end
      end

      always @(posedge clk_dst or negedge rstn_dst) begin
         if (1'b0 == rstn_dst) begin
             data_out   <= DEFAULT_VALUE;
             dataout_en <= 1'b0;
         end
         else if (datain_en_dst[3] ^ datain_en_dst[2]) begin
              data_out   <= data_in_src;
              dataout_en <= 1'b1;
         end
         else begin
             dataout_en <= 1'b0;
         end    
      end
    end    
endgenerate
endmodule
