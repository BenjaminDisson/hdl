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

    //  TO DO: Create the environment object, hooking it
    // to the test harness through interface "APB_harness.TB_intf".
    // Remember that this is to be a top-level component, and
    // therefore it has no parent component.
    //
    tb = new ("Mon composant",null,APB_harness.TB_intf);
    // IF YOU HAVE TIME:
    // Create and install a new template object
    //

    // IF YOU HAVE TIME:
    // Reconfigure the stimulus generator's run length
    //

    // Let everything run.
    //
    tb.run();
    $display("returned from top level run()");

    $finish();

  end

endmodule : APB_TB
