`ifdef __INTMEM_BLACKBOX__
module IntMem (
// Clock & Reset
            scan_en,
            aclk,
            areset_n,
            mem_type,
            remap,
    
// AXI Write Address Channel
            axi_awid,
            axi_awaddr,
            axi_awlen,
            axi_awsize,
            axi_awburst,
            axi_awlock,
            axi_awcache,
            axi_awprot,
            axi_awvalid,
            
            axi_awready,

// AXI Write Data Channel
            axi_wdata,
            axi_wstrb,
            axi_wlast,
            axi_wvalid,
            
            axi_wready,

// AXI Write response Channel
            axi_bid,
            axi_bresp,
            axi_bvalid,
            
            axi_bready,

// AXI Read Address Channel
           axi_arid,      
           axi_araddr,       
           axi_arlen,     
           axi_arsize,    
           axi_arburst,   
           axi_arlock,    
           axi_arcache,   
           axi_arprot,    
           axi_arvalid,   
           
           axi_arready,

// AXI Read Data Channel     
           axi_rid,
           axi_rdata,
           axi_rresp,
           axi_rlast,
           axi_rvalid,
           
           axi_rready,
    
// Local Ram/Rom Interface
           mem0_cs_n,
           mem0_wr_n,
           mem0_rd_n,
           mem0_wr_byte_en,
           mem0_addr,
           mem0_wr_addr,
           mem0_din,
           mem0_dout,
           
           mem1_cs_n,
           mem1_wr_n,
           mem1_rd_n,
           mem1_wr_byte_en,
           mem1_addr,
           mem1_wr_addr,
           mem1_din,
           mem1_dout,

           mem2_cs_n,
           mem2_wr_n,
           mem2_rd_n,
           mem2_wr_byte_en,
           mem2_addr,
           mem2_wr_addr,
           mem2_din,
           mem2_dout
);

parameter             ID_WIDTH   = 12;          // ID bus width, default = 12-bit
parameter             DATA_WIDTH = 128;         // DATA bus width, default = 128bit
// The following parameters should not be override
localparam            ID_MAX     = ID_WIDTH-1;

// Clock & Reset 
input               scan_en;
input               aclk;                                               
input               areset_n;
input               mem_type; // 1'b0: Single port ram; 1'b1: Dual port ram
input               remap;

// AXI Write Address Channel
input  [ ID_MAX:0]  axi_awid;
input  [31:0]       axi_awaddr;
input  [ 7:0]       axi_awlen;   
input  [ 2:0]       axi_awsize;   
input  [ 1:0]       axi_awburst;   
input  [ 1:0]       axi_awlock;   
input  [ 3:0]       axi_awcache;   
input  [ 2:0]       axi_awprot;   
input               axi_awvalid;

output              axi_awready;

// AXI Write Data Channel
input  [DATA_WIDTH-1:0]      axi_wdata;
input  [DATA_WIDTH/8-1:0]       axi_wstrb;
input               axi_wlast;
input               axi_wvalid;

output              axi_wready;

// AXI Write Response Channel
output [ ID_MAX:0]  axi_bid;
output [ 1:0]       axi_bresp;
output              axi_bvalid;
                    
input               axi_bready;

// AXI Read Address Channel
input  [ ID_MAX:0]  axi_arid;
input  [31:0]       axi_araddr;   
input  [ 7:0]       axi_arlen;
input  [ 2:0]       axi_arsize;
input  [ 1:0]       axi_arburst;
input  [ 1:0]       axi_arlock;
input  [ 3:0]       axi_arcache;
input  [ 2:0]       axi_arprot;
input               axi_arvalid;

output              axi_arready;

// AXI Read Data Channel 
output [ ID_MAX:0]  axi_rid;
output [DATA_WIDTH-1:0]      axi_rdata;
output [ 1:0]       axi_rresp;
output              axi_rlast;   
output              axi_rvalid;       

input               axi_rready;

// Local Ram/Rom Interface
output              mem0_cs_n;   // Only used for SP sram
output              mem0_wr_n;   // Used both for DP/SP sram
output              mem0_rd_n;   // Only used for SP sram
output  [DATA_WIDTH/8-1:0]      mem0_wr_byte_en;
output  [31:0]      mem0_addr;   // Used both for DP/SP sram 
output  [31:0]      mem0_wr_addr;// Only used in DP sram
output  [DATA_WIDTH-1:0]     mem0_din;
input   [DATA_WIDTH-1:0]     mem0_dout;

output              mem1_cs_n;   // Only used for SP sram
output              mem1_wr_n;   // Used both for DP/SP sram
output              mem1_rd_n;   // Only used for SP sram
output  [DATA_WIDTH/8-1:0]      mem1_wr_byte_en;
output  [31:0]      mem1_addr;   // Used both for DP/SP sram 
output  [31:0]      mem1_wr_addr;// Only used in DP sram
output  [DATA_WIDTH-1:0]     mem1_din;
input   [DATA_WIDTH-1:0]     mem1_dout;

output              mem2_cs_n;   // Only used for SP sram
output              mem2_wr_n;   // Used both for DP/SP sram
output              mem2_rd_n;   // Only used for SP sram
output  [DATA_WIDTH/8-1:0]      mem2_wr_byte_en;
output  [31:0]      mem2_addr;   // Used both for DP/SP sram 
output  [31:0]      mem2_wr_addr;// Only used in DP sram
output  [DATA_WIDTH-1:0]     mem2_din;
input   [DATA_WIDTH-1:0]     mem2_dout;

endmodule //IntMem

`else  // __INTMEM_BLACKBOX__

module IntMem (
// Clock & Reset
            scan_en,
            aclk,
            areset_n,
            mem_type,
            remap,
    
// AXI Write Address Channel
            axi_awid,
            axi_awaddr,
            axi_awlen,
            axi_awsize,
            axi_awburst,
            axi_awlock,
            axi_awcache,
            axi_awprot,
            axi_awvalid,
            
            axi_awready,

// AXI Write Data Channel
            axi_wdata,
            axi_wstrb,
            axi_wlast,
            axi_wvalid,
            
            axi_wready,

// AXI Write response Channel
            axi_bid,
            axi_bresp,
            axi_bvalid,
            
            axi_bready,

// AXI Read Address Channel
           axi_arid,      
           axi_araddr,       
           axi_arlen,     
           axi_arsize,    
           axi_arburst,   
           axi_arlock,    
           axi_arcache,   
           axi_arprot,    
           axi_arvalid,   
           
           axi_arready,

// AXI Read Data Channel     
           axi_rid,
           axi_rdata,
           axi_rresp,
           axi_rlast,
           axi_rvalid,
           
           axi_rready,
    
// Local Ram/Rom Interface
           mem0_cs_n,
           mem0_wr_n,
           mem0_rd_n,
           mem0_wr_byte_en,
           mem0_addr,
           mem0_wr_addr,
           mem0_din,
           mem0_dout,
           
           mem1_cs_n,
           mem1_wr_n,
           mem1_rd_n,
           mem1_wr_byte_en,
           mem1_addr,
           mem1_wr_addr,
           mem1_din,
           mem1_dout,
                     
           mem2_cs_n,
           mem2_wr_n,
           mem2_rd_n,
           mem2_wr_byte_en,
           mem2_addr,
           mem2_wr_addr,
           mem2_din,
           mem2_dout//, // Remove this comma, sli 2009/10/10 
);

parameter             ID_WIDTH   = 12;          // ID bus width, default = 12-bit
parameter             DATA_WIDTH = 128;         // DATA bus width,default = 128bit
// The following parameters should not be override
localparam            ID_MAX     = ID_WIDTH-1;

// Clock & Reset 
input               scan_en;
input               aclk;                                               
input               areset_n;
input               mem_type; // 1'b0: Single port ram; 1'b1: Dual port ram
input               remap;

// AXI Write Address Channel
input  [ ID_MAX:0]  axi_awid;
input  [31:0]       axi_awaddr;
input  [ 7:0]       axi_awlen;   
input  [ 2:0]       axi_awsize;   
input  [ 1:0]       axi_awburst;   
input  [ 1:0]       axi_awlock;   
input  [ 3:0]       axi_awcache;   
input  [ 2:0]       axi_awprot;   
input               axi_awvalid;

output              axi_awready;

// AXI Write Data Channel
input  [DATA_WIDTH-1:0]      axi_wdata;
input  [DATA_WIDTH/8-1:0]       axi_wstrb;
input               axi_wlast;
input               axi_wvalid;

output              axi_wready;

// AXI Write Response Channel
output [ ID_MAX:0]  axi_bid;
output [ 1:0]       axi_bresp;
output              axi_bvalid;
                    
input               axi_bready;

// AXI Read Address Channel
input  [ ID_MAX:0]  axi_arid;
input  [31:0]       axi_araddr;   
input  [ 7:0]       axi_arlen;
input  [ 2:0]       axi_arsize;
input  [ 1:0]       axi_arburst;
input  [ 1:0]       axi_arlock;
input  [ 3:0]       axi_arcache;
input  [ 2:0]       axi_arprot;
input               axi_arvalid;

output              axi_arready;

// AXI Read Data Channel 
output [ ID_MAX:0]  axi_rid;
output [DATA_WIDTH-1:0]      axi_rdata;
output [ 1:0]       axi_rresp;
output              axi_rlast;   
output              axi_rvalid;       

input               axi_rready;

// Local Ram/Rom Interface
output              mem0_cs_n;   // Only used for SP sram
output              mem0_wr_n;   // Used both for DP/SP sram
output              mem0_rd_n;   // Only used for SP sram
output  [DATA_WIDTH/8-1:0]      mem0_wr_byte_en;
output  [31:0]      mem0_addr;   // Used both for DP/SP sram 
output  [31:0]      mem0_wr_addr;// Only used in DP sram
output  [DATA_WIDTH-1:0]      mem0_din;
input   [DATA_WIDTH-1:0]      mem0_dout;

output              mem1_cs_n;   // Only used for SP sram
output              mem1_wr_n;   // Used both for DP/SP sram
output              mem1_rd_n;   // Only used for SP sram
output  [DATA_WIDTH/8-1:0]      mem1_wr_byte_en;
output  [31:0]      mem1_addr;   // Used both for DP/SP sram 
output  [31:0]      mem1_wr_addr;// Only used in DP sram
output  [DATA_WIDTH-1:0]     mem1_din;
input   [DATA_WIDTH-1:0]     mem1_dout;

output              mem2_cs_n;   // Only used for SP sram
output              mem2_wr_n;   // Used both for DP/SP sram
output              mem2_rd_n;   // Only used for SP sram
output  [DATA_WIDTH/8-1:0]      mem2_wr_byte_en;
output  [31:0]      mem2_addr;   // Used both for DP/SP sram 
output  [31:0]      mem2_wr_addr;// Only used in DP sram
output  [DATA_WIDTH-1:0]     mem2_din;
input   [DATA_WIDTH-1:0]     mem2_dout;


wire                waddr_valid;
wire                waddr_ready;
wire  [31:0]        waddr_out;
wire                raddr_valid;
wire                raddr_ready;
wire  [31:0]        raddr_out;
wire  [DATA_WIDTH-1:0]       rdata;
wire  [7:0]         mem_wr_mask;
wire                read_done;
wire                write_done;
reg                 mem0_rd_n_dly;
reg                 mem1_rd_n_dly;
reg                 mem2_rd_n_dly;


always @(posedge aclk)begin
    mem0_rd_n_dly <= ~mem0_rd_n;
end

always @(posedge aclk)begin
    mem1_rd_n_dly <= ~mem1_rd_n;
end

always @(posedge aclk)begin
    mem2_rd_n_dly <= ~mem2_rd_n;
end

assign  rdata           = mem0_rd_n_dly ?  mem0_dout :
                          mem1_rd_n_dly ?  mem1_dout :
                          mem2_rd_n_dly ?  mem2_dout : 256'h0;
                          
assign  mem0_din        =  axi_wdata;
assign  mem0_wr_byte_en =  axi_wstrb;
assign  mem1_din        =  axi_wdata;
assign  mem1_wr_byte_en =  axi_wstrb;
assign  mem2_din        =  axi_wdata;
assign  mem2_wr_byte_en =  axi_wstrb;

assign  read_done      =  ( axi_rready & axi_rlast & axi_rvalid ) ;
assign  write_done     =  ( axi_bvalid & axi_bready ) ;

IntMemWrCtrl #(DATA_WIDTH,ID_WIDTH) u_IntMemWrCtrl(
                   // Global Signals
                   .ACLK                 (aclk),
                   .ARESETn              (areset_n),

                   // Write Address Channel
                   .AWID                 (axi_awid), 
                   .AWADDR               (axi_awaddr),
                   .AWLEN                (axi_awlen),
                   .AWSIZE               (axi_awsize),
                   .AWBURST              (axi_awburst),
                   .AWVALID              (axi_awvalid),
                   .AWREADY              (axi_awready),
                   .AWLOCK               (axi_awlock),

                   // Write Channel
                   .WVALID               (axi_wvalid),
                   .WREADY               (axi_wready),

                   // Write Response Channel
                   .BID                  (axi_bid),
                   .BRESP                (axi_bresp),
                   .BVALID               (axi_bvalid),
                   .BREADY               (axi_bready),

                   // Handshake signals between AXI write interface and
                   // Slave function modules
                   .WAddrValid           (waddr_valid),
                   .WAddrReady           (waddr_ready),
                   .WAddrOut             (waddr_out)
);

IntMemRdCtrl #(DATA_WIDTH,ID_WIDTH) u_IntMemRdCtrl(
                   // Global Signals
                   .ACLK                 (aclk),
                   .ARESETn              (areset_n),

                   // Read Address Channel
                   .ARID                 (axi_arid),
                   .ARADDR               (axi_araddr),
                   .ARLEN                (axi_arlen),
                   .ARSIZE               (axi_arsize),
                   .ARBURST              (axi_arburst),
                   .ARVALID              (axi_arvalid),
                   .ARREADY              (axi_arready),
                   .ARLOCK               (axi_arlock),

                   // Read Channel
                   .RID                  (axi_rid),
                   .RLAST                (axi_rlast),
                   .RDATA                (axi_rdata),
                   .RRESP                (axi_rresp),
                   .RVALID               (axi_rvalid),
                   .RREADY               (axi_rready),

                   // Handshake signals between AXI read interface and
                   // Slave function modules
                   .RAddrValid           (raddr_valid),
                   .RAddrReady           (raddr_ready),
                   .RAddrOut             (raddr_out),
                   .RData                (rdata),
                   .RResp                (1'b0)
                  );

IntMemArb u_IntMemArb (
                   // Global Signals
                   .ACLK                 (aclk),
                   .ARESETn              (areset_n),
                   .mem_type             (mem_type),
                   .read_done            (read_done),
                   .write_done           (write_done),
                   .remap                (remap),

                   // Interface with write control module
                   .waddr_valid          (waddr_valid),
                   .axi_awvalid          (axi_awvalid),
                   .waddr_ready          (waddr_ready),
                   .waddr_out            (waddr_out),
                   .axi_awaddr           (axi_awaddr),
                   
                   // Interface with read control module
                   .raddr_valid          (raddr_valid),
                   .axi_arvalid          (axi_arvalid),                   
                   .raddr_ready          (raddr_ready),
                   .raddr_out            (raddr_out),
                   .axi_araddr           (axi_araddr),
                   
                   // Interface with Local ram
                   .mem0_cs_n             (mem0_cs_n),
                   .mem0_wr_n             (mem0_wr_n),
                   .mem0_rd_n             (mem0_rd_n),
                   .mem0_addr             (mem0_addr),
                   .mem0_wr_addr          (mem0_wr_addr),
                   .mem1_cs_n             (mem1_cs_n),
                   .mem1_wr_n             (mem1_wr_n),
                   .mem1_rd_n             (mem1_rd_n),
                   .mem1_addr             (mem1_addr),
                   .mem1_wr_addr          (mem1_wr_addr),
                   .mem2_cs_n             (mem2_cs_n),
                   .mem2_wr_n             (mem2_wr_n),
                   .mem2_rd_n             (mem2_rd_n),
                   .mem2_addr             (mem2_addr),
                   .mem2_wr_addr          (mem2_wr_addr)
);

endmodule

`endif
