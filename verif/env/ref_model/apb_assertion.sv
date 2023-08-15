`ifndef APB_ASSERTION_SV_
`define APB_ASSERTION_SV_

class TransactionQueue;
  localparam DATA_WIDTH = 32;

  string _name;
  int len;
  int _addr;
  int _data;

  int addr_queue[$];
  bit [DATA_WIDTH/8-1:0] we_queue[$];
  int data_queue[$];

  function new (string name);
    this._name = name;
    this.len = 0;
    this._addr = 0;
    this._data = 0;
  endfunction

  function int get_len ();
    return this.len;
  endfunction

  function void set_addr(int addr);
    this._addr = addr;
  endfunction

  function void set_data(int data);
    this._data = data;
  endfunction

  function void set_data_and_push(int data);
    this._data = data;
    this.push(this._addr, this._data);
  endfunction

  function void push(int addr, int data);
    this.addr_queue.push_back(addr);
    this.data_queue.push_back(data);
    this.len++;
    $info("%s.push: addr=%x, data=%x (len=%d)", this._name, this.len, addr, data);
  endfunction

  function void pop(output int addr, output int data);
    if (this.len === 0)
      $fatal(1, "%s.pop: FIFO IS EMPTY", this._name);
    addr = this.addr_queue.pop_front();
    data = this.data_queue.pop_front();
    this.len--;
    $info("%s.pop: addr=%x, data=%x (len=%d)", this._name, this.len, addr, data);
  endfunction

endclass

module apb_assertion #(
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
  typedef enum int {
    IDLE = 0,
    TRANSFER = 1,
    ACCESS = 2,
    DONE = 3
  } state;

  TransactionQueue winfo;
  TransactionQueue rinfo;
  TransactionQueue wout_fifo;
  TransactionQueue rout_fifo;
  int exp_addr;
  int exp_data;
  int act_addr;
  int act_data;

  initial begin
    winfo = new("winfo");
    rinfo = new("rinfo");
    wout_fifo = new("wout_fifo");
    rout_fifo = new("rout_fifo");
  end

  state winfo_state = IDLE;
  always @(posedge pclk) begin
    case (winfo_state)
      IDLE:
        if (en && !busy && (|we)) begin
          winfo_state = TRANSFER;
          winfo.push(addr, din);
        end
      TRANSFER:
        if (penable && psel && pwrite)
          winfo_state = ACCESS;
      ACCESS:
        if (pready && penable && psel && pwrite) begin
          winfo_state = DONE;
          wout_fifo.push(paddr, pwdata);
        end
      DONE:
        if (!busy) begin
          if (en && (|we))
            winfo_state = TRANSFER;
          else
            winfo_state = IDLE;

          winfo.pop(exp_addr, exp_data);
          wout_fifo.pop(act_addr, act_data);
        end
    endcase
  end

  state rinfo_state = IDLE;
  always @(posedge pclk) begin
    case (rinfo_state)
      IDLE:
        if (en && !busy && !(|we)) begin
          rinfo_state = TRANSFER;
          rinfo.set_addr(addr);
        end
      TRANSFER:
        if (penable && psel && !pwrite)
          rinfo_state = ACCESS;
      ACCESS:
        if (pready && penable && psel && !pwrite) begin
          rinfo_state = DONE;
          rinfo.set_data_and_push(prdata);
          rout_fifo.set_addr(paddr);
        end
      DONE:
        if (!busy) begin
          if (en && !(|we))
            rinfo_state = TRANSFER;
          else
            rinfo_state = IDLE;

          rout_fifo.set_data_and_push(dout);

          rinfo.pop(exp_addr, exp_data);
          rout_fifo.pop(act_addr, act_data);
        end
    endcase
  end

  prop_paddr_stable: assert property (
    @(posedge pclk) disable iff (!presetn)
      penable |-> $stable(paddr)
  ) else $fatal(1, "prop_paddr_stable : NG : paddr is not stable");

  prop_pwrite_stable: assert property (
    @(posedge pclk) disable iff (!presetn)
      penable |-> $stable(pwrite)
  ) else $fatal(1, "prop_pwrite_stable : NG : pwrite is not stable");

  prop_pwdata_stable: assert property (
    @(posedge pclk) disable iff (!presetn)
      penable |-> $stable(pwdata)
  ) else $fatal(1, "prop_pwdata_stable : NG : pwdata is not stable");

  prop_pstrb_stable: assert property (
    @(posedge pclk) disable iff (!presetn)
      penable |-> $stable(pstrb)
  ) else $fatal(1, "prop_pstrb_stable : NG : pstrb is not stable");

  prop_transfer_done_is_pulse: assert property (
    @(posedge pclk) disable iff (!presetn)
    psel && penable && pready |=> !psel && !penable && !pwrite
  ) else $fatal(1, "prop_transfer_done_is_pulse : NG : psel=%b, penable=%b, pwrite=%b", psel, penable, pwrite);

  prop_write_trans: assert property (
    @(posedge pclk) disable iff (!presetn)
    $past(winfo_state === DONE) && $changed(winfo_state) |-> (exp_addr === act_addr) && (exp_data === act_data)
  ) else begin
    if (exp_addr !== act_addr)
      $fatal(1, "prop_write_trans : NG : act_addr=%x, exp=%x", act_addr, exp_addr);
    else
      $fatal(1, "prop_write_trans : NG : act_data=%x, exp=%x", act_data, exp_data);
  end

  prop_read_trans: assert property (
    @(posedge pclk) disable iff (!presetn)
    $past(rinfo_state === DONE) && $changed(rinfo_state) |-> (exp_addr === act_addr) && (exp_data === act_data)
  ) else begin
    if (exp_addr !== act_addr)
      $fatal(1, "prop_read_trans : NG : act_addr=%x, exp=%x", act_addr, exp_addr);
    else
      $fatal(1, "prop_read_trans : NG : act_data=%x, exp=%x", act_data, exp_data);
  end

endmodule

`endif  // APB_ASSERTION_SV_