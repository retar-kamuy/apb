`ifndef APB_INTERFACE_SVH_
`define APB_INTERFACE_SVH_

interface apb_interface #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
) (
  input pclk,
  input presetn
);
  // Requester
  logic [ADDR_WIDTH-1:0]    paddr;
  logic [2:0]               pprot;
  logic                     pnse;
  logic                     psel;
  logic                     penable;
  logic                     pwrite;
  logic [DATA_WIDTH-1:0]    pwdata;
  logic [DATA_WIDTH/8-1:0]  pstrb;
  // Completer
  logic                     pready;
  logic [DATA_WIDTH-1:0]    prdata;
  logic                     pslverr;

  clocking master_cb @(posedge pclk);
    output  paddr;
    output  pprot;
    output  pnse;
    output  psel;
    output  penable;
    output  pwrite;
    output  pwdata;
    output  pstrb;
    input   pready;
    input   prdata;
    input   pslverr;
  endclocking

  modport master (
    input     pclk,
    input     presetn,
    clocking  master_cb
  );

  clocking slave_cb @(posedge pclk);
    input   paddr;
    input   pprot;
    input   pnse;
    input   psel;
    input   penable;
    input   pwrite;
    input   pwdata;
    input   pstrb;
    output  pready;
    output  prdata;
    output  pslverr;
  endclocking

  modport slave (
    input     pclk,
    input     presetn,
    clocking  slave_cb
  );

 clocking monitor_cb @(posedge pclk);
    input   paddr;
    input   pprot;
    input   pnse;
    input   psel;
    input   penable;
    input   pwrite;
    input   pwdata;
    input   pstrb;
    input   pready;
    input   prdata;
    input   pslverr;
  endclocking

  modport monitor (
    clocking  monitor_cb
  );

endinterface

`endif  // APB_INTERFACE_SVH_
