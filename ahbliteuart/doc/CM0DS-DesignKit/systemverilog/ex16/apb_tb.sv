// apb_tb.sv

// Top-level module definition for a testbench
// around a simple APB bus model

module APB_TB;

  import APB_pkg::*;

  // TO DO:
  // Add code to this 'initial' block that will...
  // - create a new object of Mem_map_APB_Trans class
  // - install that new object as the stimulus generator's
  //   template object
  // - run the test for 100 transactions using this new template

  initial
  begin

    // Environment object
    APB_Env tb;
    Mem_map_APB_Trans mmt;
    // Create the environment object, hook it to the test harness...
    tb = new(APB_harness.TB_intf.test_mp);
    mmt = new(tb.gen);
    tb.gen.template = mmt;

    // and let it run.
    tb.run(100);

    $finish();

  end

endmodule : APB_TB
