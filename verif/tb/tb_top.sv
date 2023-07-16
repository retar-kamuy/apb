`include "uvm_macros.svh"
`include "prj_pkg.svh"

module tb_top;
  import uvm_pkg::*;
  import prj_pkg::*;

  logic clk;
  logic rst_n;

  apb_interface apb_if (clk, rst_n);
  ram_interface ram_if (clk, rst_n);

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
    .pclk       (clk            ),
    .presetn    (rst_n          ),
    // Requester
    .paddr      (apb_if.paddr   ),
    .pprot      (apb_if.pprot   ),
    .pnse       (apb_if.pnse    ),
    .psel       (apb_if.psel    ),
    .penable    (apb_if.penable ),
    .pwrite     (apb_if.pwrite  ),
    .pwdata     (apb_if.pwdata  ),
    .pstrb      (apb_if.pstrb   ),
    // Completer
    .pready     (apb_if.pready  ),
    .prdata     (apb_if.prdata  ),
    .pslverr    (apb_if.pslverr ),
    // Local Inerface
    .en         (ram_if.en      ),
    .we         (ram_if.we      ),
    .addr       (ram_if.addr    ),
    .din        (ram_if.din     ),
    .busy       (ram_if.busy    ),
    .dout       (ram_if.dout    ),
    .err        (ram_if.err     )
  );

  initial begin
    uvm_config_db#(virtual apb_interface)::set(uvm_root::get(), "*", "apb_if", apb_if);
    uvm_config_db#(virtual ram_interface)::set(uvm_root::get(), "*", "ram_if", ram_if);
    $dumpfile("wave.vcd"); $dumpvars;
  end

  initial begin
    run_test("apb_base_test");
  end

endmodule

bind tb_top.u_apb apb_assertions apb_sva_inst (
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
  pslverr,
  en,
  we,
  addr,
  din,
  busy,
  dout,
  err
);
