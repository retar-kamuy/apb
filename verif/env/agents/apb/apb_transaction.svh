`ifndef APB_TRANSACTION_SVH_
`define APB_TRANSACTION_SVH_

class apb_transaction extends uvm_sequence_item;
        bit           [63:0]  address;
        int                   command;
  rand  bit           [31:0]  data;
        bit           [3:0]   byte_enable;
        int                   response_status;
  rand  bit           [3:0]   delay;              // num of cycles for which pready will be kept off

  `uvm_object_utils_begin(apb_transaction)
    `uvm_field_int(address          , UVM_DEFAULT)
    `uvm_field_int(command          , UVM_DEFAULT)
    `uvm_field_int(data             , UVM_DEFAULT)
    `uvm_field_int(byte_enable      , UVM_DEFAULT)
    `uvm_field_int(response_status  , UVM_DEFAULT)
    `uvm_field_int(delay            , UVM_DEFAULT)
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
    data  inside  {[0:32'hFFFF_FFFF]};
    delay inside {[0:4]};
  }

  function string convert2string();
    return $sformatf(
      "address=0x%x, command=%d, data=0x%x, response_status=%d, delay=%d",
      address, command, data, response_status, delay
    );
  endfunction

  function string get_response_status();
    case (response_status)
       1: return "UVM_TLM_OK_RESPONSE(1)";
       0: return "UVM_TLM_INCOMPLETE_RESPONSE(0)";
      -1: return "UVM_TLM_GENERIC_ERROR_RESPONSE(-1)";
      -2: return "UVM_TLM_ADDRESS_ERROR_RESPONSE(-2)";
      -3: return "UVM_TLM_COMMAND_ERROR_RESPONSE(-3)";
      -4: return "UVM_TLM_BURST_ERROR_RESPONSE(-4)";
      -5: return "UVM_TLM_BYTE_ENABLE_ERROR_RESPONSE(-5)";
    endcase
  endfunction

endclass

`endif  // APB_TRANSACTION_SVH_
