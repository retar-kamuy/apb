`ifndef PRJ_PKG_SVH_
`define PRJ_PKG_SVH_

`include "apb_interface.svh"
`include "ram_interface.svh"
`include "uvm_macros.svh"

package prj_pkg;
  import uvm_pkg::*;
  `include "../env/agents/apb/apb_transaction.svh"
  `include "../env/agents/apb/apb_monitor.svh"
  `include "../env/agents/apb/apb_scoreboard.svh"
  `include "../env/agents/apb/apb_driver.svh"
  `include "../env/agents/ram/ram_monitor.svh"
  `include "../env/agents/ram/ram_driver.svh"
  `include "../env/tests/sequence_lib/ram_sequence.svh"
  `include "../env/agents/ram/ram_agent.svh"
  `include "../env/tests/sequence_lib/apb_sequence.svh"
  `include "../env/agents/apb/apb_agent.svh"
  `include "../env/top/ram_coverage.svh"
  `include "../env/top/apb_env.svh"
  `include "../env/tests/apb_test.svh"
endpackage

`endif  // PRJ_PKG_SVH_
