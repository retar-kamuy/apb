class WriteInfo;
  int addr;
  int data;

  function new (int a, int d);
    this.addr = a;
    this.data = d;
  endfunction

  function int get_addr ();
    return this.addr;
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

  // prop_a_cnt: assert property (
  //   @(posedge pclk) disable iff (~presetn)
  //   psel & penable & pready |=> ~psel & ~penable & ~pready
  // ) else $fatal(1, "prop_a_cnt : NG");

  property valid_state;
    @(posedge pclk) disable iff (~presetn)
    psel & penable & pready |=> ~psel & ~penable & ~pready;
  endproperty

  int winfo_num = 0;
  WriteInfo winfo[$];

  initial
    forever begin
      @(en or we or busy);
      if(en & (|we) & (~busy)) begin
        WriteInfo w = new (addr, din);
        winfo.push_back(w);
        winfo_num++;
      end
    end

  int symb_addr;
  int symb_data;

  initial
    forever begin
      @(penable or psel or pwrite);
      if (penable & psel & pwrite) begin
        WriteInfo w = winfo.pop_front();
        symb_addr = w.get_addr();
        symb_data = w.get_data();
        winfo_num--;
      end
    end

  property write_info;
    @(posedge pclk) disable iff (~presetn)
    psel && $rose(penable) && pwrite |=> (symb_addr == paddr) && (symb_data == pwdata);
  endproperty

  prop_valid_state: assert property (valid_state) else $fatal(1, "prop_valid_state : NG");
  prop_write_info: assert property (write_info) else $fatal(1, "prop_write_info : NG");

endmodule
