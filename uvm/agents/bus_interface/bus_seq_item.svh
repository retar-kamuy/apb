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
    `uvm_field_int      (address            , UVM_ALL_ON)
    `uvm_field_int      (command            , UVM_ALL_ON)
    `uvm_field_int      (data               , UVM_ALL_ON)
    `uvm_field_int      (length             , UVM_ALL_ON)
    `uvm_field_array_int(byte_enable        , UVM_ALL_ON)
    `uvm_field_int      (byte_enable_length , UVM_ALL_ON)
    `uvm_field_int      (response_status    , UVM_ALL_ON)
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
    return $sformatf(
      "address=0x%x, command=%d, data=0x%x, length=%d, response_status=%d",
      address, command, data, length, response_status
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

`endif  // BUS_SEQ_ITEM_SVH_
