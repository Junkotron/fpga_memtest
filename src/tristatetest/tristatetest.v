`timescale 1ns / 1ps
`default_nettype none

// An attempt to connect two fpga pins in half duplex
// using inout an as of 2024 not well supported
// feature of the yosys for the ice40 series

module tristatetest
  (
   input wire  clk_100mhz,
   output wire led1,
   output wire led2,
   inout wire  test6,
   inout wire  test7,

   output wire dir,
   );

   wire        way_r;
   
   tristate t1
     (
      .clk(clk_100mhz),
      .dir(way_r),
      .o(led1),
      .i(r_LED2),
      .buff(test6)
      );

   tristate t2
     (
      .clk(clk_100mhz),
      .dir(~way_r),
      .o(led2),
      .i(r_LED1),
      .buff(test7)
      );


//   assign led1 = r_LED1;
//   assign led2 = r_LED2;
   assign way_r = r_dir;

   // FOr scope ch (debug)
   assign dir = r_dir;
   
   // The notorious clk divider / led flasher
   localparam integer blinkslow = 50000000;
   localparam integer blinkfast = 10000000;
   localparam integer blinkdir = 500000000;
   reg [31:0] 	      cnt1 = 0;
   reg [31:0] 	      cnt2 = 0;
   reg [31:0] 	      cnt3 = 0;
   
   reg 		      r_LED1 = 1'b0;
   reg 		      r_LED2 = 1'b0;
   reg 		      r_dir = 1'b0;
   
   always @(posedge clk_100mhz)
     begin
        if (cnt1 > blinkslow)
          begin
             r_LED1 <= !r_LED1;
             cnt1 <= 0;
          end
        else
          begin
             cnt1 <= cnt1 + 1;
          end
	
        if (cnt2 > blinkfast)
          begin
             r_LED2 <= !r_LED2;
             cnt2 <= 0;
          end
        else
          begin
             cnt2 <= cnt2 + 1;
          end

        if (cnt3 > blinkdir)
          begin
             r_dir <= !r_dir;
             cnt3 <= 0;
          end
        else
          begin
             cnt3 <= cnt3 + 1;
          end
     end
   
   
endmodule
