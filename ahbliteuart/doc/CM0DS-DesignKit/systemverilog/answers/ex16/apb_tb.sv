// apb_tb.sv

// ANSWER

// Top-level module definition for a testbench
// around a simple APB bus model

module APB_TB;

  import APB_pkg::*;

  initial
  begin

    // Environment object
    APB_Env tb;

    // Stimulus generator's template object.
    Mem_map_APB_Trans test_tr;

    // Create the environment object, hook it to the test harness...
    tb = new(APB_harness.TB_intf.test_mp);

    // Create new template object.
    test_tr = new(tb.gen);

    // Install our template object in the stimulus generator
    tb.gen.template = test_tr;

    // and let it run.
    tb.run(100);

    $finish();

  end

endmodule : APB_TB
