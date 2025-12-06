// countertb.sv

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
  // The control inputs are "inout" clockvars so that the tester
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
  // TO DO: Add tasks to perform individual operations on the counter
  /*task tester(int action, int value);

      case (action)
      //reset
      1 :
      cb.Reset  <= 1;

      //load
      2:
      begin
      cb.Enable <= 1;
      cb.Load   <= 1;
      cb.Data   <= value;
      end
      //change
      3:
      cb.UpDn   <= ~cb.UpDn;

      //toogle
      4:
      cb.Enable <= ~cb.Enable;
      endcase

  endtask
*/



  task automatic rst;
  begin
    cycles(1);
    cb.Reset  <= 1;
    cycles(1);
    cb.Reset  <= 0;
    end
  endtask

  task automatic ld;
  begin
    cycles(1);
      cb.Enable <= 1;
      cb.Load   <= 1;
      cb.Data   <= 16'h15;
    cycles(1);
      cb.Enable <= 1;
      cb.Data   <= 16'h16;
      cb.Load   <= 0;
      end
  endtask

  task automatic change;
  begin
    cycles(1);
    cb.UpDn   <= ~cb.UpDn;
    end
  endtask

  task automatic toogle;
  begin
    cycles(1);
    cb.Enable <= ~cb.Enable;
    end
  endtask
  //_________________________________________________________________________
  // TO DO: Add a task to load a random value in the range 64 to 127
  //

endmodule
