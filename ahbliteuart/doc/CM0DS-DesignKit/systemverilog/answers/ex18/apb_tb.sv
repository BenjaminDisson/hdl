// apb_tb.sv

// Top-level module definition for a testbench
// around a simple APB bus model

module APB_TB;

  import APB_pkg::*;

  initial 
  begin
    
    // Handle to the class-based environment
    APB_env tb;
    
    // IF YOU HAVE TIME:
    // Handle to a template object for stimulus generation
    //
    Mem_map_APB_Trans test_tr;
   
    // ANSWER: Create the environment object, hooking it 
    // to the test harness through interface "APB_harness.TB_intf".
    // Remember that this is to be a top-level component, and
    // therefore it has no parent component.
    //
    tb = new("tb", null, APB_harness.TB_intf);

    // IF YOU HAVE TIME:
    // Create and install a new template object
    //
    test_tr = new(tb.apb_comp.stim_gen);
    tb.set_stim_template( test_tr );
    
    // IF YOU HAVE TIME:
    // Reconfigure the stimulus generator's run length
    //
    tb.set_num_trans(100);

    // Let everything run.
    //
    tb.run();
    $display("returned from top level run()");
    
    $finish();
    
  end

endmodule : APB_TB
