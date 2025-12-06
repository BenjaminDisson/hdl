// counter.sv

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

  //Assertions
  default clocking cb @(posedge Clock);
  endclocking
  a1 : assert property (Reset |-> (Q === 0));
  a2 : assert property (disable iff (Reset) !Enable |=> (Q === $past(Q)));
  a3 : assert property (disable iff (Reset) Enable & Load |=> (Q === $past(Data)));
  a4 : assert property (disable iff (Reset) Enable & !Load & !UpDn |=> (Q === $past(Q)-1'b1));
  a5 : assert property (disable iff (Reset) Enable & !Load & UpDn |=> (Q === $past(Q)+1'b1));

  a6 : cover property (disable iff (Reset) !Enable);
  a7 : cover property (Reset);

endmodule
