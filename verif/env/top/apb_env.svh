`ifndef APB_ENV_SVH_
`define APB_ENV_SVH_

class apb_env extends uvm_env;
  `uvm_component_utils(apb_env)

  apb_agent apb_agnt;
  ram_agent ram_agnt;
  ram_coverage ram_cov;
  apb_scoreboard apb_scbd;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_agnt = apb_agent::type_id::create("apb_agnt", this);
    ram_agnt = ram_agent::type_id::create("ram_agnt", this);
    ram_cov = ram_coverage::type_id::create("ram_cov", this);
    apb_scbd = apb_scoreboard::type_id::create("apb_scbd", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    apb_agnt.monitor.analysis_port.connect(apb_scbd.out_export);
    ram_agnt.analysis_port.connect(ram_cov.analysis_export);
    ram_agnt.monitor.analysis_port.connect(apb_scbd.in_export);
  endfunction

endclass

`endif  // APB_ENV_SVH_
