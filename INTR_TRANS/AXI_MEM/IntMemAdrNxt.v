module IntMemAdrNxt
  (
  // inputs
    AddrIn,
    AxLEN,
    AxSIZE,
    AxBURST,
  // output
    AddrOut
  );

  input  [19 : 0] AddrIn;    //  Current address
  input   [7 : 0] AxLEN;     //  Burst length
  input   [2 : 0] AxSIZE;    //  Burst size
  input   [1 : 0] AxBURST;   //  Burst type

  output [19 : 0] AddrOut;   //  Next address

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

  wire   [19 : 0] AddrIn;
  wire    [7 : 0] AxLEN;
  wire    [2 : 0] AxSIZE;
  wire    [1 : 0] AxBURST;
  wire   [19 : 0] AddrOut;

//------------------------------------------------------------------------------
// Signal declarations
//------------------------------------------------------------------------------
  reg  [19 : 0] OffsetAddr; //  shifted address
  wire [19 : 0] IncrAddr;   //  incremented address
  wire [19 : 0] WrapAddr;   //  wrapped address
  wire [19 : 0] MuxAddr;    //  address selected by burst type
  reg  [19 : 0] CalcAddr;   //  final calculated address

//-------------------------------------------------------------------------
//
//  Main body of code
//=================
//
//-------------------------------------------------------------------------

//-------------------------------------------------------------------------
//  Combinational address shift right
//
//  OffsetAddr indicates the address bits of interest, depending on AxSIZE
//-------------------------------------------------------------------------
  always @ (AxSIZE or AddrIn)
  begin
    case (AxSIZE)
      `AXI_ASIZE_8   : OffsetAddr = AddrIn[19:0];
      `AXI_ASIZE_16  : OffsetAddr = { 1'b0 ,   AddrIn[19:1] };
      `AXI_ASIZE_32  : OffsetAddr = { 2'b00,   AddrIn[19:2] };
      `AXI_ASIZE_64  : OffsetAddr = { 3'b000,  AddrIn[19:3] };
      `AXI_ASIZE_128 : OffsetAddr = { 4'b0000, AddrIn[19:4] };
      `AXI_ASIZE_256 : OffsetAddr = { 5'b00000,AddrIn[19:5] };
      default        : OffsetAddr = {20{1'bx}}; // illegal switch
    endcase
  end

  // increment the address
  //assign IncrAddr = OffsetAddr + 1'b1;
 
  
  // synopsys dc_script_begin
  // set_implementation pparch u0_IncrAddr_dw
  // synopsys dc_script_end
  // instantiate DW0c_inc 
`ifdef  FPGA
assign IncrAddr = OffsetAddr + 1'b1;
`else
  DW01_inc #(20) 
  u0_IncrAddr_dw
 (
    .A   ( OffsetAddr ),
    .SUM ( IncrAddr   )
  );
`endif


//-------------------------------------------------------------------------
//  Address wrapping
//
//  The address of the next transfer should wrap on the next transfer if the
//  boundary is reached. Assumes AxSIZE = 2, 4, 8, or 16.
//-------------------------------------------------------------------------
  // Upper bits of wrapped address remain static
  assign WrapAddr[19:8] = OffsetAddr[19:8];

  // Wrap lower bits according to length of burst
  assign WrapAddr[7:0]  = (AxLEN & IncrAddr[7:0]) | (~AxLEN & OffsetAddr[7:0]);

//-------------------------------------------------------------------------
//  Combinational address multiplexor
//
//  Choose the final offset address depending on burst type
//-------------------------------------------------------------------------

  assign MuxAddr = AxBURST == `AXI_ABURST_WRAP ? WrapAddr : IncrAddr;
  

//-------------------------------------------------------------------------
//  Combinational address shift left
//
//  Shift the bits of interest to the correct bits of the resultant address
//-------------------------------------------------------------------------
  always @ (AxSIZE or MuxAddr)
  begin
    case (AxSIZE)
      `AXI_ASIZE_8   : CalcAddr = MuxAddr;
      `AXI_ASIZE_16  : CalcAddr = {MuxAddr [ 18:0],1'b0    };
      `AXI_ASIZE_32  : CalcAddr = {MuxAddr [ 17:0],2'b00   };
      `AXI_ASIZE_64  : CalcAddr = {MuxAddr [ 16:0],3'b000  };
      `AXI_ASIZE_128 : CalcAddr = {MuxAddr [ 15:0],4'b0000 };
      `AXI_ASIZE_256 : CalcAddr = {MuxAddr [ 14:0],5'b00000};
      default        : CalcAddr = {20{1'bx}}; // illegal switch
    endcase
  end

  assign AddrOut = (AxBURST == `AXI_ABURST_FIXED) ? AddrIn : CalcAddr;
  
endmodule
