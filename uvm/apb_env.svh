class apb_env extends uvm_env;
  //apb_agent agent;
  bus_agent agent;
  //apb_scoreboard scoreboard;

  `uvm_component_utils(apb_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // agent = apb_agent::type_id::create("agent", this);
    agent = bus_agent::type_id::create("agent", this);
    //scoreboard = apb_scoreboard::type_id::create("scoreboard", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //agent.monitor.mon_analysis_port.connect(scoreboard.analysis_imp);
  endfunction

endclass
