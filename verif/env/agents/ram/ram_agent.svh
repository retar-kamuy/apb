`ifndef RAM_AGENT_SVH_
`define RAM_AGENT_SVH_

class ram_agent extends uvm_agent;
  `uvm_component_utils(ram_agent)

  uvm_sequencer#(ram_transaction) sequencer;
  ram_driver driver;
  ram_monitor monitor;

  uvm_analysis_port #(ram_transaction) analysis_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sequencer = uvm_sequencer#(ram_transaction)::type_id::create("sequencer", this);
    driver = ram_driver::type_id::create("driver", this);
    monitor = ram_monitor::type_id::create("monitor", this);
    analysis_port = new("analysis_port", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
    monitor.analysis_port.connect(analysis_port);
  endfunction

endclass

`endif  // RAM_AGENT_SVH_
