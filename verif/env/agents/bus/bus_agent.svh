`ifndef BUS_AGENT_SVH_
`define BUS_AGENT_SVH_

class bus_agent extends uvm_agent;
  `uvm_component_utils(bus_agent)

  uvm_sequencer#(bus_transaction) sequencer;
  bus_driver driver;
  bus_monitor monitor;

  uvm_analysis_port #(bus_transaction) bus_analysis_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sequencer = uvm_sequencer#(bus_transaction)::type_id::create("sequencer", this);
    driver = bus_driver::type_id::create("driver", this);
    monitor = bus_monitor::type_id::create("monitor", this);
    bus_analysis_port = new("bus_analysis_port", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
    monitor.bus_analysis_port.connect(bus_analysis_port);
  endfunction

endclass

`endif  // BUS_AGENT_SVH_
