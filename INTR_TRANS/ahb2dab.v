module ahb2dab(
  HCLK, 
  HRESETn, 
  HADDR, 
  HTRANS,
  HSIZE,
  HBURST, 
  HWRITE, 
  HWDATA, 
  HSELAHB,            
  HREADYin, 
  HRDATA, 
  HREADYout, 
  HRESP,
   
  rd,
  wr,
  addr,
  datain,
  dataout,
  ready,
  sel,
  selh 
  ); 
 //-----------------------------------------------------------------------------------------
  parameter  DWIDTH    = 64;   
  parameter
  SZ_BYTE = 3'b000,
  SZ_HALF = 3'b001,
  SZ_WORD = 3'b010,
  SZ_DWORD = 3'b011;
 //-------------------------------------------------------------------------------------------
  input                  HCLK;
  input                  HRESETn;
  input  [31:0]          HADDR;
  input   [1:0]          HTRANS;
  input   [2:0]          HSIZE;
  input   [2:0]          HBURST;
  input                  HWRITE;
  input  [DWIDTH-1:0]    HWDATA;
  input                  HSELAHB;
  input                  HREADYin;
     
  output [DWIDTH - 1:0]  HRDATA;
  output                 HREADYout;
  output  [1:0]          HRESP;
     
  output                 rd;
  output                 wr;
  output [31:0]          addr;
  output [DWIDTH-1:0]    datain;
  input  [DWIDTH-1:0]    dataout;
  input                  ready;
  output [3:0]           sel;
  output [3:0]           selh;     

  reg    [3:0]           isel;
  reg    [3:0]           iselh;
  reg                    HREADYout;
  reg    [DWIDTH-1:0]    HRDATA;

  reg                    rd;
  reg                    wr;
  reg    [31:0]          addr;
  reg    [DWIDTH-1:0]    datain;
  reg    [3:0]           sel;
  reg    [3:0]           selh;                    
 
wire                htrans_val  ; 
wire                hwr_val     ;
wire                hrd_val     ;
reg                 wait_rdata  ; 
reg  [41:0]         hctrl_info  ; 
           
wire [DWIDTH+41:0]  fifo_din    ;
wire [DWIDTH+41:0]  fifo_dout   ;
wire                fifo_full   ;
wire                fifo_afull  ;
wire                fifo_empty  ;
wire                fifo_rd     ;
wire                fifo_wr     ;
reg                 wdata_ph    ;
reg                 rdata_ph    ;
wire                rd_after_wr ;
reg                 rd_pending  ; 
wire                sel_wr_info ;
wire                sel_rd_info ;
wire                sel_prd_info;
reg                 trans_p     ; 
//------------------------------------------------------------------
assign htrans_val  = HREADYin & HSELAHB & HTRANS[1];
assign hwr_val     = htrans_val & HWRITE;
assign hrd_val     = htrans_val & (HWRITE == 1'b0) & HREADYout;
assign rd_after_wr = wdata_ph & hrd_val; 

always @(posedge HCLK or negedge HRESETn) begin 
    if (!HRESETn)
        HREADYout <= 1'b1;
    else if (hrd_val)
        HREADYout <= 1'b0;
    else if (rdata_ph)
        HREADYout <= ready & wait_rdata;
    else if (hwr_val)
        HREADYout <= ~fifo_afull;
    else if (!fifo_afull)
        HREADYout <= 1'b1;
end 

always @(posedge HCLK or negedge HRESETn) begin 
    if (!HRESETn)
        HRDATA <= {{DWIDTH}{1'b0}};
    else if (wait_rdata & ready)
        HRDATA <= dataout;
end 
assign HRESP = 2'h0;
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn)
        rdata_ph <= 1'b0;
    else if (hrd_val)
        rdata_ph <= 1'b1;
    else if (ready & wait_rdata)
        rdata_ph <= 1'b0;
end 
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn)
       wait_rdata <= 1'b0;
    else if (rd)
       wait_rdata <= 1'b1;
    else if (ready)
       wait_rdata <= 1'b0;
end 

always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn)
        wdata_ph <= 1'b0;
    else if (hwr_val)
        wdata_ph <= 1'b1;
    else if (HREADYin)
        wdata_ph <= 1'b0;
end
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn)
        rd_pending <= 1'b0;
    else if (rd_after_wr)
        rd_pending <= 1'b1;
    else if (!fifo_full)
        rd_pending <= 1'b0;
end
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn)
        hctrl_info <= 42'h0;
    else if (htrans_val)
        hctrl_info <= {HADDR,iselh,isel,HWRITE,!HWRITE};
end 

assign sel_prd_info  = rd_pending & !fifo_full;
assign sel_wr_info  = wdata_ph & HREADYin;
assign sel_rd_info = hrd_val & (!rd_after_wr);

assign fifo_wr  = sel_wr_info | sel_rd_info | sel_prd_info;
assign fifo_din = ({(DWIDTH+42){sel_wr_info}} & {HWDATA,hctrl_info}) |
                  ({(DWIDTH+42){sel_rd_info}} & {64'h0,HADDR,iselh,isel,HWRITE,!HWRITE}) | 
                  ({(DWIDTH+42){sel_prd_info}}& {64'h0,hctrl_info}) ;

always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn)
        trans_p <= 1'b0;
    else if (rd|wr)
        trans_p <= 1'b1;
    else if (ready)
        trans_p <= 1'b0;
end 

always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin 
        wr     <= 1'b0;
        rd     <= 1'b0;
        addr   <= 32'h0;
        datain <= 64'h0;
        sel    <= 4'h0; 
        selh   <= 4'h0;
    end 
    else if (((!(trans_p|wr|rd))| ready) & (!fifo_empty))begin 
        wr    <= fifo_dout[1];
        rd    <= fifo_dout[0]; 
        addr  <= fifo_dout[41:10];
        datain<= fifo_dout[DWIDTH+41:42];
        sel   <= fifo_dout[5:2];
        selh  <= fifo_dout[9:6];
    end 
    else begin 
        wr <= 1'b0;
        rd <= 1'b0;
    end 
end 
       
 ahb2mem_fifo 
#(  .DWIDTH (DWIDTH+42) )
iahb2mem_fifo(
    .i_clk         (HCLK    ),   
    .i_rst_n       (HRESETn ),
    .i_fifo_rd     (fifo_rd ),    
    .i_fifo_wr     (fifo_wr ),    
    .i_fifo_din    (fifo_din ), 

    .o_fifo_full   (fifo_full  ),
    .o_fifo_afull  (fifo_afull ),
    .o_fifo_empty  (fifo_empty ),  
    .o_fifo_dout   (fifo_dout  ) 
);

assign fifo_rd = ((!(trans_p | wr|rd)) | ready) & (!fifo_empty);
                 
always@(*) begin
  isel  = 4'b0000;
  iselh = 4'b0000;
  if (htrans_val) begin 
      case(HSIZE)
          SZ_DWORD: begin
            if(DWIDTH == 64) begin 
               isel  = 4'b1111;
               iselh = 4'b1111;
            end
          end 
          SZ_WORD : begin
            if(DWIDTH == 32) begin
              isel  = 4'b1111;
              iselh = 4'b0000;
            end
            else if(DWIDTH == 64) begin
              isel  = HADDR[2] ? 4'b0000 : 4'b1111;
              iselh = HADDR[2] ? 4'b1111 : 4'b0000;
            end
          end   
          SZ_HALF : begin
            if(DWIDTH == 32) begin
               isel = HADDR[1] ? 4'b1100 : 4'b0011;
               iselh= 4'b0000;
            end
            else if(DWIDTH == 64) begin   
              case(HADDR[2:1])
                 2'b00:   {iselh,isel} = 8'b0000_0011;
                 2'b01:   {iselh,isel} = 8'b0000_1100;
                 2'b10:   {iselh,isel} = 8'b0011_0000;
                 2'b11:   {iselh,isel} = 8'b1100_0000;
                 default: {iselh,isel} = 8'b0000_0000; 
             endcase
            end
          end
          SZ_BYTE : begin
            if(DWIDTH == 32) begin
              case(HADDR[1:0])
                2'b00:   {iselh,isel} = 8'b0000_0001;
                2'b01:   {iselh,isel} = 8'b0000_0010;
                2'b10:   {iselh,isel} = 8'b0000_0100;
                2'b11:   {iselh,isel} = 8'b0000_1000;
                default: {iselh,isel} = 8'b0000_0000;
              endcase  
            end
            else if(DWIDTH == 64) begin
             case(HADDR[2:0])
                3'b000:  {iselh,isel} = 8'b0000_0001;
                3'b001:  {iselh,isel} = 8'b0000_0010;
                3'b010:  {iselh,isel} = 8'b0000_0100;
                3'b011:  {iselh,isel} = 8'b0000_1000;
                3'b100:  {iselh,isel} = 8'b0001_0000;
                3'b101:  {iselh,isel} = 8'b0010_0000;
                3'b110:  {iselh,isel} = 8'b0100_0000;
                3'b111:  {iselh,isel} = 8'b1000_0000;
                default: {iselh,isel} = 8'b0000_0000;
              endcase
            end  
          end
          default:  begin
            isel  = 4'b0000;
            iselh = 4'b0000;
          end
      endcase
  end
  else 
    {iselh,isel} = 8'h0;
end      

endmodule

