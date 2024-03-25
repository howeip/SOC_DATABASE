module IntMemAddrGen
  (
   // Global Inputs
   ACLK,         // global AXI clock
   ARESETn,      // global AXI reset

   // AXI interface
   AxADDR,       // transaction address
   AxSIZE,       // transaction size
   AxBURST,      // transaction burst type
   AxLEN,        // transaction length
   AxID,         // transaction id
   AxVALID,      // valid transaction
   AxREADY,      // AxiUnpackAddr accepted transaction

   // Unpacked address interface
   AddrOut,      // incrementing address
   AddrId,       // incrementing address id
   AddrLast,     // indicates last address in burst
   AddrValid,    // incrementing address is valid
   DataLast,     // Indicates Last Data in burst

   xVALID,       // Data is valid
   xREADY        // Indicates Data accepted
   );

//------------------------------------------------------------------------------
// Parameters
//------------------------------------------------------------------------------
  parameter	    ID_WIDTH   = 4;           // ID bus width, default = 4-bit
  localparam	    ID_MAX     = ID_WIDTH-1;

//----------------------------------------------------------------------------
// Port declarations
//----------------------------------------------------------------------------

  // Global signals
  input		          ACLK;        // global AXI clock
  input		          ARESETn;     // global AXI reset

  // AXI Address Channel
  input [31:0]	    AxADDR;      // transaction address
  input [2:0]	      AxSIZE;      // transaction size
  input [1:0]	      AxBURST;     // transaction burst type
  input [7:0]	      AxLEN;       // transaction length
  input [ID_MAX:0]  AxID;        // transaction id
  input		          AxVALID;     // valid transaction
  input		          AxREADY;     // AxiUnpackAddr accepted transaction

  // Unpacked address interface
  output [31:0]	    AddrOut;     // incrementing address
  output [ID_MAX:0] AddrId;      // incrementing address id
  output	          AddrLast;    // indicates last address in burst
  output	          AddrValid;   // incrementing address is valid
  output	          DataLast;    // Indicates Last Data in burst

  // AXI Data Channel
  input		          xVALID;       // Data is valid
  input		          xREADY;       // Indicates Data accepted

//----------------------------------------------------------------------------
// Signal declarations
//----------------------------------------------------------------------------
  // I/O wires

  // AXI interface
  wire [31:0]	      AxADDR;       // transaction address
  wire [2:0]	      AxSIZE;       // transaction size
  wire [1:0]	      AxBURST;      // transaction burst type
  wire [7:0]	      AxLEN;        // transaction length
  wire [ID_MAX:0]   AxID;         // transaction id
  wire		          AxVALID;      // valid transaction
  wire		          AxREADY;      // AxiUnpackAddr accepted transaction

  // Unpacked address interface
  wire [31:0]	      AddrOut;     // incrementing address
  wire [ID_MAX:0]   AddrId;      // incrementing address id
  wire		          AddrLast;    // indicates last address in burst
  wire		          AddrValid;   // incrementing address is valid
  wire		          DataLast;    // indicates last data in burst

  // AXI Data Channel
  wire		          xVALID;       // Data is valid
  wire		          xREADY;       // Indicates Data accepted

  // internal signals

  // AddrOut generation
  reg [31:0]	      AxADDRmuxr;
  reg [31:0]	      AxADDRr;
  reg [7:0]	        AxLENr;
  reg [ID_MAX:0]    AxIDr;
  reg [2:0]	        AxSIZEr;
  reg [1:0]	        AxBURSTr;
  wire [31:0]	      AxADDRmux;
  wire [7:0]	      AxLENmux;
  wire [ID_MAX:0]   AxIDmux;
  wire [2:0]	      AxSIZEmux;
  wire [1:0]	      AxBURSTmux;
  wire [31:0]	      AxADDRinc;
  wire		          enaddrmuxr;    // enable address register

  // AddrLast generation
  wire [7:0]	      AddrCount;
  reg [7:0]	        AddrCountr;
  wire		          enaddrcount; // enable addrcount register

  // DataLast generation
  wire [7:0]	      DataCount;
  reg [7:0]	        DataCountr;
  wire		          endatacount; // enable addrcount register

  // Valid and Ready logic
  wire		          validreq;    // valid request
  wire		          validresp;   // valid response
  wire		          validdata;   // valid response and not last response
  wire		          lastdata;    // valid and last response
  reg 		          nlastr;

//  ============================================================================
//                           Main body of code
//  ============================================================================

  // valid request
  assign 	      validreq  = AxVALID & AxREADY;
  // valid response from slave
  assign        validresp = xVALID & xREADY;
  // valid not-last response from slave
  assign        validdata = xVALID & xREADY & !DataLast;
  // valid last response from the slave
  assign        lastdata  = xVALID & xREADY & DataLast;

  // --------------------------------------
  // Address and control signal registering
  // --------------------------------------
  // address signal registers
  always @ (posedge ACLK or negedge ARESETn)
    if (!ARESETn)
      AxADDRmuxr[31:0]    <=   32'h00000000;
    else if (enaddrmuxr)
      AxADDRmuxr[31:0]    <=   AxADDRmux[31:0];

  assign 	enaddrmuxr = validreq | validdata;

  // control signal registers
  always @ (posedge ACLK or negedge ARESETn)
    if (!ARESETn) begin
      AxADDRr[31:0]   <=   32'h0000_0000;
      AxLENr[7:0]     <=   8'b0000;
      AxSIZEr[2:0]    <=   3'b000;
      AxBURSTr[1:0]   <=   2'b0;
      AxIDr[ID_MAX:0] <=   ID_MAX*{1'b0};
    end
    else if (validreq) begin
      AxADDRr[31:0]   <=   AxADDR;
      AxLENr[7:0]     <=   AxLEN[7:0];
      AxSIZEr[2:0]    <=   AxSIZE[2:0];
      AxBURSTr[1:0]   <=   AxBURST[1:0];
      AxIDr[ID_MAX:0] <=   AxID[ID_MAX:0];
    end

  assign AxLENmux    = validreq ? AxLEN   : AxLENr;
  assign AxSIZEmux   = validreq ? AxSIZE  : AxSIZEr;
  assign AxBURSTmux  = validreq ? AxBURST : AxBURSTr;
  assign AxIDmux     = validreq ? AxID    : AxIDr;

// -----------------------------------------------------------------------------
// AddrOut and AddrId generation
// -----------------------------------------------------------------------------
  assign AddrOut[31:0]      = AxADDRmux[31:0];
  assign AddrId[ID_MAX:0]   = AxIDmux[ID_MAX:0];

  assign AxADDRmux[31:0]    = validreq
                              ? AxADDR[31:0]
                              : ((validresp)
                                  ? AxADDRinc[31:0]
                                  : AxADDRmuxr[31:0]);
                                  
  // -------------------
  // Address Incrementor
  // -------------------
IntMemAdrNxt u_IntMemAdrNxt
    (// inputs
     .AddrIn         (AxADDRmuxr[19:0]),
     .AxLEN          (AxLENmux[7:0]),
     .AxSIZE         (AxSIZEmux[2:0]),
     .AxBURST        (AxBURSTmux[1:0]),
     // outputs
     .AddrOut        (AxADDRinc[19:0])
     );
  assign 	AxADDRinc[31:20] = AxADDRmuxr[31:20];

// -----------------------------------------------------------------------------
// AddrValid logic
// -----------------------------------------------------------------------------
  assign AddrValid = validreq | ( validresp && !(AddrCountr[7:0]==8'h0) );

// -----------------------------------------------------------------------------
// AddrLast logic
// -----------------------------------------------------------------------------
  assign AddrLast = (( AddrCount[7:0] == 8'h0 ) & validreq                            )   // first and last resp
                  | (( AddrCount[7:0] == 8'h0 ) & validresp & ( AddrCountr[7:0]!=8'h0 )); // validresp and last

  assign AddrCount =
    (validreq | (AddrCountr == 0)) ? AxLENmux
                                   : (AddrCountr[7:0] - 8'h1);

  always @ (posedge ACLK or negedge ARESETn)
    if (!ARESETn)
      AddrCountr[7:0] <=   8'h0;
    else if (enaddrcount)
      AddrCountr[7:0] <=   AddrCount[7:0];

  assign enaddrcount = validreq | validresp;

// -----------------------------------------------------------------------------
// DataLast logic
// -----------------------------------------------------------------------------
  assign DataLast = validreq ? (AxLENmux==8'h0 & validresp) :  nlastr;

  assign DataCount[7:0] =  ((DataCountr==8'h0) ?              AxLENmux
                                              : (validreq ? ( AxLENmux - {7*{1'b0},(validresp)})
                                                          : (DataCountr - 8'h1)));

  always @ (posedge ACLK or negedge ARESETn)
    if (!ARESETn)
      DataCountr[7:0] <=   8'h0;
    else if (endatacount)
      DataCountr[7:0] <=   DataCount[7:0];

  assign endatacount = validresp;

  always @ (posedge ACLK or negedge ARESETn)
    if (!ARESETn)
      nlastr   <=   1'b1;
    else
      nlastr   <=   validresp ? (DataCount==8'h1)
                                         : (validreq ? (AxLENmux==8'h0)
                                                     : (!xVALID & nlastr) );                                            
endmodule
