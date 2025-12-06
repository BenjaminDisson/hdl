// fsm.v

//`timescale 1ns/1ns

module fsm (
    input logic Crystal, nSysReset,
    input logic [1:2] Buttons,
    output logic WatchRunning, WatchReset
  );
timeunit 1ns;
timeprecision 1ns;
 /* parameter
    Zero          = 0,
    Start         = 1,
    Running       = 2,
    Stop          = 3,
    Stopped       = 4,
    Reset         = 5;

  logic [2:0] State, NextState;
*/
  typedef enum{Zero,Start,Running,Stop,Stopped,Reset} state_t;
  state_t State,NextState;

  always_ff @(posedge Crystal, negedge nSysReset)
    if (!nSysReset)
      State <= Zero;
    else
      State <= NextState;

  always_comb //@(State,Buttons)
  begin

    NextState = State;

    WatchRunning = 0;
    WatchReset = 0;

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
/*      default:
                             NextState = 3'bx;
*/
    endcase
  end

endmodule
