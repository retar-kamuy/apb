class apb_driver extends uvm_driver #(apb_seq_item);
  virtual apb_interface vif;
  int unsigned slv_memory [bit [31:0]];

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
    apb_seq_item req;

    reset();
    wait(vif.presetn);

    forever begin
      seq_item_port.get_next_item(req);
      drive(req);
      `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_HIGH)
      seq_item_port.item_done();
    end
  endtask

  task reset();
    vif.slave_cb.pready   <= 0;
    vif.slave_cb.prdata   <= 0;
    vif.slave_cb.pslverr  <= 0;
  endtask

  task drive(apb_seq_item req);
//    @(vif.slave_cb.paddr or vif.slave_cb.pwrite);
    //@(vif.slave_cb.psel);

    if(vif.slave_cb.pwrite) begin
      vif.slave_cb.pready <= 0;
      repeat(req.num_of_wait_cycles) @(vif.pclk);
      vif.slave_cb.pready <= 1;
//
//      slv_memory[vif.slave_cb.paddr] = vif.slave_cb.pwdata;
    end else begin
      vif.slave_cb.pready <= 0;
      repeat(req.num_of_wait_cycles) @(vif.pclk);
      vif.slave_cb.pready <= 1;
//
//      if(slv_memory.exists(vif.slave_cb.paddr))
//        vif.slave_cb.prdata <= slv_memory[vif.slave_cb.paddr];
//      else
//        vif.slave_cb.prdata <= 'hzzzzzzzz; // no data in slave with that address
//
    end
  endtask

endclass
