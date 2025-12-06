// countertester.sv

// YOU DO NOT NEED TO MODIFY THIS FILE for the first part of the exercise, at least.
// You may want to extend the test stimulus for the later part of the exercise

module CounterTester;

  timeunit 1ns;
  timeprecision 1ps;

  initial
  begin : stimulus
    CounterTB.initialise();
    CounterTB.count_enable(1);

    repeat (5000)
    begin
      randcase
        3  : CounterTB.toggle_count_enable();
        3  : CounterTB.toggle_count_dir();
        1  : CounterTB.do_reset();
        10 : CounterTB.gen_random_load_value();
        74 : CounterTB.cycles(1);
      endcase
    end

    CounterTB.count_enable(1);
    CounterTB.cycles(256);



    $finish;
  end : stimulus

endmodule : CounterTester
