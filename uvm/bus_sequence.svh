`ifndef BUS_SEQUENCE_SVH_
`define BUS_SEQUENCE_SVH_

class bus_sequence extends uvm_sequence;
  `uvm_object_utils(bus_sequence)

  function new(string name="bus_sequence");
    super.new(name);
  endfunction

  virtual task body();
    for (int i = 0; i < 4; i++) begin
      bus_seq_item item = bus_seq_item::type_id::create("item");
      start_item(item);
      assert(item.randomize());  
      `uvm_info(get_full_name(), $sformatf("RANDOMIZED TRANSACTION FROM SEQUENCE: %s", item.convert2str()), UVM_LOW);
      item.print();
      finish_item(item);
    end
  endtask

endclass

`endif  // BUS_SEQUENCE_SVH_
