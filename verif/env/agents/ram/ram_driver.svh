`ifndef RAM_DRIVER_SVH_
`define RAM_DRIVER_SVH_

class ram_driver extends uvm_driver #(ram_transaction);
  virtual ram_interface vif;

  `uvm_component_utils(ram_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ram_interface)::get(this, "", "ram_if", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction

  virtual task run_phase(uvm_phase phase);
    ram_transaction req;
    ram_transaction rsp;

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

  task drive(ram_transaction req);
    wait(~vif.master_cb.busy);
    vif.master_cb.en <= 1;
    vif.master_cb.we <= req.byte_enable;
    vif.master_cb.addr <= req.address;
    vif.master_cb.din <= req.data;
    @(vif.master_cb);
    vif.master_cb.en <= 0;
    @(vif.master_cb);
  endtask

  task response(input ram_transaction req, output ram_transaction rsp);
    wait(~vif.master_cb.busy);
    rsp = ram_transaction::type_id::create("rsp");
    rsp.set_id_info(req);
    rsp.response_status = vif.master_cb.err == 0 ? 1 : -1;
  endtask

  task reset();
    vif.master_cb.en <= 0;
    vif.master_cb.we <= 0;
    vif.master_cb.addr <= 0;
    vif.master_cb.din <= 0;
  endtask

endclass

`endif  // RAM_DRIVER_SVH_
