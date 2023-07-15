`ifndef RAM_INTERFACE_SVH_
`define RAM_INTERFACE_SVH_

interface ram_interface #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
) (
  input clk,
  input rst_n
);
  logic                     en;
  logic [DATA_WIDTH/8-1:0]  we;
  logic [ADDR_WIDTH-1:0]    addr;
  logic [DATA_WIDTH-1:0]    din;
  logic                     busy;
  logic [DATA_WIDTH-1:0]    dout;
  logic                     err;

  clocking master_cb @(posedge clk);
    output  en;
    output  we;
    output  addr;
    output  din;
    input   busy;
    input   dout;
    input   err;
  endclocking

  modport master (
    input     clk,
    input     rst_n,
    clocking  master_cb
  );

  clocking slave_cb @(posedge clk);
    input   en;
    input   we;
    input   addr;
    input   din;
    output  busy;
    output  dout;
    output  err;
  endclocking

  modport slave (
    input     clk,
    input     rst_n,
    clocking  slave_cb
  );

  clocking monitor_cb @(posedge clk);
    input en;
    input we;
    input addr;
    input din;
    input busy;
    input dout;
    input err;
  endclocking

modport monitor (clocking monitor_cb);

endinterface

`endif  // RAM_INTERFACE_SVH_
