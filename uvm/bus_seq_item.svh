`ifndef BUS_SEQ_ITEM_SVH_
`define BUS_SEQ_ITEM_SVH_

class bus_seq_item extends uvm_sequence_item;
  rand  bit [63:0]    address;
  rand  int           command;
  rand  byte          data;
  rand  int unsigned  length;
        byte          byte_enable[];
        int           byte_enable_length;
        int           response_status;

  `uvm_object_utils_begin(bus_seq_item)
    `uvm_field_int(address, UVM_ALL_ON)
    `uvm_field_int(command, UVM_ALL_ON)
    `uvm_field_int(data   , UVM_ALL_ON)
    `uvm_field_int(length , UVM_ALL_ON)
    `uvm_field_array_int(byte_enable, UVM_ALL_ON)
    `uvm_field_int(byte_enable_length , UVM_ALL_ON)
    `uvm_field_int(response_status , UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "bus_seq_item");
    super.new(name);
  endfunction

  constraint c1 {
    address inside {[0:100]};
    command inside {[0:1]};
    data inside {[0:7]};
    length inside {[1:4]};
  }

  function string convert2str();
    return $sformatf("address=0x%x, command=%d, data=0x%x, length=0x%d", address, command, data, length);
  endfunction

  function void post_randomize();
  endfunction

endclass

`endif  // BUS_SEQ_ITEM_SVH_
