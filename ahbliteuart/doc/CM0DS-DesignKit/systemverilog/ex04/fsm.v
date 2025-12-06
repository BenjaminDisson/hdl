// fsm.v

`timescale 1ns/1ns

module fsm (
    input Crystal, nSysReset,
    input [1:2] Buttons,
    output reg WatchRunning, WatchReset
  );

  parameter
    Zero          = 0,
    Start         = 1,
    Running       = 2,
    Stop          = 3,
    Stopped       = 4,
    Reset         = 5;

  reg [2:0] State, NextState;

  always @(posedge Crystal or negedge nSysReset)
    if (!nSysReset)
      State <= Zero;
    else
      State <= NextState;

  always @(State or Buttons)
  begin

    NextState = State;

    WatchRunning = 0;
    WatchReset = 0;

    case (State)
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
      default:
                             NextState = 3'bx;
    endcase
  end

endmodule
