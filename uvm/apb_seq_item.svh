class apb_seq_item extends uvm_sequence_item;
        bit           [63:0]  address;
        int                   command;
  rand  bit           [31:0]  data;
        int unsigned          length;
        byte                  byte_enable[];
        int                   byte_enable_length;

  rand bit [3:0]  num_of_wait_cycles;   // num of cycles for which pready will be kept off
  rand bit        on_off_wait_states;   // enable wait states with "1";

  `uvm_object_utils_begin(apb_seq_item)
    `uvm_field_int(data               , UVM_DEFAULT)
    `uvm_field_int(num_of_wait_cycles , UVM_DEFAULT)
    `uvm_field_int(on_off_wait_states , UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "apb_seq_item");
    super.new(name);
  endfunction

  constraint num_of_waits {
    if(on_off_wait_states)
      num_of_wait_cycles inside {[1:4]};
    else
      num_of_wait_cycles inside {[0:0]};
  }

  function string convert2str();
    return $sformatf("on_off_wait_states=%d, num_of_wait_cycles=%d", on_off_wait_states, num_of_wait_cycles);
  endfunction

endclass
