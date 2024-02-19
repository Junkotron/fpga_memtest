# fpga_memtest
An attempt to make use of the sram available on Olimex boards ice40hx8k/1k

This whole ordeal started when making some adaption for the ZX81 and Jupiter
Ace old-timer computer models available for the blackice fpga boards.

I did a port and some alterfications to the Olimex ice40 boards.

These boards have a nice external 512 kB SRAM handy, I thought, for memory
expansions.

One thing with these SRAMs is that they function in very much the same
way as old-fashioned RAMs, such as the 2114 (1kx4), 6116 (2kx8) an 6264 (8kx8) just to mention a few.

The modern counterparts are nearly identical except much faster and with more
capacity. The Olimex sram has some exciting new "UB" and "LB" but they are
earthed on the board.

One thing that became an obstacle was that I was originally unable to get
these chips running and I was unable to find some demo code for the Olimex
boards using this SRAM.

What seemed to be the problem was the support for the bidirectional data
ports still employed on these types of chips.

Whilst modern designs seem to avoid bidirectional tristate buffers like the
plague, and for good reasons, we are stuck with the board having hard-wired
threads going from fpga to sram forming a data port of 16 bit wide

One way to ease up this problem would be if the RAM would have an external
buffer, such as the 74hc245 since then the FPGA would only have to support
regular ins and outs, be it 2x the size of the data bus. It might also have
impacted the speed


Digging deeper into this matter I realized there where at least two pnr
(place and route) packages available for the yosys, arachne-pnr and next-pnr.

As I understand it, the yosys team are still not ready to support bidirectional
to the full even for the more recent next-pnr

The example codes I found seemed not to work and to my knowledge only the
commercial software packages support tristate full out.

Refusing to give up on this I managed to google a possible solution for the
arachne-pnr where Lattice Primitive "SB_IO" is used directly.

So I did my first successful tryout making use of the two LEDS on the olimex
board as my debugger. This code is one part of this repo, "tristatetest.v" and
friends.

The program I finally cobbled together had two oscilators blinking in low
enough to be visible frequencies each would feed to a tristate buffer and
then I would make them both "talk" through a pin each on the FPGA.
A third oscilator flipping back and forth at around 10x slower would then
alternate the direction of the buffers, then one would see the leds being
"taken over" by the driver that was currently activated. It seemed to work.

Now I made a similar code which would attempt to talk to the SRAM.
I made good use of Salvador Canas writing on how really simple one
could make writing and reading from this ram, tie OE and CS to zero
and then use the WR signal resting at high and then after setting
address and data, just pulse the WR low-high. Then to read data one
needed only to change the address bus, wait some time and then read the
data bus.

So since "linear" code as I understand it is unavailable for verilog real
time logic I decided to create a really simple state machine for doing
sequences, it could assing values and do conditional and unconditional
jumps. The "language" used is actually more primitive than the ZX81 Basic
it is intended for...

This code would make a simple counter for 18 bit address, another counter
for data (i did only 8 bits, leaving the high 8 data bits o the sram
alone) and then after each write, both the address and the ultra-primitive
"pattern generator" for the data written would also be incremented.

The notorious LED's where also used in such a way that when "LED2" would
light up it, would indicate a failure and "LED1" would indicate a success.

A simple checksum was employed that would just sum the numbers and then
compare notes via a modulo 256 operation.

This code is available as "sram_test.v" in this repo.

I also took two pins and made an SR-latch so I could single step the
operations via a toggle switch, feeding some relevant output to a cheap
salae logic analyzer.

At first I had a problem that it would work ok with the single stepping but
then fail at the 100MHz real oscilator feeding the sequence network. I
after some figuring realized that even though the RAM "is" a 10 ns access
type it seemed that it needed some more time so I made a divider that would
bring it down, after trying some values going as low as 50 Hz I finally
settled for a 50MHz clock which seemed to work. I did not try to do any serious
"push-pull" for read-write cycles at this time.

As this kind of simple "sum an increased value by one" schemes have an evil
habit of producing false positives, I also did a simple regression test,
one of the legs normally going to the data bus of the SRAM would now by made
to point out into nothing. This can be done by altering the .pcf file and the
LED2 would kindly light up indicating a "faulty" RAM test.

Here are some links that was very useful that I also mentioned in the text!

https://github.com/lawrie/blackicemx_zx81
https://github.com/hoglet67/Ice40JupiterAce
https://www.olimex.com/Products/FPGA/iCE40/iCE40HX8K-EVB/open-source-hardware
https://www.olimex.com/Products/FPGA/iCE40/iCE40HX1K-EVB/open-source-hardware
https://hardware.speccy.org/datasheet/2114.pdf
https://www.olimex.com/Products/_resources/ds_k6r4016v1d_rev40.pdf
https://stackoverflow.com/questions/60957971/understanding-the-sb-io-primitive-in-lattice-ice40
https://www.hackster.io/salvador-canas/a-practical-introduction-to-sram-memories-using-an-fpga-ii-a18801

Thats all for now!
