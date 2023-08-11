`ifndef APB_SCOREBOARD_SVH_
`define APB_SCOREBOARD_SVH_

class apb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_scoreboard)

  uvm_analysis_export #(apb_transaction) in_export;
  uvm_analysis_export #(apb_transaction) out_export;
  uvm_tlm_analysis_fifo #(apb_transaction) in_fifo;
  uvm_tlm_analysis_fifo #(apb_transaction) out_fifo;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    in_export = new("in_export", this);
    out_export = new("out_export", this);
    in_fifo = new("in_fifo", this);
    out_fifo = new("out_fifo", this);
    //if (!uvm_config_db #(bit[3:0])::get(this, "*", "ref_pattern", ref_pattern))
    //  `uvm_fatal("SCBD", "Did not get ref_pattern !")
  endfunction

  function void connect_phase (uvm_phase phase);
    in_export.connect(in_fifo.analysis_export);
    out_export.connect(out_fifo.analysis_export);
  endfunction

  // function write(apb_transaction req);
  //   `uvm_info(get_full_name(), $sformatf("in="), UVM_LOW)
    // act_pattern = act_pattern << 1 | item.in;

    // `uvm_info("SCBD", $sformatf("in=%0d out=%0d ref=0b%0b act=0b%0b", item.in, item.out, ref_pattern, act_pattern), UVM_LOW)

    // if (item.out != exp_out) begin
    //   `uvm_error("SCBD", $sformatf("ERROR ! out=%0d exp=%0d", item.out, exp_out))
    // end else begin
    //   `uvm_info("SCBD", $sformatf("PASS ! out=%0d exp=%0d", item.out, exp_out), UVM_HIGH)
    // end

    // if (!(ref_pattern ^ act_pattern)) begin
    //   `uvm_info("SCBD", $sformatf("Pattern found to match, next out should be 1"), UVM_LOW)
    //   exp_out = 1;
    // end else begin
    //   exp_out = 0;
    // end
  // endfunction

  task run_phase(uvm_phase phase);
    apb_transaction exp_trans;
    apb_transaction act_trans;
    forever begin
      in_fifo.get(exp_trans);
      out_fifo.get(act_trans);
      if (!exp_trans.compare(act_trans)) begin
        `uvm_error(get_full_name(), $sformatf("%s does not match\n%s", exp_trans.sprint(), act_trans.sprint()))
      end
    end
  endtask

endclass

`endif  // APB_SCOREBOARD_SVH_