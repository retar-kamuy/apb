RM = rm -rf
ifeq ($(OS), Windows_NT)
	RM = del /q
endif
RD = rd /q /s

SRCS = env/tb_top.sv env/tb/clk_rst_gen.sv src/apb.sv env/tb/apb_interface_assertions.sva
INCLUDES = tests tests/sequence_lib env env/agents/bus_interface env/agents/apb_interface
TOP = tb_top

COVDIR = xsim.covdb
REPORT_DIR = xsim.out

all: clean build test

build: $(SRCS)
	xvlog -sv $^ -L uvm $(addprefix --include ,$(INCLUDES))
	xelab $(TOP) -L uvm -timescale 1ns/1ps

test:
#	xsim work.tb_top -testplusarg UVM_TESTNAME=apb_base_test
	xsim $(TOP) -R

post:
ifeq ("$(wildcard $(REPORT_DIR)"), "")
	mkdir $(REPORT_DIR)
endif
	xcrg -dir $(COVDIR) -report_dir $(REPORT_DIR)/cov -report_format html

clean:
	$(RM) *.log *.wlf *.vcd
	$(RD) work
	$(RM) xvlog.pb xelab.pb
	$(EM) xsim_*.backup.* xsim.jou *.wdb
	$(RD) xsim.dir xsim.covdb
