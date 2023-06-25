`ifndef BUS_DRIVER_SVH_
`define BUS_DRIVER_SVH_

class bus_driver extends uvm_driver #(bus_transaction);
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
    bus_transaction req;
    bus_transaction rsp;

    reset();
    wait(vif.rst_n);
    repeat(10) @(vif.master_cb);

    forever begin
      seq_item_port.get_next_item(req);
      drive(req);
      `uvm_info(get_full_name(), $sformatf("TRANSACTION FROM DRIVER"), UVM_LOW);
      response(req, rsp);
      `uvm_info(get_full_name(), $sformatf("RESPONSE FROM DUT"), UVM_LOW);
      seq_item_port.item_done(rsp);
    end
  endtask

  task drive(bus_transaction req);
    wait(~vif.master_cb.bus_wait);
    vif.master_cb.bus_ena <= 1;
    vif.master_cb.bus_wstb <= req.byte_enable;
    vif.master_cb.bus_addr <= req.address;
    vif.master_cb.bus_wdata <= req.data;
    @(vif.master_cb);
    vif.master_cb.bus_ena <= 0;
    @(vif.master_cb);
  endtask

  task response(input bus_transaction req, output bus_transaction rsp);
    wait(~vif.master_cb.bus_wait);
    rsp = bus_transaction::type_id::create("rsp");
    rsp.set_id_info(req);
    rsp.response_status = vif.master_cb.bus_slverr == 0 ? 1 : -1;
  endtask

  task reset();
    vif.master_cb.bus_ena <= 0;
    vif.master_cb.bus_wstb <= 0;
    vif.master_cb.bus_addr <= 0;
    vif.master_cb.bus_wdata <= 0;
  endtask

endclass

`endif  // BUS_DRIVER_SVH_
