`include "uvm_macros.svh"
`include "defines.svh"
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
    .bus_ena    (bus_intf.bus_ena     ),
    .bus_wstb   (bus_intf.bus_wstb    ),
    .bus_addr   (bus_intf.bus_addr    ),
    .bus_wdata  (bus_intf.bus_wdata   ),
    .bus_ready  (bus_intf.bus_ready   ),
    .bus_rdata  (bus_intf.bus_rdata   ),
    .bus_slverr (bus_intf.bus_slverr  )
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
