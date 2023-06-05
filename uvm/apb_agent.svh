`ifndef APB_AGENT_SVH_
`define APB_AGENT_SVH_

class apb_agent extends uvm_agent;
  uvm_sequencer#(apb_seq_item) sequencer;
  apb_driver driver;
  apb_monitor monitor;

  `uvm_component_utils(apb_agent)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sequencer = uvm_sequencer#(apb_seq_item)::type_id::create("sequencer", this);
    driver = apb_driver::type_id::create("driver", this);
    monitor = apb_monitor::type_id::create("monitor", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass

`endif  // APB_AGENT_SVH_
