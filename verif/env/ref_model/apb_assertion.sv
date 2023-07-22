class TransactionQueue;
  localparam DATA_WIDTH = 32;

  int len;

  int addr_queue[$];
  bit [DATA_WIDTH/8-1:0] we_queue[$];
  int data_queue[$];

  function new ();
    this.len = 0;
  endfunction

  function int get_len ();
    return this.len;
  endfunction

  function void push_back(int addr, int data);
    this.addr_queue.push_back(addr);
    this.data_queue.push_back(data);
    this.len++;
  endfunction

  function void pop_front(output int addr, output int data);
    addr = this.addr_queue.pop_front();
    data = this.data_queue.pop_front();
    this.len--;
  endfunction

endclass

module apb_assertions #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
) (
  input                     pclk,
  input                     presetn,
  // Requester
  input [ADDR_WIDTH-1:0]    paddr,
  input [2:0]               pprot,
  input                     pnse,
  input                     psel,
  input                     penable,
  input                     pwrite,
  input [DATA_WIDTH-1:0]    pwdata,
  input [DATA_WIDTH/8-1:0]  pstrb,
  // Completer
  input                     pready,
  input [DATA_WIDTH-1:0]    prdata,
  input                     pslverr,
  // Local Inerface
  input                     en,
  input [DATA_WIDTH/8-1:0]  we,
  input [ADDR_WIDTH-1:0]    addr,
  input [DATA_WIDTH-1:0]    din ,
  input                     busy,
  input [DATA_WIDTH-1:0]    dout,
  input                     err 
);

  TransactionQueue winfo;
  TransactionQueue rinfo;
  int exp_addr;
  int exp_data;

  initial begin
    winfo = new;
    rinfo = new;
  end

  bit winfo_seen, rinfo_seen;
  assign winfo_seen = penable & psel & pwrite;
  assign rinfo_seen = penable & psel & ~pwrite;

  bit winfo_done, rinfo_done;
  initial begin
    winfo_done = 0;
    rinfo_done = 0;
    forever begin
      @(posedge winfo_seen or posedge rinfo_seen);
        winfo_done = 0;
        rinfo_done = 0;
      if (winfo_seen) begin
        @(negedge pready);
        winfo_done = 1;
      end else if (rinfo_seen) begin
        @(negedge pready);
        rinfo_done = 1;
      end
    end
  end

  initial
    forever begin
      @(winfo_done);
      wait(winfo_done);
        winfo.pop_front(exp_addr, exp_data);
    end

  initial
    forever begin
      @(rinfo_done);
      wait (rinfo_done);
      rinfo.pop_front(exp_addr, exp_data);
    end

  initial
    forever begin
      @(en or busy);
      wait (en && (!busy));
      if (|we)
        winfo.push_back(addr, din);
      else begin
        @(posedge pready)
        rinfo.push_back(addr, prdata);
      end
    end

  prop_transfer_done_is_pulse: assert property (
    @(posedge pclk) disable iff (!presetn)
    psel && penable && pready |=> !psel && !penable && !pwrite
  ) else $fatal(1, "prop_transfer_done_is_pulse : NG : psel=%b, penable=%b, pwrite=%b", psel, penable, pwrite);

  prop_write_trans: assert property (
    @(posedge pclk) disable iff (!presetn)
    winfo_done && $fell(pwrite) |-> (exp_addr === paddr) && (exp_data === pwdata)
  ) else begin
    if (exp_addr !== paddr)
      $fatal(1, "prop_write_trans : NG : addr=%x, exp=%x", paddr, exp_addr);
    else
      $fatal(1, "prop_write_trans : NG : data=%x, exp=%x", pwdata, exp_data);
  end

  prop_read_trans: assert property (
    @(posedge pclk) disable iff (!presetn)
    rinfo_done && $fell(busy) |-> (exp_addr === paddr) && (exp_data === dout)
  ) else begin
    if (exp_addr !== paddr)
      $fatal(1, "prop_read_trans : NG : addr=%x, exp=%x", paddr, exp_addr);
    else
      $fatal(1, "prop_read_trans : NG : data=%x, exp=%x", dout, exp_data);
  end

endmodule
