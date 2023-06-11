class apb_sequence extends uvm_sequence;
  `uvm_object_utils(apb_sequence)

  function new(string name="apb_sequence");
    super.new(name);
  endfunction

  virtual task body();
    for (int i = 0; i < 4; i++) begin
      apb_seq_item item = apb_seq_item::type_id::create("item");
      start_item(item);
      assert(item.randomize());  
      `uvm_info(get_full_name(), $sformatf("RANDOMIZED TRANSACTION FROM SEQUENCE"),UVM_LOW);
      `uvm_info(get_full_name(),  $sformatf("Generate new item: %s", item.convert2str()), UVM_HIGH)
      item.print();
      finish_item(item);
    end
    //forever begin
    //  apb_seq_item req = apb_seq_item::type_id::create("req");
    //  start_item(req);
    //  req.randomize();
    //  `uvm_info("SEQ", $sformatf("Generate new item: %s", req.convert2str()), UVM_HIGH)
    //  finish_item(req);
    //  
    //  //apb_seq_item req = apb_seq_item::type_id::create("req");
    //  //apb_seq_item rsp = apb_seq_item::type_id::create("rsp");
    //  //wait_for_grant();
    //  //send_request(req);
    //  //get_response(rsp);
    //end
  endtask

endclass
