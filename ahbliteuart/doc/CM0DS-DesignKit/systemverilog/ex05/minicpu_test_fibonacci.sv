// minicpu_test_fibonacci.sv

// YOU DO NOT NEED TO MODIFY THIS FILE


// Test case for miniCPU using Fibonacci sequence program

module miniCPU_test_fibonacci;

  // Maximum number of clock cycles we are prepared to wait for
  // the program to complete
  parameter TimeoutCycles = 1000;

  // _________________________________________________ TESTBENCH INSTANCE ___
  //
  miniCPU_tb #( .init_file("fibonacci.mca") ) testbench();  // No ports


  // ___________________________________________________ RESULTS CHECKING ___
  //
  // After the program has finished running, tweny terms of
  // the Fibonacci sequence 1,1,2,3,5,8... should be stored
  // in locations 32..51.
  //
  initial 
  begin : fibonacci_results_checker

    logic [15:0] fibo1, fibo2, adrs, result, term, errorCount;

    // Wait for the testbench to finish, and cancel the
    // timeout when it finishes:
    wait (testbench.halted) disable TestTimeout;

    // Initialise our reference Fibonacci sequence generator:
    fibo1 = 0;
    fibo2 = 1;

    // Initialise the memory address where we expect to find the
    // results calculated by our miniCPU program:
    adrs = 32;

    // Initialise our error counter:
    errorCount = 0;

    // Display a header line:
    $display();
    $display("-------+--------+---------");
    $display(" adrs  | result | expected");
    $display("-------+--------+---------");

    // Check the first 20 terms:
    repeat (20) 
    begin : repeat_20
      // Calculate the next term
      term = fibo2;
      fibo2 = fibo1 + fibo2;
      fibo1 = term;

      // Find what the program calculated, check it
      result = testbench.readMem(adrs);
      if (result !== term)
        errorCount = errorCount + 1;

      // Generate a display line
      $display(" %d |  %d |  %d", adrs, result, term);

      // Advance the address
      adrs = adrs + 1;

    end : repeat_20

    // End of table...
    $display("-------+--------+---------");
    if (errorCount)
      $display("%0d ERRORS FOUND", errorCount);
    else
      $display("Success: no errors found");
    $display("-------+--------+---------");
    $display();

  end : fibonacci_results_checker

  // ____________________________________________________________ TIMEOUT ___
  //
  // Abort the test if the program does not finish soon enough
  initial 
  begin : TestTimeout
    #(testbench.PCLK_period * TimeoutCycles)
    $display("################ FAILURE ##################");
    $display("#  Timeout waiting for program to finish  #");
    $display("###########################################");
    $stop;
    $finish;
  end : TestTimeout


endmodule : miniCPU_test_fibonacci
