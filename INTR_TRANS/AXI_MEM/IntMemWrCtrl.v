module IntMemWrCtrl (
                   // Global Signals
                   ACLK,
                   ARESETn,

                   // Write Address Channel
                   AWID,
                   AWADDR,
                   AWLEN,
                   AWSIZE,
                   AWBURST,
                   AWVALID,
                   AWREADY,
                   AWLOCK,

                   // Write Channel
                   WVALID,
                   WREADY,

                   // Write Response Channel
                   BID,
                   BRESP,
                   BVALID,
                   BREADY,

                   // Handshake signals between AXI write interface and
                   // Slave function modules
                   WAddrValid,
                   WAddrReady,
                   WAddrOut
);

// -----------------------------------------------------------------------------
// Include Global Constant's
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
// AXI Constants
//------------------------------------------------------------------------------
// ALEN Encoding
`define AXI_ALEN_1            4'b0000
`define AXI_ALEN_2            4'b0001
`define AXI_ALEN_3            4'b0010
`define AXI_ALEN_4            4'b0011
`define AXI_ALEN_5            4'b0100
`define AXI_ALEN_6            4'b0101
`define AXI_ALEN_7            4'b0110
`define AXI_ALEN_8            4'b0111
`define AXI_ALEN_9            4'b1000
`define AXI_ALEN_10           4'b1001
`define AXI_ALEN_11           4'b1010
`define AXI_ALEN_12           4'b1011
`define AXI_ALEN_13           4'b1100
`define AXI_ALEN_14           4'b1101
`define AXI_ALEN_15           4'b1110
`define AXI_ALEN_16           4'b1111

// ASIZE Enconding
`define AXI_ASIZE_8           3'b000
`define AXI_ASIZE_16          3'b001
`define AXI_ASIZE_32          3'b010
`define AXI_ASIZE_64          3'b011
`define AXI_ASIZE_128         3'b100
`define AXI_ASIZE_256         3'b101
`define AXI_ASIZE_512         3'b110
`define AXI_ASIZE_1024        3'b111

// ABURST Encoding
`define AXI_ABURST_FIXED      2'b00
`define AXI_ABURST_INCR       2'b01
`define AXI_ABURST_WRAP       2'b10

// ALOCK Encoding
`define AXI_ALOCK_NOLOCK      2'b00
`define AXI_ALOCK_EXCL        2'b01
`define AXI_ALOCK_LOCKED      2'b10

// RRESP / BRESP Encoding
`define AXI_RESP_OKAY         2'b00
`define AXI_RESP_EXOKAY       2'b01
`define AXI_RESP_SLVERR       2'b10
`define AXI_RESP_DECERR       2'b11

// --========================= End =============================================

//------------------------------------------------------------------------------
// Parameters
//------------------------------------------------------------------------------
// user parameters
  parameter           DATA_WIDTH = 128;           // Data bus width, default = 128-bit
  parameter           ID_WIDTH   = 4;             // ID bus width, default = 4-bit

// Do not override the following parameters: they must be calculated exactly
// as shown below
  localparam          DATA_MAX   = DATA_WIDTH-1;  // DATA max index
  localparam          ID_MAX     = ID_WIDTH-1;    // ARID/RID max index

//------------------------------------------------------------------------------
// Port declarations
//------------------------------------------------------------------------------
// Global Signals
  input                     ACLK;       // Clock input
  input                     ARESETn;    // Reset async input active low

// Write Address Channel
  input [ID_MAX : 0]  AWID;       // Write address ID
  input [31 : 0]      AWADDR;     // Write address
  input [7 : 0]       AWLEN;      // Write burst length
  input [2 : 0]       AWSIZE;     // Write burst size
  input [1 : 0]       AWBURST;    // Write burst type
  input                     AWVALID;    // Write data valid
  output                    AWREADY;    // Write data ready
  input [1:0]               AWLOCK ;

// Write Channel
  input                     WVALID;     // Write valid
  output                    WREADY;     // Write ready

// Write Response Channel
  output [ID_MAX : 0] BID;        // Write response ID
  output [1 : 0]      BRESP;      // Write response
  output                    BVALID;     // Response valid
  input                     BREADY;     // Response ready

// Handshake signals between AXI write interface and Slave function modules
  output                    WAddrValid; // Write address to Slave block is valid
  input                     WAddrReady; // Write address is consumed in Slave block
  output [31 : 0]     WAddrOut;   // Write address to Slave block

//----------------------------------------------------------------------------
// Signal declarations
//----------------------------------------------------------------------------

// Global Signals
  wire                      ACLK;       // Clock wire
  wire                      ARESETn;    // Reset async wire  active low

  reg   [1:0] BRESP_TYPE ;

// Write Address Channel
  wire [ID_MAX : 0]   AWID;       // Write address ID
  wire [31 : 0]       AWADDR;     // Write address
  wire [7 : 0]        AWLEN;      // Write burst length
  wire [2 : 0]        AWSIZE;     // Write burst size
  wire [1 : 0]        AWBURST;    // Write burst type
  wire                      AWVALID;    // Write address valid
  wire                      AWVALIDhold;
  wire                      AWREADY;    // Write address ready
  wire                      AWREADYi;
  wire                      AWREADYhold;

// Write Channel
  wire                      WVALID;     // Data valid
  wire                      WREADY;     // Data ready

// Write Response Channel
  wire [ID_MAX : 0]   BID;        // Write response ID
  wire [1 : 0]        BRESP;      // Write response
  wire                      BVALID;     // Response valid
  wire                      BREADY;     // Response ready

// Handshake signals between AXI write interface and Slave function modules
  wire                      WAddrValid; // Write address to Slave block is valid
  wire                      WAddrReady; // Write address is consumed in Slave block
  wire [31 : 0]       WAddrOut;   // Write address to Slave block

  wire [31 : 0]       AddrOut;
  wire [ID_MAX : 0]   AddrId;
  wire                      AddrLast;
  wire                      AddrValid;
  wire                      AddrReady;
  wire                      DataLast;

  wire                      wrongwid;
 // reg                             brespr;
  wire                      brespi;

  reg [ID_MAX : 0]    bidr;
  reg                         bvalidr;
  reg                         wreadyr;
  reg                       AddrValidr;

//  ============================================================================
//                           Main body of code
//  ============================================================================
  // -------------------
  // output to slave
  // -------------------
  assign WAddrValid         = AddrValid;
  assign WAddrOut[31:0]     = AddrOut[31:0];

  // -------------------
  // input from slave
  // -------------------
  assign AddrReady          = WAddrReady;

  // -------------------
  // outputs to AXI write address channel
  // -------------------
  assign AWREADY            = AWREADYhold;
  
  // Begin of modification, sli
  // Original
  //assign AWREADYi         = AWVALIDhold & WVALID;
 
  // New
  assign AWREADYi           = AWVALIDhold & WVALID & WAddrReady;
  // End of modification, sli

  // -------------------
  // outputs to AXI write data channel
  // -------------------
  assign WREADY             =   WAddrReady & ( AWVALIDhold ? WVALID : wreadyr) ;

  // -------------------
  // outputs to AXI write response channel
  // -------------------
  assign BID[ID_MAX:0]      = bidr[ID_MAX:0];
  //assign BRESP[1:0]         = {brespr,1'b0};
  assign BRESP[1:0]         = BRESP_TYPE ;
  assign brespi             = wrongwid;
  assign BVALID             = bvalidr;

  // -------------------
  // Address Unpacker
  // -------------------
  IntMemAddrGen #(ID_WIDTH) u_IntMemAddrGen
    (
     // Global Inputs
     .ACLK(ACLK),
     .ARESETn(ARESETn),
     // AXI interface
     .AxADDR(AWADDR),
     .AxSIZE(AWSIZE),
     .AxBURST(AWBURST),
     .AxLEN(AWLEN),
     .AxID(AWID),
     .AxVALID(AWVALIDhold),
     .AxREADY(AWREADYhold),
     // Unpacked address interface
     .AddrOut(AddrOut),
     .AddrId(AddrId),
     .AddrLast(AddrLast),
     .AddrValid(AddrValid),
     .DataLast(DataLast),

     .xVALID(WVALID),
     .xREADY(WREADY)
     );
  always @ (posedge ACLK or negedge ARESETn)
  begin
      if(!ARESETn)
      begin
          BRESP_TYPE <= 2'b00 ;
      end
      else if(~bvalidr)
      begin
            if(AWVALID & AWREADY)
                begin
                    case(AWLOCK)
                    2'b00: BRESP_TYPE <= {brespi,1'b0};
                    2'b01: BRESP_TYPE <= 2'b01 ;
                    2'b10: BRESP_TYPE <= {brespi,1'b0};
                    2'b11: BRESP_TYPE <= {brespi,1'b0};
                    default:BRESP_TYPE <= {brespi,1'b0};
                    endcase
                end
            else
            begin
                BRESP_TYPE <= BRESP_TYPE | {brespi,1'b0} ;
            end
      end
  end

  // -------------------
  // HOLD REQUESTS

  always @ (posedge ACLK or negedge ARESETn)
    if (!ARESETn) begin
      bidr[ID_MAX:0] <=   ID_WIDTH*{1'b0};
      bvalidr        <=   1'b0;
//    brespr         <=   1'b0;
      wreadyr        <=   1'b0;
      AddrValidr     <=   1'b0;
    end else begin // if (!ARESETn)
      bidr[ID_MAX:0] <=   DataLast ? AddrId[ID_MAX:0] : bidr[ID_MAX:0];
      bvalidr        <=   bvalidr  ? (!BREADY)        : (DataLast & AddrValid);
 //   brespr         <=   bvalidr  ? (brespr)         : ((AWVALID & AWREADY) ? brespi : brespi | brespr);
      wreadyr        <=   !AddrLast & WREADY;
      AddrValidr     <=   AddrValid;
    end //

  // -------------------
  // AWID WID check
  // -------------------
  // The following logic ensures that AWID and WID are the same
  // for a given transaction.

  //assign wrongwid = WVALID & WREADY & (AddrId!=WID);
  assign wrongwid = 1'b0;
  // -------------------
  // HOLD REQUESTS
  // -------------------
  // Drops Ready low when a request has been accepted until last appears

  IntMemReqHold u_IntMemReqHold
    (
     // outputs
     .AxVALIDhold(AWVALIDhold),
     .AxREADYhold(AWREADYhold),
     .AxREADYhold_c (),
     // inputs
     .ACLK(ACLK),
     .ARESETn(ARESETn),
     .AxVALID(AWVALID),
     .AxREADY(AWREADYi),
     .xREADY(BREADY),
     .xVALID(BVALID),
     .xLAST(1'b1)
     );

endmodule
