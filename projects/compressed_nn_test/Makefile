ROOTDIR=../../

BSCFLAGS = -show-schedule -show-range-conflict -aggressive-conditions --wait-for-license 
BUILD_DIR=./build/
BSIM_DIR=./bsim/
BSVPATH=$(ROOTDIR)/src/

BSCFLAGS_SYNTH = -bdir $(BUILD_DIR) -vdir $(BUILD_DIR) -simdir $(BUILD_DIR) -info-dir $(BUILD_DIR) -fdir $(BUILD_DIR)

BSCFLAGS_BSIM = -bdir $(BSIM_DIR) -vdir $(BSIM_DIR) -simdir $(BSIM_DIR) -info-dir $(BSIM_DIR) -fdir $(BSIM_DIR) -D BSIM -l pthread

BSIM_CPPFILES= $(ROOTDIR)/src/cpp/UartSim.cpp ./cpp/main.cpp
#$(ROOTDIR)/cpp/PcieBdpi.cpp \
	$(ROOTDIR)/cpp/ShmFifo.cpp

all:
	rm -rf build
	mkdir -p build
	cd $(BUILD_DIR); apio init -b upduino2 -p .
	bsc  $(BSCFLAGS) $(BSCFLAGS_SYNTH) -remove-dollar -p +:$(BSVPATH) -verilog -u -g mkBsvTop $(ROOTDIR)/src/BsvTop.bsv 
	cp verilog/*.v build
	cp verilog/*.pcf build
	cp $(ROOTDIR)/verilog/bluespec/*.v build 
	cd build; apio verify 
	cd build; apio build -v

bsim: Main.bsv cpp/main.cpp
	mkdir -p $(BSIM_DIR)
	bsc $(BSCFLAGS) $(BSCFLAGS_BSIM) $(DEBUGFLAGS) -p +:$(BSVPATH) -sim -u -g mkBsvTop_bsim $(ROOTDIR)/src/BsvTop.bsv  
	bsc $(BSCFLAGS) $(BSCFLAGS_BSIM) $(DEBUGFLAGS) -sim -e mkBsvTop_bsim -o $(BSIM_DIR)/bsim $(BSIM_DIR)/*.ba $(BSIM_CPPFILES)


program:
	cd build; apio upload

