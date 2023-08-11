`ifndef APB_TEST_SVH_
`define APB_TEST_SVH_

class apb_base_test extends uvm_test;
  `uvm_component_utils(apb_base_test)

  apb_env env;
  apb_sequence apb_seq;
  ram_sequence ram_seq;

  function new(string name = "apb_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = apb_env::type_id::create("env", this);
    apb_seq = apb_sequence::type_id::create("apb_seq");
    ram_seq = ram_sequence::type_id::create("ram_seq");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    fork
      apb_seq.start(env.apb_agnt.sequencer);
      ram_seq.start(env.ram_agnt.sequencer);
    join_any
    phase.drop_objection(this);
  endtask

endclass

`endif  // APB_TEST_SVH_