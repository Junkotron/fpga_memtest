`timescale 1ns / 1ps
`default_nettype none


module sramtest
  (
   input wire 	      clk_100mhz,
   output reg 	      led1,
   output reg 	      led2,

   // Using the ps/2 connector pins for a two-throw switch
   input 	      sr1,
   input 	      sr2,
   
   output wire [17:0] a,
   inout [7:0] 	      d,
   
   output reg 	      cs_n=0,
   output reg 	      oe_n=0,
   output reg 	      we_n,

   output reg [7:0]   test,  
   );

   reg 		      single_step_clock;
   assign test[0] = single_step_clock;
   
   // S-R vipp for single stepping
   always @(posedge clk_100mhz)
     begin
	if (sr1 & ~sr2 & ~single_step_clock)
	  single_step_clock = 1;
	
	
	if (sr2 & ~sr1 & single_step_clock)
	  single_step_clock = 0;
	  
     end

   assign test[0]=single_step_clock;
   assign test[1]=0;  // PAJ!!!
   assign test[2]=chk[dleg];
   assign test[3]=d_f2s[dleg];
   assign test[4]=we_n;
   assign test[5]=dcnt[dleg];
   assign test[6]=acnt[0];
   assign test[7]=d_s2f[dleg];

   reg [7:0] 	      d_f2s;
   wire [7:0] 	      d_s2f;

   integer 	      state=0;
   
   reg [17:0] 	      acnt=0;
   reg [7:0] 	      dcnt=43;

   reg [7:0] 	      chk=0;
   reg [7:0] 	      wsum=0;

   integer 	      goto=-1;
   reg 		      dummy;
   
   assign a=acnt;

   integer 	      dleg=0;
   localparam integer acntlim=1<<17-1;
   
   // clk divider, seems 100 mhz / 10 ns is to fast
   // Using this divider at its max (50 mhz) seem to work
   // on ice40 with olimex board
   // also tried it as slow as 50 Hz (n_divisor=1000000) in which case the
   // delay is visible for acntlim up to 10
   localparam integer n_divisor=1;
   reg [31:0] 	      fcnt=0;
   reg 	      clkdiv=0;
   
   always @(posedge clk_100mhz)
     begin
	fcnt++;
	if (n_divisor==fcnt) 
	  begin
	     fcnt=0;
	     clkdiv=~clkdiv;
	  end
	
     end
   
//   always @(posedge single_step_clock) // Will be unbearable for acnt over 2-3
//   always @(posedge clk_100mhz)    // Will fail
   always @(posedge clkdiv)
     begin
	case (state)
	  0: we_n=1;
	  1: d_f2s=dcnt;
	  2: we_n=0;
	  3: we_n=1;
	  4: acnt++;
	  5: chk=chk+dcnt;
	  6: dcnt++;
	  7: if (acnt==acntlim) goto=100;
	  8: goto=1;

	  100: wsum=chk;
	  101: chk=0;
	  102: acnt=0;
	  103: chk=chk+d_s2f;
	  104: acnt++;
	  105: if (acnt==acntlim) goto=200;
	  107: goto=103;

  	  200: if (chk==wsum) goto=1000;
//  	  200: if (chk== ((43+52)*5)%256) goto=1000;
	  201: goto=2000;
  
	  1000: led1=1;
	  1001: led2=0;
	  1002: goto=1002; // halt OK
	  
	  2000: led1=0;
	  2001: led2=1;
	  2002: goto=2002; // halt FAIL
	  
	endcase // case (state)
	if (goto != -1)
	  begin
	     state=goto;
	     goto=-1;
	  end
	else
	  begin
	     state++;
	  end
    end
   tristate8 t
     (
      .clk(clk_100mhz),
      .dir(~we_n),
      .i(d_f2s),
      .o(d_s2f),
      .buff(d)
      );
   
   
endmodule
