module ahb2mem_fifo
#(
    parameter DWIDTH = 32)
(
    input               i_clk         ,   
    input               i_rst_n       ,
    input               i_fifo_rd     ,    
    input               i_fifo_wr     ,    
    input [DWIDTH-1:0]  i_fifo_din    , 

// output pins 
    output              o_fifo_full   ,
    output              o_fifo_afull  ,
    output              o_fifo_empty  ,  
    output [DWIDTH-1:0] o_fifo_dout
);

//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
reg  [2:0]   wptr;   
reg  [2:0]   rptr;   

wire [2:0]   wptr_nxt; 
wire [2:0]   rptr_nxt; 

reg  [DWIDTH-1:0] mem[3:0];

wire   sel0;
wire   sel1;
wire   sel2;
wire   sel3; 
wire [2:0]   wptr_add_2; 
//---------------------read and write control---------------------------------

assign  wptr_nxt = wptr + 1'b1;
assign  rptr_nxt = rptr + 1'b1;

always @(posedge i_clk or negedge i_rst_n) begin 
    if(i_rst_n == 1'b0)   
        rptr <= {3{1'b0}}; 
    else if (i_fifo_rd & (!o_fifo_empty))
        rptr <= rptr_nxt;
end 

always @(posedge i_clk or negedge i_rst_n) begin 
    if(i_rst_n == 1'b0) 
        wptr <= {3{1'b0}}; 
    else if (i_fifo_wr & (!o_fifo_full))
        wptr <= wptr_nxt;
end 

always @(posedge i_clk) begin 
    if(i_fifo_wr & (!o_fifo_full)) 
      mem[wptr[1:0]] <= i_fifo_din;
end
 

assign sel0 = (rptr[1:0] == 2'h0);
assign sel1 = (rptr[1:0] == 2'h1);
assign sel2 = (rptr[1:0] == 2'h2);
assign sel3 = (rptr[1:0] == 2'h3);

assign o_fifo_dout = ({(DWIDTH){sel0}} & mem[0])
                   | ({(DWIDTH){sel1}} & mem[1])
                   | ({(DWIDTH){sel2}} & mem[2])
                   | ({(DWIDTH){sel3}} & mem[3]);

 

//------------------------------full&empty control------------------------------

assign wptr_add_2  = wptr + 3'h2;
assign o_fifo_full = (wptr =={!rptr[2],rptr[1:0]});
assign o_fifo_empty =(wptr == rptr);
assign o_fifo_afull = (wptr_nxt=={!rptr[2],rptr[1:0]}) | o_fifo_full | (wptr_add_2 == {!rptr[2],rptr[1:0]});

endmodule
