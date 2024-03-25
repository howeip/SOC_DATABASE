`ifdef FPGA
`elsif NO_ASIC
`else
	`include "std_cell_def.h"
`endif
module icg(
    input  wire clkin,
    input  wire enable,
    input  wire se,
    output wire clkout
);

`ifdef FPGA
//BUFGCE u_icg(
//  .O(clkout),
//  .CE(enable),
//  .I(clkin)
//);
//assign clkout = clkin & enable;
assign clkout = clkin ;
//`ifdef HAPS
//    reg clkout_pre;
//    always @ (*)
//        if (!clkin)
//            clkout_pre=enable|se;
//    assign clkout=clkout_pre&clkin;
//
//	`else
//	assign clkout = clkin ;
//
//	`endif

`elsif NO_ASIC
    reg clkout_pre;
    always @ (*)
    	if (!clkin)
    		clkout_pre=enable|se;
    assign clkout=clkout_pre&clkin;
`else
   `ifdef EVEREST2
      `STD_ICG_CELL u_dontouch_icg(
          .CK         (clkin          ),
          .E          (enable         ),
          .TE         (se             ),
          .Q          (clkout         )
      );
   `else
      `ifdef OLYMPUS2
         `STD_ICG_CELL u_dontouch_icg(
             .CK         (clkin          ),
             .E          (enable         ),
             .SE         (se             ),
             .ECK        (clkout         )
         );
      `else
         `ifdef SKY
            `STD_ICG_CELL u_dontouch_icg(
               .CP         (clkin          ),
               .E          (enable         ),
               .TE         (se             ),
               .Q          (clkout         )
            );
         `endif   
      `endif
   `endif
`endif

endmodule
