// apb_harness.sv

// ANSWER: definition of an interface that will
// contain all the signals your testbench manipulates.
// You will then put an instance of this interface into
// the test harness, and reference it through a virtual
// interface variable in the testbench.
//
interface APB_test_intf (input bit PCLK);
                       // ANSWER: Probably best to port in the clock

  // ANSWER: APB synchronous signals defined here
  //
  logic [15:0] PADDR, PWDATA, PRDATA;
  logic PSEL, PENABLE, PWRITE;

  // ANSWER: Clocking block to give access to all signals
  //
  clocking cb @(posedge PCLK);
    input  #1step PRDATA;
    output #1 PADDR, PWDATA, PSEL, PENABLE, PWRITE;
  endclocking : cb

  // ANSWER: task to give testbench access to ##N behaviour
  //
  task cycles(int N);
    repeat (N) @(cb);
  endtask : cycles

  // ANSWER: modport to provide controlled access from testbench
  //
  modport test_mp ( clocking cb, import cycles );

endinterface : APB_test_intf

///////////////////////////////////////////////////////////

// ANSWER: definition of test harness module containing
// instance of DUT, clock generator, instance of test access
// interface, and any other required infrastructure
//
module APB_harness();

  // clock generator
  bit PCLK;
  always #5 PCLK = ~PCLK;

  // test access interface
  APB_test_intf TB_intf(PCLK);

  // DUT (simple behavioural model)
  APB_dummy DUT(
    .PCLK   (PCLK),
    .PENABLE(TB_intf.PENABLE),   // ANSWER:
    .PSEL   (TB_intf.PSEL   ),   //   Connect DUT ports to
    .PWRITE (TB_intf.PWRITE ),   //   appropriate signals in the
    .PADDR  (TB_intf.PADDR  ),   //   test access interface
    .PWDATA (TB_intf.PWDATA ),
    .PRDATA (TB_intf.PRDATA )
  );

endmodule : APB_harness
