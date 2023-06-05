`ifndef BUS_MONITOR_SVH_
`define BUS_MONITOR_SVH_

class bus_monitor extends uvm_monitor;
  uvm_analysis_port#(bus_seq_item) mon_analysis_port;
  bus_seq_item act_trans;
  virtual bus_interface vif;

  `uvm_component_utils(bus_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    act_trans = new();
    mon_analysis_port = new("mon_analysis_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual bus_interface)::get(this, "", "bus_intf", vif))
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      collect_trans();
      //mon_analysis_port.write(act_trans);
    end
  endtask

  task collect_trans();
    //wait(vif.rst_n);
    @(vif.slave_cb);
      act_trans.address = vif.slave_cb.bus_addr;
      //act_trans.bus_ena = vif.slave_cb.bus_ena;
      act_trans.byte_enable_length = 4;
      for(int i = 0; i < 4; i++) begin
        act_trans.byte_enable[i] = vif.slave_cb.bus_wstb[i];
      end
      //act_trans.bus_wdata = vif.slave_cb.bus_wdata;
      //act_trans.bus_ready = vif.slave_cb.bus_ready;
      //act_trans.bus_rdata = vif.slave_cb.bus_rdata;
      //act_trans.bus_slverr = vif.slave_cb.bus_slverr;
    `uvm_info(get_full_name(), $sformatf("TRANSACTION FROM MONITOR"), UVM_LOW);
      act_trans.print();
  endtask

endclass

`endif  // BUS_MONITOR_SVH_
