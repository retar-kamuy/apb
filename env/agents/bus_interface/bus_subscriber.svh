class bus_subscriber extends uvm_subscriber #(bus_seq_item);
  `uvm_component_utils(bus_subscriber)

  int           command;
  bit   [63:0]  address;
  bit   [31:0]  data;
  bit   [3:0]   byte_enable;

  covergroup cover_bus;
    coverpoint command {
      bins c[] = {0, 1};
    }
    coverpoint address { 
      bins a0 = {0};
      wildcard bins a1 = {1'b1, 31'h????_????};
    }
    coverpoint data {
      bins d0 = {0};
      wildcard bins d1 = {1'b1, 31'h????_????};
    }
    coverpoint byte_enable {
      bins b[] = {
        4'b0000,
        4'b0001,
        4'b0010,
        4'b0100,
        4'b1000,
        4'b1111
      };
    }
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cover_bus = new();
  endfunction

    function void write(bus_seq_item t);
      `uvm_info(get_full_name(), $sformatf("SUBSCRIBER RECIEVED %s", t.convert2string()), UVM_DEBUG);

      command     = t.command;
      address     = t.address;
      data        = t.data;
      byte_enable = t.byte_enable;
      cover_bus.sample();
      /*
      begin
        my_transaction expected;
        expected = new;
        expected.copy(t);
        if ( !t.compare(expected))
          `uvm_error("mg", "Transaction differs from expected");
      end
      */
    endfunction

  endclass
