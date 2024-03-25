module rstn_sync(
    input       sync_clock  ,
    input       rstn_n      ,
    output      async_rstn_n,
    output      sync_rstn_n    
);

parameter WIDTH = 4;
reg [WIDTH-1:0] sync_rstn   ;

always @(posedge sync_clock or negedge rstn_n) begin
    if(1'b0 == rstn_n)
	    sync_rstn <= {WIDTH{1'b0}};
    else 
	    sync_rstn <= {sync_rstn[WIDTH-2:0], 1'b1};
end

assign async_rstn_n = sync_rstn[WIDTH-2];
assign sync_rstn_n  = sync_rstn[WIDTH-1] || (~sync_rstn[WIDTH-2]);

endmodule
