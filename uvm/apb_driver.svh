class apb_driver extends uvm_driver #(apb_seq_item);
  // virtual apb_if vif;
  virtual bus_interface vif;

  `uvm_component_utils(apb_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual bus_interface)::get(this, "", "intf", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction

  virtual task run_phase(uvm_phase phase);
    apb_seq_item item;
    reset();
    forever begin
      seq_item_port.get_next_item(item);
      drive(item);
      `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_HIGH)
      seq_item_port.item_done();
    end
  endtask

  task drive(apb_seq_item item);
    wait(vif.rst_n);
    @(vif.master_cb);
      vif.master_cb.bus_ena <= 1;
      vif.master_cb.bus_wstb <= item.length;
      vif.master_cb.bus_addr <= item.address;
      vif.master_cb.bus_wdata <= item.data;
    @(vif.master_cb);
      vif.master_cb.bus_ena <= 0;
  endtask

  task reset();
    vif.master_cb.bus_ena <= 0;
    vif.master_cb.bus_wstb <= 0;
    vif.master_cb.bus_addr <= 0;
    vif.master_cb.bus_wdata <= 0;
  endtask

endclass
