// minicpu_tb.sv

// YOU DO NOT NEED TO MODIFY THIS FILE

// ----------------------------------------------------------------------------
// This test bench is instantiated by the test case -
//   e.g.  minicpu_test_fibonacci.sv
// You should NOT simulate this test bench as the top level module
// ----------------------------------------------------------------------------
//
// Instantiates CPU connected to memory.
// The CPU model should execute instructions from the memory,
// so this testbench doesn't need to do very much:
// * instantiation of memory and CPU models
// * interconnect between memory and CPU
// * initialisation of memory to contain a suitable program
// * clock and reset generator
// * auto stop of clock generator when CPU goes into halt state
//
// As a convenience, we also do some parameter overrides on
// the CPU model so that its states are more easily understood.


module miniCPU_tb;

  import miniCPU_types::*;

  // File containing instructions for this test, in readmemb format
  parameter init_file = "doesnt_exist";

  parameter PCLK_period = 10;

  // Reset signal to initialise CPU
  logic reset;

  // APB interconnect - note that the clock is generated locally here
  logic   PCLK;
  T_word  PADDR;
  T_word  PWDATA, PRDATA;
  logic   PWRITE, PENABLE, PSEL;

  // Diagnostic/status outputs from CPU
  logic halted, fetch, branch;

  // Flag used to control the clock generator
  logic running;


  // _______________________________________________________ CPU INSTANCE ___
  //
/*
  miniCPU #(
    // Patch-up the CPU's controller state values to be readable strings instead of numbers:
    .state_width(32),
    .init  ("init"),
    .initZ ("iniZ"),
    .fetch0("fet0"),
    .fetch1("fet1"),
    .decode("decd"),
    .load0 ("lod0"),
    .load1 ("lod1"),
    .store0("str0"),
    .store1("str1"),
    .exec  ("exec"),
    .halt  ("halt")
  ) theCPU ( .* );
  */

  miniCPU theCPU ( .* );

  // ____________________________________________________ MEMORY INSTANCE ___
  //
  APB_mem # (.Depth(1000)) memory ( .* );

  // Preload the memory with a program taken from a "readmemb" file
  //
  initial
    $readmemb(init_file, memory.mem);


  // ____________________________________________________ CLOCK AND RESET ___
  //
  initial
  begin : reset_gen
    reset = 1;
    running = 1;
    reset <= repeat (4) @(negedge PCLK) 0;
    wait (halted);
    running <= repeat (4) @(negedge PCLK) 0;
  end : reset_gen

  always
  begin : clk_gen
    wait (running)
    while (running)
    begin
      PCLK = 0;
      PCLK <= #(PCLK_period/2) 1;
      #PCLK_period;
    end
  end : clk_gen


  // _________________________________________________ MEMORY READ ACCESS ___
  //
  function T_word readMem (input T_word adrs);
    return memory.mem[adrs];
  endfunction : readMem


  // ________________________________________________ MEMORY WRITE ACCESS ___
  //
  task writeMem (input T_word adrs, data);
    memory.mem[adrs] = data;
  endtask : writeMem


endmodule
