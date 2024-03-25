module IntMemReqHold
  (
   // outputs
   AxVALIDhold,
   AxREADYhold,
   AxREADYhold_c,
   
   // inputs
   ACLK,
   ARESETn,
   AxVALID,
   AxREADY,
   xREADY,
   xVALID,
   xLAST
   );

//------------------------------------------------------------------------------
// Port declarations
//------------------------------------------------------------------------------

  // Global inputs
  input	 ACLK;
  input	 ARESETn;

   // outputs
  output AxVALIDhold;   // AxREADY to slave
  output AxREADYhold;   // AxREADY to master
  output AxREADYhold_c; // AxREADY_c to master
  
   // inputs
  input	 AxVALID;       // AxVALID from slave
  input	 AxREADY;       // AxREADY from slave
  input	 xREADY;        // xREADY associated with the response channel
  input	 xVALID;        // xVALID associated with the response channel
  input	 xLAST;         // xLAST  last response or tied to 1'b1 for use
                        // with Write Channel

//------------------------------------------------------------------------------
// Signal declarations
//------------------------------------------------------------------------------
  wire	      wait_for_resp_in;
  reg	        wait_for_resp;

//==============================================================================
//                           Main body of code
//==============================================================================
  assign AxVALIDhold = AxVALID & ~wait_for_resp;
  assign AxREADYhold = AxREADY & ~wait_for_resp;
  
  assign AxREADYhold_c = AxREADY & ~wait_for_resp_in;

  assign        wait_for_resp_in = ((AxREADY & AxVALID) | wait_for_resp) & // set + hold
				      ~(xLAST & xVALID & xREADY); // reset

  always @(posedge ACLK or negedge ARESETn)
    begin
      if (!ARESETn)
	begin
	  wait_for_resp <=   1'b0;
	end
      else
	begin
	  wait_for_resp <=   wait_for_resp_in;
	end
    end

endmodule
