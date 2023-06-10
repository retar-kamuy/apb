`ifndef BUS_DRIVER_SVH_
`define BUS_DRIVER_SVH_

class bus_driver extends uvm_driver #(bus_seq_item);
  virtual bus_interface vif;

  `uvm_component_utils(bus_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual bus_interface)::get(this, "", "bus_intf", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction

  virtual task run_phase(uvm_phase phase);
    bus_seq_item item;
    bus_seq_item rsp;
    reset();
    wait(vif.rst_n);
    forever begin
      seq_item_port.get_next_item(item);
      drive(item);
      `uvm_info(get_full_name(), $sformatf("TRANSACTION FROM DRIVER"), UVM_LOW);
      // seq_item_port.item_done(item);
      response(item, rsp);
      `uvm_info(get_full_name(), $sformatf("RESPONSE FROM DUT"), UVM_LOW);
      seq_item_port.item_done(rsp);
      // seq_item_port.put(rsp);
    end
  endtask

  task drive(bus_seq_item item);
    wait(vif.rst_n);
    @(vif.master_cb);
      vif.master_cb.bus_ena <= 1;
      vif.master_cb.bus_wstb <= item.length;
      vif.master_cb.bus_addr <= item.address;
      vif.master_cb.bus_wdata <= item.data;
    @(vif.master_cb);
      vif.master_cb.bus_ena <= 0;
    @(vif.master_cb.bus_ready);
  endtask

  task response(input bus_seq_item req, output bus_seq_item rsp);
    @(vif.master_cb.bus_ready);
      $cast(rsp, req.clone());
      rsp.set_id_info(req);
      rsp.response_status = vif.master_cb.bus_slverr;
      // rsp.response_status = 1;
  endtask

  task reset();
    vif.master_cb.bus_ena <= 0;
    vif.master_cb.bus_wstb <= 0;
    vif.master_cb.bus_addr <= 0;
    vif.master_cb.bus_wdata <= 0;
  endtask

endclass

`endif  // BUS_DRIVER_SVH_
