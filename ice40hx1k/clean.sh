#!/bin/bash

mkdir -p old
cp * old/ >& /dev/null

rm -f sramtest.txt

# Remove BlackIce files
rm -f *.blif *.bin *.log

rm -f "#*"
rm -f "*#"
rm -f *~


# Remove Simulation files
rm -f a.out dump.vcd
