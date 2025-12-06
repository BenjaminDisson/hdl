// fsm.sv

// ANSWER:

module fsm (
    input  logic Crystal, nSysReset,
    input  logic [1:2] Buttons,
    output logic WatchRunning, WatchReset
  );

  timeunit 1ns;
  timeprecision 1ns;

  // Explicit one-hot encoding; type 'bit' ensures no X values
  // Encoding chosen to include the default value of 6'b0
  enum bit [5:0] {
    Zero          = 6'b000000,
    Start         = 6'b000011,
    Running       = 6'b000101,
    Stop          = 6'b001001,
    Stopped       = 6'b010001,
    Reset         = 6'b100001
  } State, NextState;


  // Use always_ff for clocked logic
  always_ff @(posedge Crystal or negedge nSysReset)
    if (!nSysReset)
      State <= Zero;
    else
      State <= NextState;

  // Use always_comb for combinational logic
  always_comb
  begin

    NextState = State;

    WatchRunning = 0;
    WatchReset = 0;

    // 'unique' case checks for completeness and instructs synthesis
    // to create parallel logic
    unique case (State)
      Zero:
        if (Buttons[1])      NextState = Start;
      Start:
        begin
          WatchRunning = 1;
          if (!Buttons)      NextState = Running;
        end
      Running:
        begin
          WatchRunning = 1;
          if (Buttons[1])    NextState = Stop;
        end
      Stop:
        if (!Buttons)        NextState = Stopped;
      Stopped:
        if (Buttons[1])      NextState = Start;
        else if (Buttons[2]) NextState = Reset;
      Reset:
        begin
          WatchReset = 1;
          if (!Buttons)      NextState = Zero;
        end
    endcase
  end

endmodule
