`ifndef PRJ_PKG_SVH_
`define PRJ_PKG_SVH_

`include "apb_interface.svh"
`include "bus_interface.svh"
`include "uvm_macros.svh"

package prj_pkg;
  import uvm_pkg::*;
  `include "agents/bus_interface/bus_seq_item.svh"
  `include "agents/bus_interface/bus_monitor.svh"
  `include "agents/bus_interface/bus_driver.svh"
  `include "agents/bus_interface/bus_sequence.svh"
  `include "agents/bus_interface/bus_agent.svh"
  `include "agents/apb_interface/apb_seq_item.svh"
  `include "agents/apb_interface/apb_monitor.svh"
  // `include "apb_scoreboard.svh"
  `include "agents/apb_interface/apb_driver.svh"
  `include "agents/apb_interface/apb_sequence.svh"
  `include "agents/apb_interface/apb_agent.svh"
  `include "apb_env.svh"
  `include "apb_test.svh"
endpackage

`endif  // PRJ_PKG_SVH_
