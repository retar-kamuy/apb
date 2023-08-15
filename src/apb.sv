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
  input                             en,
  input         [DATA_WIDTH/8-1:0]  we,
  input         [DATA_WIDTH-1:0]    addr,
  input         [DATA_WIDTH-1:0]    din,
  output  logic                     busy,
  output  logic [DATA_WIDTH-1:0]    dout,
  output  logic                     err
);
  enum logic [1:0] {
    IDLE = 0,
    SETUP = 1,
    ACCESS = 2
  } state;

  assign pprot = 3'd0;
  assign pnse = 1'd0;

  logic [DATA_WIDTH/8-1:0] pipeline_pwrite;
  logic [DATA_WIDTH-1:0] pipeline_pwdata;
  logic [ADDR_WIDTH-1:0] pipeline_paddr;
  logic [DATA_WIDTH/8-1:0] pipeline_pstrb;
  always_ff @(posedge pclk or negedge presetn)
    if (~presetn) begin
      pipeline_pwrite <= (DATA_WIDTH/8)'(1'd0);
      pipeline_pwdata <= DATA_WIDTH'(1'd0);
      pipeline_paddr <= ADDR_WIDTH'(1'd0);
      pipeline_pstrb <= (DATA_WIDTH/8)'(1'd0);
    end else
      case (state)
        IDLE: begin
          pipeline_pwrite <= we;
          pipeline_pwdata <= din;
          pipeline_paddr <= addr;
          pipeline_pstrb <= we;
        end
        SETUP: begin
          pipeline_pwrite <= (DATA_WIDTH/8)'(1'd0);
          pipeline_pwdata <= DATA_WIDTH'(1'd0);
          pipeline_paddr <= ADDR_WIDTH'(1'd0);
          pipeline_pstrb <= (DATA_WIDTH/8)'(1'd0);
        end
        ACCESS: begin
          pipeline_pwdata <= DATA_WIDTH'(1'd0);
          pipeline_paddr <= ADDR_WIDTH'(1'd0);
        end
        default: begin
          pipeline_pwrite <= pipeline_pwrite;
          pipeline_pwdata <= pipeline_pwdata;
          pipeline_paddr <= pipeline_paddr;
          pipeline_pstrb <= pipeline_pstrb;
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
          paddr <= pipeline_paddr;
          pwrite <= |pipeline_pwrite;
          psel <= 1'd1;
          pwdata <= pipeline_pwdata;
          pstrb <= pipeline_pstrb;
        end
        ACCESS: begin
          if (pready) begin
            psel <= 1'd0;
            penable <= 1'd0;
            pwrite <= 1'd0;
          end
          else begin
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
      dout <= DATA_WIDTH'(1'd0);
    else
      if (~(|pipeline_pwrite))
        if (penable & pready)
          dout <= prdata;

  always_ff @(posedge pclk or negedge presetn)
    if (~presetn) begin
      busy <= 1'd0;
      err <= 1'd0;
    end else
      case (state)
        IDLE: begin
          err <= 1'd0;
          if (en)
            busy <= 1'd1;
        end
        ACCESS:
          if (pready) begin
            busy <= 1'd0;
            err <= pslverr;
          end
        default: begin
          busy <= busy;
          err <= err;
        end
      endcase

  always_ff @(posedge pclk or negedge presetn)
    if (~presetn)
      state <= IDLE;
    else
      case (state)
        IDLE:
          if (en)
            state <= SETUP;
        SETUP:
          state <= ACCESS;
        ACCESS:
          if (pready & en)
            state <= SETUP;
          else if (pready)
            state <= IDLE;
        default:
          state <= state;
      endcase

endmodule
