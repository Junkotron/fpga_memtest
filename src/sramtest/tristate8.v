`timescale 1ns / 1ps
`default_nettype none

// An attempt to connect two fpga pins in half duplex
// using inout an as of 2024 not well supported
// feature of the yosys for the ice40 series

module tristate8
  (
   input wire 	     clk,
   input wire 	     dir, // set this to one means outgoing (out of fpga)
   output wire [7:0] o,
   input wire [7:0]  i,
   
   inout 	   [7:0]  buff,
   );

   SB_IO #(
	   .PIN_TYPE(6'b 1010_01),
	   .PULLUP(1'b 0)
	   ) databus [7:0] 
     (
      .PACKAGE_PIN(buff),
      .OUTPUT_ENABLE(dir),
      .D_OUT_0(i),
      .D_IN_0(o)
      );
   
   
//   assign buff = dir ? i : 1'bZ;
//   assign o = dir ? 1'bZ : buff;

/*
   always @(posedge clk)
     begin
	if (dir)
	  begin
	     buff <= i;
	     o <= 1'bZ;
	  end
	else
	  begin
	     buff <= 1'bZ;
	     o <= buff;
	  end
     end
*/	
   
endmodule
