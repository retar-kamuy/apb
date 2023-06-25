`ifndef APB_TRANSACTION_SVH_
`define APB_TRANSACTION_SVH_

class apb_transaction extends uvm_sequence_item;
        bit           [63:0]  address;
        int                   command;
  rand  bit           [31:0]  data;
        int unsigned          length;
        byte                  byte_enable[];
        int                   byte_enable_length;
  rand  bit           [3:0]   delay;              // num of cycles for which pready will be kept off

  `uvm_object_utils_begin(apb_transaction)
    `uvm_field_int(data   , UVM_DEFAULT)
    `uvm_field_int(delay  , UVM_DEFAULT)
  `uvm_object_utils_end

  function void do_record(uvm_recorder recorder);
    super.do_record(recorder);
    `uvm_record_field("addr", address);
    `uvm_record_field("data", data);
    `uvm_record_field("delay", delay);
  endfunction

  function new(string name = "apb_transaction");
    super.new(name);
  endfunction

  constraint c1 {
    delay inside {[0:4]};
  }

  function string convert2string();
    return $sformatf(
      "address=0x%x, command=%d, data=0x%x, length=%d, delay=%d",
      address, command, data, length, delay
    );
  endfunction

endclass

`endif  // APB_TRANSACTION_SVH_
