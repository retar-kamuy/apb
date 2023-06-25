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
  input         [DATA_WIDTH-1:0]    prdata,
  input                             pslverr,
  // Local Inerface
  input                             bus_ena,
  input         [2:0]               a_code,
  input         [DATA_WIDTH-1:0]    bus_addr,
  input         [DATA_WIDTH-1:0]    bus_wdata,
  output  logic                     bus_wait,
  output  logic [DATA_WIDTH-1:0]    bus_rdata,
  output  logic                     bus_slverr
);
  enum logic [1:0] {
    IDLE = 0,
    SETUP = 1,
    ACCESS = 2
  } state;

  enum logic [2:0] {
    PUT_FULL_DATA = 0,
    PUT_PARTIAL_DATA = 1,
    GET = 4
  } request;

  enum logic [2:0] {
    ACCESS_ACK = 0,
    ACCESS_ACK_DATA = 1
  } response;

  assign pprot = 3'd0;
  assign pnse = 1'd0;

  logic [DATA_WIDTH/8-1:0] pipeline_opcode;
  logic [DATA_WIDTH-1:0] pipeline_data;
  logic [ADDR_WIDTH-1:0] pipeline_addr;
  always_ff @(posedge pclk or negedge presetn)
    if (~presetn) begin
      pipeline_opcode <= 3'd0;
      pipeline_data <= DATA_WIDTH'(1'd0);
      pipeline_addr <= ADDR_WIDTH'(1'd0);
    end else
      case (state)
        IDLE: begin
          pipeline_opcode <= a_code;
          pipeline_data <= bus_wdata;
          pipeline_addr <= bus_addr;
        end
        SETUP: begin
          pipeline_opcode <= 3'd0;
          pipeline_data <= DATA_WIDTH'(1'd0);
          pipeline_addr <= ADDR_WIDTH'(1'd0);
        end
        ACCESS: begin
          pipeline_data <= DATA_WIDTH'(1'd0);
          pipeline_addr <= ADDR_WIDTH'(1'd0);
        end
        default: begin
          pipeline_opcode <= pipeline_opcode;
          pipeline_data <= pipeline_data;
          pipeline_addr <= pipeline_addr;
        end
      endcase

  always_ff @(posedge pclk or negedge presetn)
    if (~presetn) begin
      paddr <= ADDR_WIDTH'(1'd0);
      pwrite <= 1'd0;
      psel <= 1'd0;
      penable <= 1'd0;
      pwdata <= DATA_WIDTH'(1'd0);
      pstrb <= (DATA_WIDTH/8)'(1'd0);
    end else
      case (state)
        IDLE: begin
          paddr <= ADDR_WIDTH'(1'd0);
          pwrite <= 1'd0;
          psel <= 1'd0;
          penable <= 1'd0;
          pstrb <= (DATA_WIDTH/8)'(1'd0);
        end
        SETUP: begin
          paddr <= pipeline_addr;
          pwrite <= |pipeline_opcode;
          psel <= 1'd1;
          pwdata <= pipeline_data;
          pstrb <= pipeline_opcode;
        end
        ACCESS: begin
          penable <= 1'd1;
        end
        default: begin
          paddr <= paddr;
          pwrite <= pwrite;
          psel <= psel;
          penable <= penable;
          pwdata <= pwdata;
          pstrb <= pstrb;
        end
      endcase

  always_ff @(posedge pclk or negedge presetn)
    if (~presetn)
      bus_rdata <= DATA_WIDTH'(1'd0);
    else
      if (~(|pipeline_opcode))
        if (penable & pready)
          bus_rdata <= prdata;

  always_ff @(posedge pclk or negedge presetn)
    if (~presetn) begin
      bus_wait <= 1'd0;
      bus_slverr <= 1'd0;
    end else
      case (state)
        IDLE: begin
          bus_slverr <= 1'd0;
          if (bus_ena)
            bus_wait <= 1'd1;
        end
        ACCESS:
          if (pready) begin
            bus_wait <= 1'd0;
            bus_slverr <= pslverr;
          end
        default: begin
          bus_wait <= bus_wait;
          bus_slverr <= bus_slverr;
        end
      endcase

  always_ff @(posedge pclk or negedge presetn)
    if (~presetn)
      state <= IDLE;
    else
      case (state)
        IDLE:
          if (bus_ena)
            state <= SETUP;
        SETUP:
          state <= ACCESS;
        ACCESS:
          if (pready & bus_ena)
            state <= SETUP;
          else if (pready)
            state <= IDLE;
        default:
          state <= state;
      endcase

endmodule
