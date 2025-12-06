// apb_tb.sv

// YOU DO NOT NEED TO MODIFY THIS FILE


module test_APB;

  // Environment class definition is built using components
  // from apb_classes, which we include here.

  import APB_pkg::*;

  initial
  begin
    // Create the environment object, hook it to the test harness...
    APB_Env tb;
    tb = new(APB_harness.TB_intf.test_mp);
  
    // and let it run.
    tb.run();
    $finish();
  end

endmodule : test_APB
