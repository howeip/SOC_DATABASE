module IntMemArb (
                   // Global Signals
                   ACLK,
                   ARESETn,
                   mem_type,
                   read_done,
                   write_done,
                   remap,
                   
                   // Interface with write control module
                   waddr_valid,
                   axi_awvalid,
                   waddr_ready,
                   waddr_out,
                   axi_awaddr,
                   
                   // Interface with read control module
                   raddr_valid,
                   axi_arvalid,
                   raddr_ready,
                   raddr_out,
                   axi_araddr,
                   
                   // Interface with Local ram
                   mem0_cs_n,
                   mem0_wr_n,
                   mem0_rd_n,
                   mem0_addr,
                   mem0_wr_addr,
                   mem1_cs_n,
                   mem1_wr_n,
                   mem1_rd_n,
                   mem1_addr,
                   mem1_wr_addr,
                   mem2_cs_n,
                   mem2_wr_n,
                   mem2_rd_n,
                   mem2_addr,
                   mem2_wr_addr//, //Remove this comma, sli 2009/10/10
);
// Global Signals
input           ACLK;
input           ARESETn;
input           mem_type;
input           read_done;
input           write_done;
input           remap;

// Interface with write control module
input           axi_awvalid;
input           waddr_valid;
input  [31:0]   waddr_out; 
output          waddr_ready;
input  [31:0]   axi_awaddr;    

// Interface with read control module
input           axi_arvalid;
input           raddr_valid;
input  [31:0]   raddr_out;      
output          raddr_ready;
input  [31:0]   axi_araddr;   

// Interface with Local ram
output          mem0_cs_n;
output          mem0_wr_n;
output          mem0_rd_n;
output [31:0]   mem0_addr;
output [31:0]   mem0_wr_addr;

output          mem1_cs_n;
output          mem1_wr_n;
output          mem1_rd_n;
output [31:0]   mem1_addr;
output [31:0]   mem1_wr_addr;

output          mem2_cs_n;
output          mem2_wr_n;
output          mem2_rd_n;
output [31:0]   mem2_addr;
output [31:0]   mem2_wr_addr;

`define MEM_IDLE  2'b00
`define MEM_RD    2'b01
`define MEM_WR    2'b10
`define WR_WIN    1'b0
`define RD_WIN    1'b1

parameter IDLE   = 2'b00;
parameter RD     = 2'b01;
parameter WR     = 2'b10;
parameter RDWR   = 2'b11;


reg [31:0]  waddr;
reg [31:0]  raddr;  
wire        arb_c;
wire        arb_r;
wire        arb_w;
reg [1:0]   mem_status;
reg         waddr_ready;
reg         raddr_ready;
wire        sp_mem;    // 1'b0: single port ram, include rom; 1'b1: dual port ram
wire [31:0] mux_addr;
    

wire     mem_cs_n      = !( waddr_valid | raddr_valid );
wire     mem_bank0     = mem0_addr[20]; 
wire     mem_bank1     = !mem0_addr[20];
wire     mem_sub_bank0 = ~((mem0_addr[18:15]==4'h0)&(mem0_addr[14:12]==3'd0|mem0_addr[14:12]==3'd1));
wire     mem_sub_bank1 = ((mem0_addr[18:15]==4'h0)&(mem0_addr[14:12]==3'd0|mem0_addr[14:12]==3'd1));

//assign   mem0_cs_n    = remap ? (mem_cs_n | mem_bank1 ) : (mem_cs_n | mem_bank0); 
assign   mem0_cs_n    = mem_cs_n ; 
assign   mem0_wr_n    = (!waddr_valid) | mem0_cs_n;
assign   mem0_rd_n    = !raddr_valid | mem0_cs_n;
assign   mem0_wr_addr = waddr_out;

assign   mem1_cs_n    = 1'b1;//remap ? (mem_cs_n | mem_bank0 | mem_sub_bank0) : (mem_cs_n | mem_bank1 | mem_sub_bank0); 
assign   mem1_wr_n    = (!waddr_valid) | mem1_cs_n;
assign   mem1_rd_n    = (!raddr_valid) | mem1_cs_n;
assign   mem1_wr_addr = waddr_out;

assign   mem2_cs_n    = 1'b1;//remap ? (mem_cs_n | mem_bank0 | mem_sub_bank1) : (mem_cs_n | mem_bank1 | mem_sub_bank1); 
assign   mem2_wr_n    = (!waddr_valid) | mem2_cs_n;
assign   mem2_rd_n    = (!raddr_valid) | mem2_cs_n;
assign   mem2_wr_addr = waddr_out;


assign   mux_addr     = ( mem_status == `MEM_RD ) ? raddr_out  : waddr_out ; 
assign   sp_mem       = ( mem_type == 1'b0 );

assign   mem0_addr    = raddr_out;

//assign   mem0_addr    = sp_mem ? mux_addr : raddr_out;
assign   mem1_addr    = sp_mem ? mux_addr : raddr_out;
assign   mem2_addr    = sp_mem ? (mux_addr-14'h2000) : raddr_out;

always @(posedge ACLK or negedge ARESETn)begin
     if(!ARESETn) 
         waddr <=  32'b0;
     else if (axi_awvalid)
         waddr <= axi_awaddr;
end         

always @(posedge ACLK or negedge ARESETn)begin
     if(!ARESETn) 
         raddr <=  32'b0;
     else if (axi_arvalid)
         raddr <= axi_araddr;
end   

    assign arb_c =  (axi_awaddr[31:16] == axi_araddr[31:16]) ? 1'b1 : 1'b0;
    assign arb_w =  (axi_awaddr[31:16] == raddr[31:16]) ? 1'b1 : 1'b0;
    assign arb_r =  (waddr[31:16] == axi_araddr[31:16]) ? 1'b1 : 1'b0;



always @(posedge ACLK or negedge ARESETn)begin
     if(!ARESETn) begin
         waddr_ready   <= 1'b0;
         raddr_ready   <= 1'b0;
         mem_status    <= `MEM_IDLE;
     end 
     else case (mem_status)
        IDLE: begin
             if(axi_awvalid & !axi_arvalid) begin
                mem_status    <= WR;
                raddr_ready   <= 1'b0;
                waddr_ready   <= 1'b1;
             end
             else if(axi_arvalid & !axi_awvalid) begin
                mem_status    <= RD;
                waddr_ready   <= 1'b0;
                raddr_ready   <= 1'b1;
             end
             else if(axi_awvalid & axi_arvalid & arb_c) begin
                mem_status    <= WR;
                waddr_ready   <= 1'b1;
                raddr_ready   <= 1'b0;
             end
             else if(axi_awvalid & axi_arvalid & !arb_c) begin
                mem_status    <= RDWR;
                waddr_ready   <= 1'b1;
                raddr_ready   <= 1'b1;
             end
         end
         WR: begin
             if (write_done & axi_arvalid) begin
                mem_status    <= RD;
                waddr_ready   <= 1'b0;
                raddr_ready   <= 1'b1;
             end    
             else if(axi_arvalid & !arb_r) begin
                mem_status    <= RDWR;
                waddr_ready   <= waddr_ready;
                raddr_ready   <= 1'b1;
             end
             else if (write_done) begin
                mem_status    <= IDLE;
                waddr_ready   <= 1'b0;
                raddr_ready   <= 1'b0;
             end
         end
         RD: begin    
             if (read_done & axi_awvalid) begin
                mem_status    <= WR;
                waddr_ready   <= 1'b1;
                raddr_ready   <= 1'b0;
             end    
             else if(axi_awvalid & !arb_w) begin
                mem_status    <= RDWR;
                waddr_ready   <= 1'b1;
                raddr_ready   <= raddr_ready;
             end
             else if (read_done) begin
                mem_status    <= IDLE;
                waddr_ready   <= 1'b0;
                raddr_ready   <= 1'b0;
             end
         end
         default: begin    
             if(read_done & write_done) begin
                mem_status    <= IDLE;
                waddr_ready   <= 1'b0;
                raddr_ready   <= 1'b0;
             end
             else if (read_done ) begin
                mem_status    <= WR;
                waddr_ready   <= waddr_ready;
                raddr_ready   <= 1'b0;
             end    
             else if (write_done) begin
                mem_status    <= RD;
                waddr_ready   <= 1'b0;
                raddr_ready   <= raddr_ready;
             end
         end
    endcase
end
       
/*
always @(posedge ACLK or negedge ARESETn)begin
     if(!ARESETn) begin
         waddr_ready   <= 1'b0;
         raddr_ready   <= 1'b0;
         mem_status    <= `MEM_IDLE;
     end else if(!sp_mem)begin // No arbitration for DP ram
           mem_status    <= `MEM_IDLE;
           raddr_ready   <= 1'b1;
           waddr_ready   <= 1'b1;
     end else if(read_done & axi_awvalid )begin //Write occurs during read?
           mem_status    <= `MEM_WR;
           raddr_ready   <= 1'b0;
           waddr_ready   <= 1'b1;
     end else if(write_done & axi_arvalid )begin //Read occurs during write?
           mem_status    <= `MEM_RD;
           raddr_ready   <= 1'b1;
           waddr_ready   <= 1'b0;
     end else if(write_done & !axi_arvalid )begin //No Read occurs during write?
           mem_status    <= `MEM_IDLE;
           raddr_ready   <= 1'b0;
           waddr_ready   <= 1'b0;
     end else if(read_done & !axi_awvalid )begin //No Write occurs during read?
           mem_status    <= `MEM_IDLE;
           raddr_ready   <= 1'b0;
           waddr_ready   <= 1'b0;          
     end else if(axi_awvalid & !axi_arvalid & (mem_status == `MEM_IDLE)) begin // Grant write operation for SP ram
         mem_status    <= `MEM_WR;
         raddr_ready   <= 1'b0;
         waddr_ready   <= 1'b1;
     end else if(axi_arvalid & !axi_awvalid & (mem_status == `MEM_IDLE)) begin // Grant read operation for SP ram
         mem_status    <= `MEM_RD;
         waddr_ready   <= 1'b0;
         raddr_ready   <= 1'b1;
     end else if(axi_awvalid & axi_arvalid  & (mem_status == `MEM_IDLE)) begin // Write win now  for SP ram
           mem_status    <= `MEM_WR;
           raddr_ready   <= 1'b0;
           waddr_ready   <= 1'b1;
     end
end
*/
endmodule
