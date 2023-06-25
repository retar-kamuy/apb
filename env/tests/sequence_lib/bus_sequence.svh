`ifndef BUS_SEQUENCE_SVH_
`define BUS_SEQUENCE_SVH_

// class bus_sequence extends uvm_sequence;
class bus_sequence #(type REQ=bus_seq_item, type RSP=bus_seq_item) extends uvm_sequence #(REQ, RSP);
  `uvm_object_utils(bus_sequence)

  function new(string name="bus_sequence");
    super.new(name);
  endfunction

  virtual task body();
    for (int i = 0; i < 256; i++) begin
      // bus_seq_item req = bus_seq_item::type_id::create("req");
      REQ req = REQ::type_id::create("req");
      wait_for_grant();
      assert(req.randomize());
      `uvm_info(get_full_name(), $sformatf("RANDOMIZED TRANSACTION FROM SEQUENCE: %s", req.convert2string()), UVM_LOW);
      // req.print();
      send_request(req);
      `uvm_info(get_full_name(), $sformatf("WAIT FOR RESPONSE FROM DRIVER"), UVM_LOW);
      wait_for_item_done();
      get_response(rsp);
      `uvm_info(get_full_name(), $sformatf("GET RESPONSE STATUS FROM DRIVER: %s", rsp.get_response_status()), UVM_LOW);
      // rsp.print();
    end
  endtask

endclass

`endif  // BUS_SEQUENCE_SVH_
