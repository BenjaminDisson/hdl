// countermonitor.sv

// ANSWER

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
  
  // ANSWER:  Add coverage collection here.
  //
  covergroup cvr_counter @(CounterTB.cb  iff !Reset);
    option.per_instance = 1;

    dir_cp : coverpoint UpDn {
      bins COUNT_UP   = {1'b1};
      bins COUNT_DOWN = {1'b0}; 
    }
  
    en_cp : coverpoint Enable {
      bins ENABLED    = {1'b1};
      bins DISABLED   = {1'b0}; 
    }
  
    load_cp  : coverpoint Load {
      bins LOAD       = {1'b1};
      bins NO_LOAD    = {1'b0}; 
    }

    loaded_val  : coverpoint Data {
      bins ZERO        = {8'h00};
      bins NON_ZERO[4] = {[8'h01:8'hFE]};
      bins MAX         = {8'hFF}; 
    }

    count_cp  : coverpoint Q {
      bins ZERO        = {8'h00};
      bins NON_ZERO[4] = {[8'h01:8'hFE]};
      bins MAX         = {8'hFF}; 
    }

    control_x : cross  en_cp, load_cp, dir_cp;

    // If you have time: add code to cover counter wrapping
    wrap_cp : coverpoint wrap;
  endgroup

  covergroup cvr_reset @(Reset);
    option.per_instance = 1;

    reset_cp : coverpoint Reset {
      bins RESET_ACTIVE   = {1'b1};
      bins RESET_INACTIVE = {1'b0};
    }
  endgroup
    
  cvr_counter cg1 = new();
  cvr_reset   cg2 = new();

  // ANSWER: Add code to detect when the counter wraps around
  always_comb
  begin
    logic [7:0] lastQ;

    if (Q == 8'h00 && lastQ == 8'hFF)
      wrap = WRAP_UP;
    else if (Q == 8'hFF && lastQ == 8'h00)
      wrap = WRAP_DOWN;
    else
      wrap = WRAP_NONE;
    
    lastQ = Q;
  end

endmodule
