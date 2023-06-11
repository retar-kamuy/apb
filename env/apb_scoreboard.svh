class apb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(apb_scoreboard)

    function new(string name="apb_scoreboard", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    bit[3:0] ref_pattern;
    bit[3:0] act_pattern;
    bit exp_out;

    uvm_analysis_imp #(apb_seq_item, apb_scoreboard) analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        analysis_imp = new("analysis_imp", this);
        //if (!uvm_config_db #(bit[3:0])::get(this, "*", "ref_pattern", ref_pattern))
        //    `uvm_fatal("SCBD", "Did not get ref_pattern !")
    endfunction

    function write(apb_seq_item item);
        `uvm_info("SCBD", $sformatf("in="), UVM_LOW)
        // act_pattern = act_pattern << 1 | item.in;
    
        // `uvm_info("SCBD", $sformatf("in=%0d out=%0d ref=0b%0b act=0b%0b", item.in, item.out, ref_pattern, act_pattern), UVM_LOW)

        // if (item.out != exp_out) begin
        //     `uvm_error("SCBD", $sformatf("ERROR ! out=%0d exp=%0d", item.out, exp_out))
        // end else begin
        //     `uvm_info("SCBD", $sformatf("PASS ! out=%0d exp=%0d", item.out, exp_out), UVM_HIGH)
        // end

        // if (!(ref_pattern ^ act_pattern)) begin
        //     `uvm_info("SCBD", $sformatf("Pattern found to match, next out should be 1"), UVM_LOW)
        //     exp_out = 1;
        // end else begin
        //     exp_out = 0;
        // end
    endfunction
endclass