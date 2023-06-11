`timescale 1ns / 1ns

module clk_rst_gen #(
  parameter CLK_PERIOD = 10ns
) (
  output logic rst_n,
  output logic clk
);

  initial begin
    rst_n = 0;

    wait(clk);

    #(CLK_PERIOD * 5)
    rst_n = 1;
  end

  initial begin
    clk = 0;
    forever begin
      #(CLK_PERIOD / 2) clk = ~clk;
    end
  end

endmodule
