// counter.sv

// ANSWER:

module Counter (
  input  logic Clock, Reset, Enable, Load, UpDn,
  input  logic [7:0] Data,
  output logic [7:0] Q
);

  timeunit 1ns;
  timeprecision 1ns;

  always_ff @(posedge Clock or posedge Reset)
    if (Reset)
      Q <= 0;
    else
      if (Enable)
        if (Load)
          Q <= Data;
        else
          if (UpDn)
            Q <= Q + 1;
          else
            Q <= Q - 1;
           

  // Reset - active high, asynchronous
  aReset : assert property ( @(posedge Clock) Reset |-> Q == 0 );
  
  // Enable
  aEnable : assert property ( @(posedge Clock) disable iff (Reset) !Enable |=> Q == $past(Q) );

  // Load
  aLoad   : assert property ( @(posedge Clock) disable iff (Reset) Enable && Load |=> Q == $past(Data) );

  // Count up
  aUp   : assert property ( @(posedge Clock) disable iff (Reset) Enable && !Load && UpDn |=> Q == $past(Q)+8'b1 );

  // Count down
  aDown : assert property ( @(posedge Clock) disable iff (Reset) Enable && !Load && !UpDn |=> Q == $past(Q)-8'b1 );

  
endmodule
