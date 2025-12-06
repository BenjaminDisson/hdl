// apb_harness.sv

// YOU DO NOT NEED TO MODIFY THIS FILE


// Interface with all the signals your testbench manipulates.
// You will then put an instance of this interface into
// the test harness, and reference it through a virtual
// interface variable in the testbench.
//
interface APB_test_intf (input bit PCLK);

  // APB synchronous signals defined here
  //
  logic [15:0] PADDR, PWDATA, PRDATA;
  logic PSEL, PENABLE, PWRITE;

  // Clocking block to give access to all signals
  //
  clocking cb @(posedge PCLK);
    input #1step PRDATA;
    output #1 PADDR, PWDATA, PSEL, PENABLE, PWRITE;
  endclocking : cb

  // Add a clocking block for the monitor 
  // (all clockvars are input)
  clocking mon_cb @(posedge PCLK);
    input #1step PADDR, PWDATA, PSEL, PENABLE, PWRITE, PRDATA;
  endclocking : mon_cb

  // task to give testbench access to ##N behaviour
  //
  task automatic cycles(int N);
    repeat (N) @(cb);
  endtask : cycles

  // modport to provide controlled access from testbench
  //
  modport test_mp ( clocking cb, import cycles );
  
  // Add a modport to give access to the monitor clocking block
  // The modport should be named "mon_mp" (to match the typedef in apb_classes.sv)
  modport mon_mp ( clocking mon_cb, import cycles );

endinterface : APB_test_intf

///////////////////////////////////////////////////////////

// Test harness module containing
// instance of DUT, clock generator, instance of test access
// interface, and any other required infrastructure
//
module APB_harness();

  // clock generator
  //
  bit PCLK;
  always #5 PCLK = ~PCLK;

  // test access interface
  //
  APB_test_intf TB_intf(PCLK);

  // DUT (simple behavioural model)
  //
  APB_dummy DUT(
    .PCLK   (PCLK),
    .PENABLE(TB_intf.PENABLE),
    .PSEL   (TB_intf.PSEL   ),   //   Connect DUT ports to
    .PWRITE (TB_intf.PWRITE ),   //   appropriate signals in the
    .PADDR  (TB_intf.PADDR  ),   //   test access interface
    .PWDATA (TB_intf.PWDATA ),
    .PRDATA (TB_intf.PRDATA )
  );

endmodule : APB_harness
