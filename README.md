# up5k_bsv
Bluespec environment for the Lattice up5k FPGA

# Rough notes
Makefile expects APIO(https://github.com/FPGAwars/apio)
Use python and pip to install it

The cpp code for communicating with the hardware over uart is not there yet

Bluespe BRAM sometimes gets synthesized into LUTs... Port number issues?

export BLUESPECDIR=~/bsc/inst/lib/
