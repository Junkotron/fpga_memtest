#!/bin/bash

set -e


TOP=sramtest
NAME=sramtest
PACKAGE=vq100
SRCS="../src/sramtest/sramtest.v ../src/sramtest/tristate8.v"
DEVICE=1k

#TOP=tristatetest
#NAME=tristatetest
#PACKAGE=ct256
#SRCS="../src/tristatetest/tristatetest.v ../src/tristatetest/tristate.v"
#DEVICE=8k

yosys -q -f "verilog -Duse_sb_io" -l ${NAME}.log -p "synth_ice40 -top ${TOP} -abc2 -blif ${NAME}.blif" ${SRCS}
arachne-pnr -d ${DEVICE} -P ${PACKAGE} -p ${NAME}_${PACKAGE}.pcf ${NAME}.blif -o ${NAME}.txt
icepack ${NAME}.txt ${NAME}.bin
#icetime -d hx8k -P ${PACKAGE} ${NAME}.txt
