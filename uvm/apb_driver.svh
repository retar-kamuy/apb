class apb_driver extends uvm_driver #(apb_seq_item);
  virtual apb_interface vif;

  `uvm_component_utils(apb_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_interface)::get(this, "", "apb_intf", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction

  virtual task run_phase(uvm_phase phase);
    apb_seq_item item;
    //reset();
    forever begin
      seq_item_port.get_next_item(item);
      //drive(item);
      `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_HIGH)
      seq_item_port.item_done();
    end
  endtask

  task drive(apb_seq_item item);
    wait(vif.presetn);
    @(vif.requester_cb);
      vif.requester_cb.penable <= 1;
      vif.requester_cb.pstrb <= item.length;
      vif.requester_cb.paddr <= item.address;
      vif.requester_cb.pwrite <= item.data;
    @(vif.requester_cb);
      vif.requester_cb.penable <= 0;
  endtask

  task reset();
    vif.requester_cb.paddr    <= 0;
    vif.requester_cb.pprot    <= 0;
    vif.requester_cb.pnse     <= 0;
    vif.requester_cb.psel     <= 0;
    vif.requester_cb.penable  <= 0;
    vif.requester_cb.pwrite   <= 0;
    vif.requester_cb.pwdata   <= 0;
    vif.requester_cb.pstrb    <= 0;
  endtask

endclass
