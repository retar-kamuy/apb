`ifndef BUS_MONITOR_SVH_
`define BUS_MONITOR_SVH_

class bus_monitor extends uvm_monitor;
  `uvm_component_utils(bus_monitor)

  uvm_analysis_port#(bus_transaction) bus_analysis_port;
  bus_transaction act_trans;
  virtual bus_interface vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    act_trans = new();
    bus_analysis_port = new("bus_analysis_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual bus_interface)::get(this, "", "bus_intf", vif))
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      collect_trans();
      bus_analysis_port.write(act_trans);
    end
  endtask

  task collect_trans();
    @(vif.monitor_cb.en or
      vif.monitor_cb.we or
      vif.monitor_cb.addr or
      vif.monitor_cb.din or
      vif.monitor_cb.busy or
      vif.monitor_cb.dout or
      vif.monitor_cb.err
    );

    if (vif.monitor_cb.en) begin
      act_trans.address = vif.slave_cb.addr;
      act_trans.command = |vif.monitor_cb.we;
      act_trans.byte_enable = vif.monitor_cb.we;

      wait(~vif.monitor_cb.busy);

      if (|vif.monitor_cb.we)
        act_trans.data = vif.monitor_cb.din;
      else
        act_trans.data = vif.monitor_cb.dout;
      act_trans.response_status = vif.monitor_cb.err;

      `uvm_info(get_full_name(), $sformatf("TRANSACTION FROM MONITOR: %s", act_trans.convert2string()), UVM_LOW);
      // act_trans.print();
    end
  endtask

endclass

`endif  // BUS_MONITOR_SVH_
