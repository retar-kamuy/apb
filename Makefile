RM = rm -rf
ifeq ($(OS), Windows_NT)
	RM = del /q
endif
RD = rd /q /s

FILTER_EXTENSIONS = v vh sv svh

SRCDIRS = src verif

# FIND_FILES = $(foreach ext,$(FILTER_EXTENSIONS),$(wildcard $(srcdir)/*.$(ext)))
FIND_FILES = $(foreach ext,$(FILTER_EXTENSIONS),$(shell find $(srcdir) -name "*.$(ext)"))
SRCS = $(foreach srcdir,$(SRCDIRS),$(FIND_FILES))

# SRCS = verif/tb/tb_top.sv verif/tb/clk_rst_gen.sv src/apb.sv verif/env/ref_model/apb_assertion.sv
INCDIRS = verif/tests verif/tests/sequence_lib verif/env verif/env/agents/ram verif/env/agents/apb
TOP = tb_top

COVDIR = xsim.covdb
REPORT_DIR = xsim.out

all: clean build test cover

list: $(SRCS)
	echo $(SRCS)

define F
	echo +incdir+$(1) >> filelist.f

endef

.PHONY: filelist.f
filelist.f: $(SRCS)
	echo $(filter %.v %.sv,$(SRCS)) | sed -e "s/ /\n/g" > $@
	$(foreach incdir,$(INCDIRS),$(call F,$(incdir)))

.PHONY: build
build: xsim.dir/work.tb_top

xsim.dir/work.tb_top: $(SRCS)
	xvlog -sv $(filter %.v %.sv,$^) -L uvm $(addprefix --include ,$(INCDIRS))
	xelab $(notdir $@) -L uvm -timescale 1ns/1ps -cc_type sbct

.PHONY: test
test: xsim.log

xsim.log: xsim.dir/work.tb_top
ifeq ("$(wildcard xsim.covdb"), "xsim.covdb")
	$(RM) $(@D)
	mkdir $(@D)
endif
	xsim $(notdir $<) -R -testplusarg \"UVM_VERBOSITY=UVM_LOW\" -log $@

.PHONY: cover
cover:
ifeq ("$(wildcard $(REPORT_DIR)"), "$(REPORT_DIR)")
	$(RM) $(REPORT_DIR)
endif
	mkdir -p $(REPORT_DIR)
	xcrg -cc_db work.tb_top -dir $(COVDIR) -report_dir $(REPORT_DIR)/xcrg_func_cov_report -cc_report $(REPORT_DIR)/xcrg_code_cov_report -report_format html

clean:
ifeq ("$(wildcard xsim.dir"), "xsim.dir")
	$(RM) xsim.dir
endif
	$(RM) xsim.codeCov xsim.covdb xsim.dir xsim.out xvlog.pb xelab.pb
	$(RM) xsim_*.backup.* xsim.jou *.wdb
	$(RM) *.log *.vcd
	$(RM) filelist.f