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
  input         [DATA_WIDTH/8-1:0]  bus_wstb,
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

  assign pprot = 3'd0;
  assign pnse = 1'd0;

  logic [DATA_WIDTH/8-1:0] pipeline_inst;
  logic [DATA_WIDTH-1:0] pipeline_data;
  logic [ADDR_WIDTH-1:0] pipeline_addr;
  always_ff @(posedge pclk or negedge presetn)
    if (~presetn) begin
      pipeline_inst <= (DATA_WIDTH/8)'(1'd0);
      pipeline_data <= DATA_WIDTH'(1'd0);
      pipeline_addr <= ADDR_WIDTH'(1'd0);
    end else
      case (state)
        IDLE: begin
          pipeline_inst <= bus_wstb;
          pipeline_data <= bus_wdata;
          pipeline_addr <= bus_addr;
        end
        SETUP: begin
          pipeline_inst <= (DATA_WIDTH/8)'(1'd0);
          pipeline_data <= DATA_WIDTH'(1'd0);
          pipeline_addr <= ADDR_WIDTH'(1'd0);
        end
        ACCESS: begin
          pipeline_data <= DATA_WIDTH'(1'd0);
          pipeline_addr <= ADDR_WIDTH'(1'd0);
        end
        default: begin
          pipeline_inst <= pipeline_inst;
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
          pwrite <= |pipeline_inst;
          psel <= 1'd1;
          pwdata <= pipeline_data;
          pstrb <= pipeline_inst;
        end
        ACCESS: begin
          if (pready) begin
            psel <= 1'd0;
            penable <= 1'd0;
          end
          else begin
            psel <= 1'd1;
            penable <= 1'd1;
          end
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
      if (~(|pipeline_inst))
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
