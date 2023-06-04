interface apb_if #(
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
  logic                     prdata;
  logic                     pslverr;

  modport requester (
    input   pclk,
    input   presetn,
    output  paddr,
    output  pprot,
    output  pnse,
    output  psel,
    output  penable,
    output  pwrite,
    output  pready,
    output  pwdata,
    output  pstrb,
    input   prdata,
    input   pslverr
  );

  modport completer (
    input   pclk,
    input   presetn,
    input   paddr,
    input   pprot,
    input   pnse,
    input   psel,
    input   penable,
    input   pwrite,
    input   pwdata,
    input   pstrb,
    output  pready,
    output  prdata,
    output  pslverr
  );

  clocking cb @(posedge pclk);
    default input #1step output #3ns;
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

endinterface
