`ifndef BUS_INTERFACE_SVH_
`define BUS_INTERFACE_SVH_

interface bus_interface #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
) (
  input clk,
  input rst_n
);
  logic                     bus_ena;
  logic [DATA_WIDTH/8-1:0]  bus_wstb;
  logic [ADDR_WIDTH-1:0]    bus_addr;
  logic [DATA_WIDTH-1:0]    bus_wdata;
  logic                     bus_ready;
  logic [DATA_WIDTH-1:0]    bus_rdata;
  logic                     bus_slverr;

  clocking master_cb @(posedge clk);
    output  bus_ena;
    output  bus_wstb;
    output  bus_addr;
    output  bus_wdata;
    input   bus_ready;
    input   bus_rdata;
    input   bus_slverr;
  endclocking

  modport master (
    input     clk,
    input     rst_n,
    clocking  master_cb
  );

  clocking slave_cb @(posedge clk);
    input   bus_ena;
    input   bus_wstb;
    input   bus_addr;
    input   bus_wdata;
    output  bus_ready;
    output  bus_rdata;
    output  bus_slverr;
  endclocking

  modport slave (
    input     clk,
    input     rst_n,
    clocking  slave_cb
  );

  clocking monitor_cb @(posedge clk);
    input bus_ena;
    input bus_wstb;
    input bus_addr;
    input bus_wdata;
    input bus_ready;
    input bus_rdata;
    input bus_slverr;
  endclocking

modport monitor (clocking monitor_cb);

endinterface

`endif  // BUS_INTERFACE_SVH_
