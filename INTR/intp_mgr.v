module intp_mgr
#(
    parameter   SIG_WIDTH = 1
)    
(
    
    input                           clk,
    input                           rst_n,

    input      [SIG_WIDTH-1:0]      intp_sig,
    input      [SIG_WIDTH-1:0]      intp_sig_set,
    input      [SIG_WIDTH-1:0]      intp_sig_clr,
    input      [SIG_WIDTH-1:0]      intp_sig_mode,
    input      [SIG_WIDTH-1:0]      intp_sig_mask,
    input      [SIG_WIDTH-1:0]      intp_sig_polar,

    output reg [SIG_WIDTH-1:0]      intp_sig_stat,
    output                          intp_sig_out

);

    /*autodef*/
    //Start of automatic define
    //Start of automatic reg
    //Define flip-flop registers here
    //Define combination registers here
    //End of automatic reg
    //Start of automatic wire
    //Define assign wires here
    //Define instance wires here
    //End of automatic wire
    //End of automatic define
    reg    [SIG_WIDTH-1:0]      intp_sig_dly     ;
    reg    [SIG_WIDTH-1:0]      intp_sig_stat_dly;
    wire   [SIG_WIDTH-1:0]      intp_sig_rise    ;
    wire   [SIG_WIDTH-1:0]      intp_sig_fall    ;
    wire   [SIG_WIDTH-1:0]      intp_sig_low     ;
    wire   [SIG_WIDTH-1:0]      intp_sig_high    ;

    genvar i;    

    generate for (i = 0; i < SIG_WIDTH; i = i + 1)begin: intp_mgr

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            intp_sig_dly[i] <= 1'b0;
        end else begin
            intp_sig_dly[i] <= intp_sig[i];
        end
    end
    
    assign intp_sig_rise[i] = intp_sig[i]&&!intp_sig_dly[i];
    assign intp_sig_fall[i] = !intp_sig[i]&&intp_sig_dly[i];
    assign intp_sig_low[i] = (intp_sig_dly[i]==1'b0);
    assign intp_sig_high[i] = (intp_sig_dly[i]==1'b1);
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            intp_sig_stat[i] <= 1'b0;
        end else begin
            intp_sig_stat[i] <= intp_sig_stat_dly[i];
        end
    end

    always @(*) begin
        case ({intp_sig_mode[i],intp_sig_polar[i]})
            2'b00 : begin
                intp_sig_stat_dly[i] = intp_sig_clr[i] ? 1'b0 :
                                 (intp_sig_set[i]||intp_sig_fall[i]) ? 1'b1 : intp_sig_stat[i];
            end
            2'b01 : begin
                intp_sig_stat_dly[i] = intp_sig_clr[i] ? 1'b0 :
                                 (intp_sig_set[i]||intp_sig_rise[i]) ? 1'b1 : intp_sig_stat[i];
            end
            2'b10 : begin
                intp_sig_stat_dly[i] = intp_sig_clr[i] ? 1'b0 :
                                 (intp_sig_set[i]||intp_sig_low[i]) ? 1'b1 : intp_sig_stat[i];
            end
            default : begin
                intp_sig_stat_dly[i] = intp_sig_clr[i] ? 1'b0 :
                                 (intp_sig_set[i]||intp_sig_high[i]) ? 1'b1 : intp_sig_stat[i];
            end
        endcase
    end
    end

    endgenerate 

    assign intp_sig_out = (|((~intp_sig_mask[SIG_WIDTH-1:0]) & intp_sig_stat[SIG_WIDTH-1:0]));


endmodule
