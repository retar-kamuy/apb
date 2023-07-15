RM = rm -rf
ifeq ($(OS), Windows_NT)
	RM = del /q
endif
RD = rd /q /s

SRCS = verif/tb/tb_top.sv verif/tb/clk_rst_gen.sv src/apb.sv verif/env/ref_model/apb_assertion.sv
INCLUDES = verif/tests verif/tests/sequence_lib verif/env verif/env/agents/ram verif/env/agents/apb
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
	$(RM) xsim.covdb xsim.dir xsim.out xvlog.pb xelab.pb
	$(RM) xsim_*.backup.* xsim.jou *.wdb
	$(RM) *.log *.vcd
