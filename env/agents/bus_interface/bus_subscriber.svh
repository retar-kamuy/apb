class bus_subscriber extends uvm_subscriber #(bus_seq_item);
  `uvm_component_utils(bus_subscriber)

  int           command;
  bit   [63:0]  address;
  bit   [31:0]  data;

  covergroup cover_bus;
    coverpoint command {
      bins c[] = {0, 1};
    }
    coverpoint address { 
      bins a = {[0:4294967296-1]};
    }
    coverpoint data {
      bins d = {[0:4294967296-1]};
    }
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cover_bus = new();
  endfunction

    function void write(bus_seq_item t);
      `uvm_info(get_full_name(), $sformatf("SUBSCRIBER RECIEVED %s", t.convert2string()), UVM_NONE);

      command = t.command;
      address = t.address;
      data    = t.data;
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
