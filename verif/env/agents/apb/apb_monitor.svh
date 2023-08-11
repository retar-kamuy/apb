class apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_monitor)

  uvm_analysis_port#(apb_transaction) analysis_port;
  apb_transaction act_trans;
  virtual apb_interface vif;

  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event ev;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    act_trans = new();
    analysis_port = new("analysis_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_interface)::get(this, "", "apb_if", vif))
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      act_trans = apb_transaction::type_id::create("act_trans");
      // act_trans.num_of_wait_cycles = 1;
      ev = ev_pool.get("mon_ev");
      ev.trigger(act_trans);
      collect_trans();
      // if (vif.monitor_cb.psel && vif.monitor_cb.penable) begin
      //   analysis_port.write(act_trans);
      // end
    end
  endtask

  task collect_trans();
    @(vif.monitor_cb.penable or vif.monitor_cb.pready);

    if (vif.monitor_cb.psel && vif.monitor_cb.penable && vif.monitor_cb.pready) begin
      act_trans.address = vif.monitor_cb.paddr;
      act_trans.command = vif.monitor_cb.pwrite;
      act_trans.byte_enable = 4'(vif.monitor_cb.pstrb);
      act_trans.data = vif.monitor_cb.pwdata;
      act_trans.response_status = vif.monitor_cb.pslverr;

      if(act_trans.command == 1)
        `uvm_info(get_full_name(), $sformatf("WRITE TRANSACTION FROM DUT: %p", act_trans.sprint()), UVM_HIGH)
      else
        `uvm_info(get_full_name(), $sformatf("READ TRANSACTION FROM DUT: %p", act_trans.sprint()), UVM_HIGH)
      analysis_port.write(act_trans);
    end

    `uvm_info(get_full_name(), $sformatf("TRANSACTION FROM MONITOR"), UVM_LOW);
    // act_trans.print();
  endtask

endclass