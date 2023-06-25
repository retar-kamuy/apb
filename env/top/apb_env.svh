`ifndef APB_ENV_SVH_
`define APB_ENV_SVH_

class apb_env extends uvm_env;
  apb_agent apb_agnt;
  bus_agent bus_agnt;
  bus_coverage bus_cov;
  //apb_scoreboard scoreboard;

  `uvm_component_utils(apb_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_agnt = apb_agent::type_id::create("apb_agnt", this);
    bus_agnt = bus_agent::type_id::create("bus_agnt", this);
    bus_cov = bus_coverage::type_id::create("bus_cov", this);
    //scoreboard = apb_scoreboard::type_id::create("scoreboard", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    bus_agnt.bus_analysis_port.connect(bus_cov.analysis_export);
    //agent.monitor.apb_analysis_port.connect(scoreboard.analysis_imp);
  endfunction

endclass

`endif  // APB_ENV_SVH_
