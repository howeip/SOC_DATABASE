module IntMemRdCtrl (
                   // Global Signals
                   ACLK,
                   ARESETn,

                   // Read Address Channel
                   ARID,
                   ARADDR,
                   ARLEN,
                   ARSIZE,
                   ARBURST,
                   ARVALID,
                   ARREADY,
                   ARLOCK,

                   // Read Channel
                   RID,
                   RLAST,
                   RDATA,
                   RRESP,
                   RVALID,
                   RREADY,

                   // Handshake signals between AXI read interface and
                   // Slave function modules
                   RAddrValid,
                   RAddrReady,
                   RAddrOut,
                   RData,
                   RResp
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

// --========================= End ===========================================

//------------------------------------------------------------------------------
// Parameters
//------------------------------------------------------------------------------
// user parameters
  parameter		DATA_WIDTH = 128;           // Data bus width, default = 128-bit
  parameter		ID_WIDTH   = 4;             // ID bus width, default = 4-bit

// Do not override the following parameters: they must be calculated exactly
// as shown below
  localparam		DATA_MAX   = DATA_WIDTH-1;  // DATA max index
  localparam		ID_MAX     = ID_WIDTH-1;    // ARID/RID max index

//------------------------------------------------------------------------------
// Port declarations
//------------------------------------------------------------------------------
// Global Signals
  input			            ACLK;       // Clock input
  input			            ARESETn;    // Reset async input active low

// Read Address Channel
  input [ID_MAX:0]	    ARID;       // Read address ID
  input [31:0]	        ARADDR;     // Read address
  input [7:0]		        ARLEN;      // Read burst length
  input [2:0]		        ARSIZE;     // Read burst size
  input [1:0]		        ARBURST;    // Read burst type
  input			            ARVALID;    // Read address valid
  output		            ARREADY;    // Read address ready
  input [1:0]		            ARLOCK;    // Read address ready
                        
// Read Channel         
  output [ID_MAX:0]	    RID;        // Read response ID
  output		            RLAST;      // Read last
  output [DATA_MAX:0]	  RDATA;      // Read data
  output [1:0]   	      RRESP;      // Read response
  output		            RVALID;     // Read valid
  input			            RREADY;     // Read ready

// Handshake signals between read interface and Slave function modules
  output		            RAddrValid; // Read address to Slave block is valid
  input			            RAddrReady; // Read address is consumed in Slave block
  output [31:0]	        RAddrOut;   // Read address to Slave block
  input			            RResp;      // Read response for RAddrValid
  input [DATA_MAX:0]	  RData;      // Read data for RAddrValid

//----------------------------------------------------------------------------
// Signal declarations
//----------------------------------------------------------------------------
// I/O wires
// Read Channel
  wire [ID_MAX:0]	      RID;        // Read response ID
  wire			            RLAST;      // Read last
  wire [DATA_MAX:0]	    RDATA;      // Read data
  wire [1:0]		        RRESP;      // Read response
  wire			            RVALID;     // Read valid
  wire			            RREADY;     // Read ready
                        
  //                    
  wire			            ARVALIDhold;
  wire			            ARREADYhold;

// Handshake signals between read interface and Slave function modules
  wire			            RAddrValid; // Read address to Slave block is valid
  wire			            RAddrReady; // Read address is consumed in Slave block
  wire [31:0]		        RAddrOut;   // Read address to Slave block
  wire			            RResp;      // Read response for RAddrValid
  wire [DATA_MAX:0]  	  RData;      // Read data for RAddrValid
                        
  wire [31:0]		        AddrOut;
  wire [31:0]		        MaskAddr;
  wire [31:0]		        AddrInv;
  wire [ID_MAX:0]	      AddrId;
  wire			            AddrLast;
  wire			            AddrValid;
  wire			            AddrReady;
  wire			            DataLast;
                        
  reg			              DataValid;
  reg			              RREADYr;
  reg			              AddrValidr;
  reg			              DataLastr;
  wire [DATA_MAX:0]	    RDatai;
  reg  [DATA_MAX:0]	    RDatar;
  wire [31:0]		        AddrBitUsed;
  reg  [127:0]		      ShiftMe;
  reg  [DATA_MAX:0]	    MaskDatar;
  wire [DATA_MAX:0]	    MaskAndDataX;
  wire [DATA_MAX:0]	    MaskOrDataX;
  reg  [DATA_MAX:0]	    RDATAr;
  reg			              ValidReqr;
  wire [2:0]		        Size;
  reg			              selRDATAr;
  wire                  AxREADYhold_c;

  reg [1:0] RRESP_TYPE ;
  
//============================================================================
//                           Main body of code
//============================================================================

  // -------------------
  // output to slave
  // -------------------
  assign RAddrValid         = AddrValid;
  assign RAddrOut[31:0]     = AddrOut[31:0];

  assign AddrReady          = RAddrReady;

  // -------------------
  // outputs to AXI read address channel
  // -------------------
  assign ARREADY            = ARREADYhold;

  // -------------------
  // outputs to AXI read data channel
  // -------------------
  assign RID[ID_MAX:0]      = AddrId [ID_MAX : 0];
  assign RLAST              = DataLast | DataLastr;
  //assign RRESP[1:0]         = { RResp,1'b0 };
  assign RRESP[1:0]         = RRESP_TYPE;
  assign RVALID             = DataValid;

  // RDATA selection
  assign RDATA[DATA_MAX:0]  = RDatai[DATA_MAX:0] ;

  assign RDatai[DATA_MAX:0]  = (AddrValidr)
                                ? RData[DATA_MAX:0]
                                : RDatar[DATA_MAX:0];

  // -------------------
  // Address Unpacker
  // -------------------
  IntMemAddrGen #(ID_WIDTH) u_IntMemAddrGen
    (
     // Global Inputs
     .ACLK     (ACLK),
     .ARESETn  (ARESETn),
     // AXI interface
     .AxADDR   (ARADDR),
     .AxSIZE   (ARSIZE),
     .AxBURST  (ARBURST),
     .AxLEN    (ARLEN),
     .AxID     (ARID),
     .AxVALID  (ARVALIDhold),
     .AxREADY  (ARREADYhold),
     // Unpacked address interface
     .AddrOut  (AddrOut),
     .AddrId   (AddrId),
     .AddrLast (AddrLast),
     .AddrValid(AddrValid),
     .DataLast (DataLast),

     .xVALID   (RVALID),
     .xREADY   (RREADY)
     );

  always @ (posedge ACLK or negedge ARESETn)
    if (!ARESETn) begin
      DataValid  <=   1'b0;
      RREADYr    <=   1'b1;
      AddrValidr <=   1'b0;
      DataLastr  <=   1'b0;
      RDatar     <=   DATA_WIDTH*{1'b0};
      RDATAr     <=   DATA_WIDTH*{1'b0};
      ValidReqr  <=   1'b0;
      selRDATAr  <=   1'b0;
    end else begin
      DataValid  <=   	(AddrReady & AddrValid) ? 1'b1 :
	                         (RREADY ? 1'b0 : DataValid);
      RREADYr    <=   RREADY;
      AddrValidr <=   AddrValid;
      DataLastr  <=   (RREADY | (RVALID & ~DataLastr)) ? (DataLast & ~RREADY) : DataLastr;
      RDatar     <=   AddrValidr        ? RData    : RDatar;
      RDATAr     <=   !selRDATAr        ? RDATA    : RDATAr;
      ValidReqr  <=   ARVALIDhold & ARREADYhold;
      selRDATAr  <=   !AddrValid | (selRDATAr&!RREADY);
    end //

  always @ (posedge ACLK or negedge ARESETn)
  begin
      if(!ARESETn)
      begin
          RRESP_TYPE <= 2'b00 ;
      end
      else if(ARVALID & ARREADY)
      begin
          case(ARLOCK)
              2'b00: RRESP_TYPE <= 2'b00 ;
              2'b01: RRESP_TYPE <= 2'b01 ;
              2'b10: RRESP_TYPE <= 2'b00 ;
              2'b11: RRESP_TYPE <= 2'b00 ;
              default:RRESP_TYPE <= 2'b00 ;
          endcase
      end
  end

  // -------------------
  // HOLD REQUESTS
  // -------------------
  // Drops Ready low when a request has been accepted until last appears
  IntMemReqHold U_IntMemReqHold
    (
     // outputs
     .AxVALIDhold     (ARVALIDhold),
     .AxREADYhold     (ARREADYhold),
     .AxREADYhold_c   (AxREADYhold_c),
     // inputs
     .ACLK            (ACLK),
     .ARESETn         (ARESETn),
     .AxVALID         (ARVALID),
     .AxREADY         (RAddrReady),
     .xREADY          (RREADY),
     .xVALID          (RVALID),
     .xLAST           (RLAST)
   );

endmodule
