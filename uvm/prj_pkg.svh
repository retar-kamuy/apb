`ifndef PRJ_PKG_SVH_
`define PRJ_PKG_SVH_

`include "apb_interface.svh"
`include "bus_interface.svh"
`include "uvm_macros.svh"

package prj_pkg;
  import uvm_pkg::*;
  `include "apb_seq_item.svh"
  `include "bus_seq_item.svh"
  `include "apb_monitor.svh"
  `include "bus_monitor.svh"
  // `include "apb_scoreboard.svh"
  `include "apb_driver.svh"
  `include "bus_driver.svh"
  `include "apb_sequence.svh"
  `include "bus_sequence.svh"
  `include "apb_agent.svh"
  `include "bus_agent.svh"
  `include "apb_env.svh"
  `include "apb_test.svh"
endpackage

`endif  // PRJ_PKG_SVH_
