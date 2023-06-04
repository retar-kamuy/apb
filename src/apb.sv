module apb #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
) (
  input                             pclk,
  input                             presetn,
  // Requester
  output  logic [ADDR_WIDTH-1:0]    paddr,
  output  logic [2:0]               pprot,
  output  logic                     pnse,
  output  logic                     psel,
  output  logic                     penable,
  output  logic                     pwrite,
  output  logic [DATA_WIDTH-1:0]    pwdata,
  output  logic [DATA_WIDTH/8-1:0]  pstrb,
  // Completer
  input                             pready,
  input                             prdata,
  input                             pslverr,
  // Local Inerface
  input                             bus_ena,
  input         [DATA_WIDTH/8-1:0]  bus_wstb,
  input         [DATA_WIDTH-1:0]    bus_addr,
  input         [DATA_WIDTH-1:0]    bus_wdata,
  output  logic                     bus_ready,
  output  logic [DATA_WIDTH-1:0]    bus_rdata,
  output  logic                     bus_slverr
);
  enum logic [1:0] {
    IDLE = 0,
    SETUP = 1,
    ACCESS = 2
  } state;

  assign pprot = 3'b000;
  assign pnse = 1'b0;

  logic usr_read_req;
  assign usr_read_req = bus_ena & ~(|bus_wstb);
  logic usr_write_req;
  assign usr_write_req = bus_ena & (|bus_wstb);
  logic transfer;
  assign transfer = usr_read_req | usr_write_req;

  logic exit_access;
  assign exit_access = penable & pready;

  always_ff @(posedge pclk or negedge presetn)
    if (~presetn) begin
      paddr <= ADDR_WIDTH'(1'd0);
      pwrite <= 1'b0;
      psel <= 1'b0;
      penable <= 1'b0;
      pwdata <= DATA_WIDTH'(1'd0);
    end else
      case (state)
        IDLE: begin
          paddr <= ADDR_WIDTH'(1'd0);
          pwrite <= 1'b0;
          psel <= 1'b0;
          penable <= 1'b0;
        end
        SETUP: begin
          paddr <= bus_addr;
          if (usr_write_req)
            pwrite <= 1'b1;
          psel <= 1'b1;
          pwdata <= bus_wdata;
        end
        ACCESS: begin
          penable <= 1'b1;
        end
      endcase

  always_ff @(posedge pclk or negedge presetn)
    if (~presetn)
      bus_rdata <= DATA_WIDTH'(1'd0);
    else
      if (exit_access)
        if (usr_read_req)
          bus_rdata <= prdata;

  always_ff @(posedge pclk or negedge presetn)
    if (~presetn) begin
      bus_ready <= 1'b0;
      bus_slverr <= 1'b0;
    end else
      case (state)
        IDLE: begin
          bus_ready <= 1'b0;
          bus_slverr <= 1'b0;
        end
        ACCESS:
          if (exit_access) begin
            bus_ready <= 1'b1;
            bus_slverr <= pslverr;
          end
      endcase

  always_ff @(posedge pclk or negedge presetn)
    if (~presetn)
      state <= IDLE;
    else
      case (state)
        IDLE:
          if (transfer)
            state <= SETUP;
        SETUP:
          state <= ACCESS;
        ACCESS:
          if (exit_access & transfer)
            state <= SETUP;
          else if (exit_access)
            state <= IDLE;
      endcase

endmodule
