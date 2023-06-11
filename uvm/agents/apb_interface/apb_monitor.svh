class apb_monitor extends uvm_monitor;
  uvm_analysis_port#(apb_seq_item) mon_analysis_port;
  apb_seq_item act_trans;
  virtual apb_interface vif;

  `uvm_component_utils(apb_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    act_trans = new();
    mon_analysis_port = new("mon_analysis_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_interface)::get(this, "", "apb_intf", vif))
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      collect_trans();
      //mon_analysis_port.write(act_trans);
    end
  endtask

  task collect_trans();
    @(vif.monitor_cb.psel or
      vif.monitor_cb.pwrite or
      vif.monitor_cb.penable or
      vif.monitor_cb.pready or
      vif.monitor_cb.prdata);

    if (vif.monitor_cb.psel) begin
      act_trans.command = vif.monitor_cb.pwrite ? 1 : 0;

      wait(vif.monitor_cb.penable);

      wait(vif.monitor_cb.pready);

      if(act_trans.command == 1)
        `uvm_info(get_full_name(), $sformatf("WRITE TRANSACTION FROM DUT: %p", act_trans.sprint()), UVM_HIGH)
      else
        `uvm_info(get_full_name(), $sformatf("READ TRANSACTION FROM DUT: %p", act_trans.sprint()), UVM_HIGH)
    end

    `uvm_info(get_full_name(), $sformatf("TRANSACTION FROM MONITOR"), UVM_LOW);
    act_trans.print();
  endtask

endclass