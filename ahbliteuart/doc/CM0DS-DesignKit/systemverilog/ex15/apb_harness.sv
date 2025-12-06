// apb_harness.sv

// YOU NEED TO COMPLETE THIS FILE -
// see comments containing "TO DO:"

// This file contains definitions of the test access interface
// and test harness that a class-based testbench will use to
// manipulate the DUT.

// TO DO: definition of an interface that will
// contain all the signals your testbench manipulates.
// You will then put an instance of this interface into
// the test harness, and reference it through a virtual
// interface variable in the testbench.
//
package pkg_interface;
  typedef
  logic [15:0] t_APB_vector;
endpackage



interface APB_test_intf (input PCLK);

  import pkg_interface::*;
  t_APB_vector PADDR, PWDATA, PRDATA;
  logic PSEL, PENABLE, PWRITE;

  // TO DO: clocking block to give access to all signals
  //
  clocking cb @(posedge PCLK);
    //default input #2 output #3;
    output PSEL, PENABLE, PWRITE,PADDR, PWDATA;
    input PRDATA;
  endclocking : cb

  // TO DO: task to give testbench access to ##N behaviour
  //
  task automatic cycles(int N);
    repeat (N)
    begin
      @(cb);
    end
  endtask : cycles

  // TO DO: modport to provide controlled access from testbench
  //
  modport test_mp (clocking cb, import cycles);

endinterface : APB_test_intf

///////////////////////////////////////////////////////////

// TO DO: definition of test harness module containing
// instance of DUT, clock generator, instance of test access
// interface, and any other required infrastructure
//
module APB_harness();

  // clock generator
  bit PCLK;
  always #5 PCLK = ~PCLK;

  // TO DO: instance of test access interface
  APB_test_intf TB_intf(.PCLK);

  // Instance of DUT (simple behavioural model)
  APB_dummy DUT(
    .PCLK   (PCLK),
    .PENABLE(TB_intf.PENABLE),
    .PSEL   (TB_intf.PSEL),   //   TO DO: Connect DUT ports to
    .PWRITE (TB_intf.PWRITE),   //   appropriate signals
    .PADDR  (TB_intf.PADDR),
    .PWDATA (TB_intf.PWDATA),
    .PRDATA (TB_intf.PRDATA)
  );

endmodule : APB_harness
