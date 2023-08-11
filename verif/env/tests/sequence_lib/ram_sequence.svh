`ifndef RAM_SEQUENCE_SVH_
`define RAM_SEQUENCE_SVH_

// class ram_sequence extends uvm_sequence;
class ram_sequence #(type REQ=apb_transaction, type RSP=apb_transaction) extends uvm_sequence #(REQ, RSP);
  `uvm_object_utils(ram_sequence)

  function new(string name="ram_sequence");
    super.new(name);
  endfunction

  virtual task body();
    for (int i = 0; i < 256; i++) begin
      // apb_transaction req = apb_transaction::type_id::create("req");
      REQ req = REQ::type_id::create("req");
      wait_for_grant();
      assert(req.randomize());
      `uvm_info(get_full_name(), $sformatf("RANDOMIZED TRANSACTION FROM SEQUENCE: %s", req.convert2string()), UVM_LOW)
      // req.print();
      send_request(req);
      `uvm_info(get_full_name(), $sformatf("WAIT FOR RESPONSE FROM DRIVER"), UVM_LOW)
      wait_for_item_done();
      get_response(rsp);
      `uvm_info(get_full_name(), $sformatf("GET RESPONSE STATUS FROM DRIVER: %s", rsp.get_response_status()), UVM_LOW)
      // rsp.print();
    end
  endtask

endclass

`endif  // RAM_SEQUENCE_SVH_
