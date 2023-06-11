RM = rm -rf
ifeq ($(OS), Windows_NT)
	RM = del /q
endif

SRCS = uvm/tb_top.sv uvm/clk_rst_gen.sv src/apb.sv
INCLUDES = uvm uvm/agents/bus_interface uvm/agents/apb_interface
TOP = tb_top

all: clean build test

build: $(SRCS)
	xvlog -sv $^ -L uvm $(addprefix --include ,$(INCLUDES))
	xelab $(TOP) -L uvm -timescale 1ns/1ps

test:
#	xsim work.tb_top -testplusarg UVM_TESTNAME=apb_base_test
	xsim $(TOP) -R

clean:
	$(RM) work *.log *.wlf
	$(RM) xvlog.log xvlog.pb xelab.pb xelab.log
	$(RM) xsim.dir  xsim_*.backup.* xsim.jou xsim.log
