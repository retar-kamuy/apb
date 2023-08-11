class apb_sequence extends uvm_sequence;
  `uvm_object_utils(apb_sequence)

  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event ev;

  function new(string name="apb_sequence");
    super.new(name);
  endfunction

  virtual task body();
    forever begin
      apb_transaction req = apb_transaction::type_id::create("req");
      ev = ev_pool.get("mon_ev");
      ev.wait_trigger();
      $cast(req, ev.get_trigger_data());
      start_item(req);
      assert(req.randomize());
      `uvm_info(get_full_name(), $sformatf("RANDOMIZED TRANSACTION FROM SEQUENCE"), UVM_LOW)
      finish_item(req);
    end
  endtask

endclass
