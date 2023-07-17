class WriteTransaction;
  int address;
  bit command;
  int data;
  bit [3:0] byte_enable;

  function new (int addr, bit cmd, int d, bit [3:0] be);
    this.address = addr;
    this.command = cmd;
    this.data = d;
    this.byte_enable = be;
  endfunction

  function int get_address ();
    return this.address;
  endfunction

  function bit get_command ();
    return this.command;
  endfunction

  function int get_data ();
    return this.data;
  endfunction

endclass

class ReadTransaction;
  int address;
  bit command;
  int data;

  function new (int addr, bit cmd, int d);
    this.address = addr;
    this.command = cmd;
    this.data = d;
  endfunction

  function int get_address ();
    return this.address;
  endfunction

  function bit get_command ();
    return this.command;
  endfunction

  function int get_data ();
    return this.data;
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

  int w_trans_num = 0;
  int r_trans_num = 0;
  WriteTransaction winfo[$];
  ReadTransaction rinfo[$];

  bit trans_done;
  initial begin
    trans_done = 0;
    forever begin
      @(psel or penable or pready);
      wait(psel && penable && !pready);
        trans_done = 0;
      wait(psel && penable && pready);
      wait(!psel && !penable && !pready);
        trans_done = 1;
    end
  end

  prop_transfer_done_is_pulse: assert property (
    @(posedge pclk) disable iff (!presetn)
    psel && penable && pready |=> !psel && !penable && !pwrite
  ) else $fatal(1, "prop_transfer_done_is_pulse : NG");

  WriteTransaction w_trans;
  bit cmd;

  initial
    forever begin
      @(en or we or busy);
      if (en && (!busy) && (|we)) begin
        cmd = (|we);
        w_trans = new (addr, cmd, din, we);
        winfo.push_back(w_trans);
        w_trans_num++;
      end
    end

  ReadTransaction r_trans;

  initial
    forever begin
      @(en or we or busy or psel or penable or pready);
      wait (en & ~(|we));
      cmd = (|we);
      wait (!busy);
      //@(psel or penable or pready)
      wait (psel);
      wait (penable);
      wait (pready);
      r_trans = new (addr, cmd, prdata);
      rinfo.push_back(r_trans);
      r_trans_num++;
    end

  int symb_paddr;
  bit symb_command;
  int symb_pwdata;
  int symb_dout;

  bit w_seen;
  assign w_seen = penable & psel & pwrite;
  bit r_seen;
  assign r_seen = penable & psel & ~pwrite;

  WriteTransaction w_tmp;

  initial
    forever begin
      @(w_seen);
      if (w_seen) begin
        w_tmp = winfo.pop_front();
        symb_paddr = w_tmp.get_address();
        symb_command = w_tmp.get_command();
        symb_pwdata = w_tmp.get_data();
        w_trans_num--;
      end
    end

  ReadTransaction r_tmp;

  initial
    forever begin
      @(r_seen or pready);
      wait (r_seen);
      wait (pready);
      r_tmp = rinfo.pop_front();
      symb_paddr = r_tmp.get_address();
      symb_command = r_tmp.get_command();
      symb_dout = r_tmp.get_data();
      r_trans_num--;
    end

  prop_write_trans: assert property (
    @(posedge pclk) disable iff (!presetn)
    $rose(trans_done) && pwrite |=> (symb_paddr === paddr) && (symb_pwdata === pwdata)
  ) else $fatal(1, "prop_write_trans : NG");

  prop_read_trans: assert property (
    @(posedge pclk) disable iff (!presetn)
    $rose(trans_done) && !symb_command |-> (symb_paddr === paddr) && (symb_dout === dout)
  ) else $fatal(1, "prop_read_trans : NG");

endmodule
