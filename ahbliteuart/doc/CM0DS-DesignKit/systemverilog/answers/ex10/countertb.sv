// countertb.sv

// ANSWER

module CounterTB;

  timeunit      1ns;
  timeprecision 1ps;

  logic       Clock;
  logic       Reset;
  logic       Enable;
  logic       Load;
  logic       UpDn;
  logic [7:0] Data;
  logic [7:0] Q;

  bit count_dir = 1;
  bit count_en  = 0;

  // DUT instance
  //
  Counter G1 ( .* );

  // Note that the test (CounterTester) is not instanced here
  // it is co-compiled and simulated . This means that we can
  // create many tests without having to recompile the testbench or
  // DUT each time

  // Clock generator
  //
  always
  begin
    #5 Clock = 1;
    #5 Clock = 0;
  end

  // Clocking block.
  // The control signals are "inout" clockvars here so that the tester 
  // can both sample and drive them
  //
  clocking cb @(posedge Clock);
    default input #2 output #3;
    input Q;
    inout Reset, Enable, Load, UpDn, Data;
  endclocking

  // Task to wait for N clocks 
  // NOTE the use of "automatic" here to allow more than one
  //      instance of the task to be run concurrently
  //
  task automatic cycles(int unsigned N);
    repeat (N)
    begin
      @(cb);
    end
  endtask

  //__________________________________________________________TESTER_METHODS__
  // ANSWER:  Add tasks to perform individual operations on the counter
  //       
  task initialise();
    $display("Initialising the counter");
  
    cycles(1);  // Line up with the first clock edge
    cb.Enable <= 0;
    cb.Load   <= 0;
    cb.UpDn   <= count_dir;
    do_reset();
  endtask : initialise

  task do_reset(int unsigned n = 1);
    $display("Reseting the counter");

    cb.Reset <= 1;
    cycles(n); // Should be reset
    cb.Reset <= 0;
  endtask

  task set_count_dir(bit d);
    $display("Setting the count direction to %s",
              d ? "up" : "down");

    cb.UpDn   <= d;
    count_dir  = d;
  endtask : set_count_dir

  task toggle_count_dir();
    count_dir = ~count_dir;

    $display("Toggling the count direction");

    set_count_dir(count_dir);
  endtask : toggle_count_dir

  function bit get_count_dir();
    return count_dir;
  endfunction : get_count_dir

  function bit get_count();
    return cb.Q;
  endfunction : get_count

  task count_enable(bit e);
    $display("Setting the counter to %s",
              e ? "enabled" : "disabled");
    
    cb.Enable <= e;
    count_en   = e;
  endtask : count_enable

  task toggle_count_enable();
    $display("Toggling the counter enable");

    count_en = ~count_en;
    count_enable(count_en);
  endtask : toggle_count_enable

  task load(logic [7:0] d);
    $display("Loading a new counter value: 'h%h", d);
  
    cb.Load <= 1;
    cb.Data <= d;
    cycles(1);
    cb.Load <= 0;
    cb.Data <= 'x;
  endtask : load
  
  //_________________________________________________________________________
  // ANSWER: Add a task to load a random value in the range 64 to 127
  //
  task gen_random_load_value();
    logic [7:0] value;
    bit ok;
    ok = std::randomize(value) with { value >= 64; value < 128; };
    assert (ok);
    load(value);
  endtask
  //_________________________________________________________________________

endmodule
