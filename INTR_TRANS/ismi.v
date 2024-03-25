module ismi(
   // global signals
   input                hclk        ,
   input                hresetn     ,
   input                hsel        ,

   // AHB interface
   input  [31:0]        haddr       ,
   input  [31:0]        hwdata      ,
   input  [1:0]         htrans      ,
   input  [2:0]         hburst      ,
   input  [1:0]         hsize       ,
   input                hwrite      ,
   input                hreadyin    ,
   output reg [31:0]    hrdata      ,
   output               hreadyout   ,
   output [1:0]         hresp       ,

   // memory interface
   input  [31:0]        mrdata      ,
   output [29:0]        maddr       ,
   output               mcen        ,
   output reg [31:0]    mwdata      ,
   output reg [3:0]     mwe         
);

// state enumeration
parameter   IDLE    =0  ;
parameter   WRPA    =1  ;
parameter   WAIT    =2  ;         //wait during read start as same as write data phase
parameter   RDPA1   =3  ;
parameter   RDPD    =4  ;
parameter   RDPR    =5  ;
parameter   BRBZ    =6  ;
parameter   RDPA2   =7  ;

// burst parameter
parameter HBURST_SINGLE  =3'b000;
parameter HBURST_INCR    =3'b001;
parameter HBURST_WRAP4   =3'b010;
parameter HBURST_INCR4   =3'b011;
parameter HBURST_WRAP8   =3'b100;
parameter HBURST_INCR8   =3'b101;
parameter HBURST_WRAP16  =3'b110;
parameter HBURST_INCR16  =3'b111;

// registers
reg [7:0]   cstate;
reg [7:0]   nstate;
reg [31:0]  haddrReg;
reg [31:0]  haddr_wr_reg2;
reg [1:0]   hsizeReg;
reg         write_sram;

// reg [31:0]  mwdata;
// reg [3:0]   mwe;

wire          ReadValid;
wire          WriteValid;
wire          is_noseq;
wire          is_seq;
wire          is_idle;
wire          is_busy;
wire          burst_reading;

assign ReadValid     = hsel & hreadyin & ~hwrite & htrans[1];
assign WriteValid    = hsel & hreadyin &  hwrite & htrans[1];
assign is_idle       = hsel & hreadyin & (htrans[1:0] == 2'b00);
assign is_busy       = hsel & hreadyin & (htrans[1:0] == 2'b01);
assign is_noseq      = hsel & hreadyin & (htrans[1:0] == 2'b10);
assign is_seq        = hsel & hreadyin & (htrans[1:0] == 2'b11);
assign burst_reading = hsel & ~hwrite  & (hburst[2:0]!=HBURST_SINGLE);

// FSM sequential
always @(posedge hclk or negedge hresetn)
  begin
  if(!hresetn)
      cstate <= 8'h01;
  else
      cstate <= nstate;
end

// FSM combinational
always @( /*AUTOSENSE*/ReadValid or WriteValid or burst_reading
      or cstate or is_busy or is_noseq or is_seq )
  begin
  nstate=8'h00;
  case (1'b1)
      cstate[IDLE]:
          begin
        if(WriteValid)
          nstate[WRPA]=1;
        else if(ReadValid&is_noseq)
          nstate[RDPA1]=1;
        else
          nstate[IDLE]=1;
      end

      cstate[WRPA]:
          begin
        if(WriteValid)
          nstate[WRPA]=1;
        else if(ReadValid&is_noseq)
          nstate[RDPA2]=1;
        else
          nstate[IDLE]=1;
      end

      cstate[RDPA2]:
          begin
        nstate[WAIT]=1;
      end

    cstate[WAIT]:
          begin
      nstate[RDPD]=1;
    end

      cstate[RDPA1]:
          begin
        nstate[RDPD]=1;
      end

      cstate[RDPD]:
          begin
        nstate[RDPR]=1;
      end

      cstate[RDPR]:
          begin
        if(ReadValid&is_noseq)
          nstate[RDPA1]=1;
      else if(WriteValid&is_noseq)
          nstate[WRPA]=1;
        else if(is_busy&burst_reading)
          nstate[BRBZ]=1;
        else if(is_seq&burst_reading)
          nstate[RDPR]=1;
        else
          nstate[IDLE]=1;
      end

      cstate[BRBZ]:
          begin
      if(is_busy)
          nstate[BRBZ]=1;
        else if(ReadValid&is_noseq)
          nstate[RDPA1]=1;
      else if(WriteValid&is_noseq)
          nstate[WRPA]=1;
        else if(is_seq)
          nstate[RDPR]=1;
        else
          nstate[IDLE]=1;
      end

    default:
      nstate[IDLE]=1;
  endcase
end


// AHB output signals
// hreadyout
assign hreadyout= cstate[IDLE]|cstate[WRPA]|cstate[RDPR]|cstate[BRBZ];

// hrdata
always @(posedge hclk or negedge hresetn)
  begin
  if(!hresetn)
      hrdata <= 32'h0;
  else if(cstate[RDPR]|(nstate[RDPR]&~cstate[BRBZ]))
      hrdata <= mrdata[31:0];
end

// hresp
assign hresp[1:0] =2'b00;


// Memory output signals
// mwdata
always @(posedge hclk or negedge hresetn)
  begin
  if(!hresetn)
      mwdata[31:0] <= 32'h0;
  else if(cstate[WRPA])
      mwdata[31:0] <= hwdata[31:0];
end

// write cycle of SRAM
always @(posedge hclk or negedge hresetn)
  begin
  if(!hresetn)
    write_sram <= 1'b0;
  else
    write_sram <= cstate[WRPA];
end

// mcen
assign mcen = (cstate[RDPA1]|cstate[WAIT]|write_sram) ? 1'b0:
              (burst_reading&~cstate[IDLE])? 1'b0: 1'b1;

// address latch
always @(posedge hclk or negedge hresetn)
  begin
   if(!hresetn)
       haddrReg<=0;
   else if(nstate[WRPA]|nstate[RDPA1]|nstate[RDPA2])
       haddrReg<=haddr[31:0];
   else if(burst_reading&(nstate[RDPD]|nstate[RDPR]))
         begin
     case(hburst)
         HBURST_INCR,HBURST_INCR4,HBURST_INCR8,HBURST_INCR16:
                 begin
           case(hsize)
             2'b00: haddrReg<=haddrReg+1;
             2'b01: haddrReg<=haddrReg+3'h2;
             2'b10: haddrReg<=haddrReg+3'h4;
           default: haddrReg<=haddrReg;
           endcase // case (hsize)
         end

         HBURST_WRAP4:
                 begin
           case(hsize)
             2'b00: haddrReg[1:0]<=haddrReg[1:0]+1;
             2'b01: haddrReg[2:1]<=haddrReg[2:1]+1;
             2'b10: haddrReg[3:2]<=haddrReg[3:2]+1;
           default: haddrReg<=haddrReg;
           endcase // case (hsize)
         end

         HBURST_WRAP8:
                 begin
           case(hsize)
             2'b00: haddrReg[2:0]<=haddrReg[2:0]+1;
             2'b01: haddrReg[3:1]<=haddrReg[3:1]+1;
             2'b10: haddrReg[4:2]<=haddrReg[4:2]+1;
           default: haddrReg<=haddrReg;
           endcase // case (hsize)
         end

         HBURST_WRAP16:
                 begin
           case(hsize)
             2'b00: haddrReg[3:0]<=haddrReg[3:0]+1;
             2'b01: haddrReg[4:1]<=haddrReg[4:1]+1;
             2'b10: haddrReg[5:2]<=haddrReg[5:2]+1;
           default: haddrReg<=haddrReg;
           endcase // case (hsize)
         end
       default: haddrReg<=haddrReg;
       endcase // case (hburst)
   end
end

// maddr up to 64KB
assign maddr[29:0] = write_sram ? haddr_wr_reg2[31:2] : haddrReg[31:2];

// write haddr register, no auto generate for burst
always @(posedge hclk or negedge hresetn)
  begin
  if(!hresetn)
    haddr_wr_reg2 <= 0;
  else
    haddr_wr_reg2 <= haddrReg;
end

// hsize Register
always @(posedge hclk or negedge hresetn)
  begin
  if(!hresetn)
      hsizeReg<=0;
  else
      hsizeReg<=hsize;
end

// mwe
always @(posedge hclk or negedge hresetn)
  begin
  if(!hresetn)
    mwe[3:0]<=4'b0000;
  else if(cstate[WRPA])
      begin
      case(hsizeReg[1:0])
        2'b00:
              begin
          case(haddrReg[1:0])
              2'b00: mwe[3:0]<=4'b0001;
              2'b01: mwe[3:0]<=4'b0010;
              2'b10: mwe[3:0]<=4'b0100;
              //2'b11: mwe[3:0]<=4'b1000;
          default: mwe[3:0]<=4'b1000;
          endcase // case (haddrReg[1:0])
        end

        2'b01:
              begin
          case(haddrReg[1:0])
              2'b00: mwe[3:0]<=4'b0011;
              2'b10: mwe[3:0]<=4'b1100;
          default: mwe[3:0]<=4'b0000;
          endcase // case (haddrReg[1:0])
        end

        2'b10:
              begin
          case(haddrReg[1:0])
              2'b00: mwe[3:0]<=4'b1111;
          default: mwe[3:0]<=4'b0000;
          endcase // case (haddrReg[1:0])
        end

      default: mwe[3:0]<=4'b0000;
      endcase // case (hsize[1:0])
 end // if (cstate[WRPA])
 else
     mwe[3:0]<=4'b0000;
end

endmodule
