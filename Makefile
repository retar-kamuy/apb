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
INCLUDES = verif/tests verif/tests/sequence_lib verif/env verif/env/agents/ram verif/env/agents/apb
TOP = tb_top

COVDIR = xsim.covdb
REPORT_DIR = xsim.out

all: clean build test cover

list: $(SRCS)
	echo $(SRCS)

define F
	echo +incdir+$(1) | sed -e "s/ /\n/g" >> filelist.f

endef

.PHONY: filelist.f
filelist.f: $(SRCS)
	echo $(filter %.v %.sv,$(SRCS)) | sed -e "s/ /\n/g" > $@
	$(foreach incdir,$(INCLUDES),$(call F,$(incdir)))

.PHONY: build
xsim.dir/work.tb_top/xsimk: $(SRCS)
	xvlog -sv $(filter %.v %.sv,$^) -L uvm $(addprefix --include ,$(INCLUDES))
	xelab $(TOP) -L uvm -timescale 1ns/1ps

.PHONY: test
test: xsim.dir/work.tb_top/xsimk
ifeq ("$(wildcard xsim.covdb"), "xsim.covdb")
	$(RM) $(@D)
	mkdir $(@D)
endif
	xsim $(notdir $(<D)) -R -testplusarg \"UVM_VERBOSITY=UVM_LOW\"

.PHONY: cover
cover: xsim.covdb/work.tb_top
ifeq ("$(wildcard $(REPORT_DIR)"), "$(REPORT_DIR)")
	$(RM) $(REPORT_DIR)
endif
	mkdir -p $(REPORT_DIR)
	xcrg -dir $(COVDIR) -report_dir $(REPORT_DIR)/cov -report_format html

clean:
ifeq ("$(wildcard xsim.dir"), "xsim.dir")
	$(RM) xsim.dir
endif
	$(RM) xsim.covdb xsim.dir xsim.out xvlog.pb xelab.pb
	$(RM) xsim_*.backup.* xsim.jou *.wdb
	$(RM) *.log *.vcd
	$(RM) filelist.f