`include "uvm_macros.svh"
`include "prj_pkg.svh"

module tb_top;
  import uvm_pkg::*;
  import prj_pkg::*;

  logic clk;
  logic rst_n;

  apb_interface apb_intf (clk, rst_n);
  bus_interface bus_intf (clk, rst_n);

  clk_rst_gen #(
    .CLK_PERIOD(10)
  ) u_clk_rst_gen (
    .rst_n  (rst_n  ),
    .clk    (clk    )
  );

  apb #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32)
  ) u_apb (
    .pclk       (clk                  ),
    .presetn    (rst_n                ),
    // Requester
    .paddr      (apb_intf.paddr       ),
    .pprot      (apb_intf.pprot       ),
    .pnse       (apb_intf.pnse        ),
    .psel       (apb_intf.psel        ),
    .penable    (apb_intf.penable     ),
    .pwrite     (apb_intf.pwrite      ),
    .pwdata     (apb_intf.pwdata      ),
    .pstrb      (apb_intf.pstrb       ),
    // Completer
    .pready     (apb_intf.pready      ),
    .prdata     (apb_intf.prdata      ),
    .pslverr    (apb_intf.pslverr     ),
    // Local Inerface
    .en   (bus_intf.en    ),
    .we   (bus_intf.we    ),
    .addr (bus_intf.addr  ),
    .din  (bus_intf.din   ),
    .busy (bus_intf.busy  ),
    .dout (bus_intf.dout  ),
    .err  (bus_intf.err   )
  );

  initial begin
    uvm_config_db#(virtual apb_interface)::set(uvm_root::get(), "*", "apb_intf", apb_intf);
    uvm_config_db#(virtual bus_interface)::set(uvm_root::get(), "*", "bus_intf", bus_intf);
    $dumpfile("wave.vcd"); $dumpvars;
  end

  initial begin
    run_test("apb_base_test");
  end

endmodule

bind tb_top.u_apb apb_interface_assertions apb_interface_sva_inst (
  pclk,
  presetn,
  paddr,
  pprot,
  pnse,
  psel,
  penable,
  pwrite,
  pwdata,
  pstrb,
  pready,
  prdata,
  pslverr
);
