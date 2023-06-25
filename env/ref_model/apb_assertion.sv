module apb_interface_assertions #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
) (
  input                           pclk,
  input                           presetn,
  // Requester
  input logic [ADDR_WIDTH-1:0]    paddr,
  input logic [2:0]               pprot,
  input logic                     pnse,
  input logic                     psel,
  input logic                     penable,
  input logic                     pwrite,
  input logic [DATA_WIDTH-1:0]    pwdata,
  input logic [DATA_WIDTH/8-1:0]  pstrb,
  // Completer
  input logic                     pready,
  input logic [DATA_WIDTH-1:0]    prdata,
  input logic                     pslverr
);

prop_a_cnt: assert property (
    @(posedge pclk) disable iff (~presetn)
    psel & penable & pready |=> ~psel & ~penable & ~pready
) else $fatal("prop_a_cnt : NG");

property valid_state;
    @(posedge pclk) disable iff (~presetn)
    pready |=> ~pready;
endproperty

prop_valid_state: assert property (valid_state) else $fatal("prop_valid_state : NG");

endmodule
