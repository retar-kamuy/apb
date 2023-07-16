class apb_driver extends uvm_driver #(apb_transaction);
  virtual apb_interface vif;
  int unsigned slv_memory [bit [31:0]];

  `uvm_component_utils(apb_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_interface)::get(this, "", "apb_if", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction

  virtual task run_phase(uvm_phase phase);
    apb_transaction req;

    reset();
    wait(vif.presetn);
    repeat(10) @(vif.slave_cb);

    forever begin
      seq_item_port.get_next_item(req);
      drive(req);
      `uvm_info(get_full_name(), $sformatf("TRANSACTION FROM DRIVER"), UVM_LOW);
      seq_item_port.item_done();
    end
  endtask

  task reset();
    vif.slave_cb.pready   <= 0;
    vif.slave_cb.prdata   <= 0;
    vif.slave_cb.pslverr  <= 0;
  endtask

  task drive(apb_transaction req);
    wait(vif.slave_cb.psel);
    repeat(req.delay) @(vif.slave_cb);

    vif.slave_cb.pready <= 1;
    `uvm_info(get_full_name(), $sformatf("PREADY ASSERT FROM DRIVER"), UVM_LOW);
    @(vif.slave_cb);

    `uvm_info(get_full_name(), $sformatf("WAIT FOR PENABLE FROM DUT"), UVM_LOW);
    wait(vif.monitor_cb.penable);
    vif.slave_cb.pready <= 0;
    `uvm_info(get_full_name(), $sformatf("PREADY NEGATEASSERT FROM DRIVER"), UVM_LOW);
  endtask

endclass
