// countermonitor.sv

module CounterMonitor;

  timeunit 1ns;
  timeprecision 1ps;

  // It is very tedious to use fully-qualified clocking block
  // names for every signal, so we create copies of those signals
  // here, with convenient local names.  If these are not quite
  // what you need for your coverage collection, feel free to
  // change them or add some new ones.
  //
  logic Reset;
  logic Enable;
  logic Load;
  logic UpDn;
  logic [7:0] Data;
  logic [7:0] Q;

  assign Reset  = CounterTB.cb.Reset;
  assign Enable = CounterTB.cb.Enable;
  assign Load   = CounterTB.cb.Load;
  assign UpDn   = CounterTB.cb.UpDn;
  assign Data   = CounterTB.cb.Data;
  assign Q      = CounterTB.cb.Q;

  enum {WRAP_DOWN, WRAP_UP, WRAP_NONE} wrap;

  // TO DO:  Add coverage collection here.
  covergroup cg @(CounterTB.cb);
    coverpoint CounterTB.cb.Reset;
    coverpoint CounterTB.cb.Enable;
    coverpoint CounterTB.cb.Load;
    coverpoint CounterTB.cb.UpDn;
    coverpoint CounterTB.cb.Data;
    coverpoint CounterTB.cb.Q;
    coverpoint CounterTB.cb.Q {
      bins countup = (16'hFF => 16'h00);
    }
  endgroup

  cg cg_inst = new;

  //cg_inst.sample();

  // TO DO: If you have time, add code to detect when the counter wraps around

endmodule
