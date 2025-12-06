// counter.sv

// YOU DO NOT NEED TO MODIFY THIS FILE

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

endmodule : Counter
