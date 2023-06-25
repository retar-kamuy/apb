RM = rm -rf
ifeq ($(OS), Windows_NT)
	RM = del /q
endif
RD = rd /q /s

SRCS = env/tb_top.sv env/tb/clk_rst_gen.sv src/apb.sv env/ref_model/apb_assertion.sv
INCLUDES = tests tests/sequence_lib env env/agents/bus_interface env/agents/apb_interface
TOP = tb_top

COVDIR = xsim.covdb
REPORT_DIR = xsim.out

all: clean build test cover

build: $(SRCS)
	xvlog -sv $^ -L uvm $(addprefix --include ,$(INCLUDES))
	xelab $(TOP) -L uvm -timescale 1ns/1ps

test:
ifeq ("$(wildcard xsim.covdb"), "xsim.covdb")
	$(RD) xsim.covdb
	mkdir xsim.covdb
endif
	xsim $(TOP) -R -testplusarg \"UVM_VERBOSITY=UVM_LOW\"

cover:
ifeq ("$(wildcard $(REPORT_DIR)"), "$(REPORT_DIR)")
	$(RD) $(REPORT_DIR)
	mkdir $(REPORT_DIR)
endif
	xcrg -dir $(COVDIR) -report_dir $(REPORT_DIR)/cov -report_format html

clean:
ifeq ("$(wildcard xsim.dir"), "xsim.dir")
	$(RD) xsim.dir
endif
	$(RM) xvlog.pb xelab.pb
	$(RM) xsim_*.backup.* xsim.jou *.wdb
	$(RM) *.log *.vcd
