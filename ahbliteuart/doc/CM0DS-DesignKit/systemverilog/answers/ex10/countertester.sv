// countertester.sv

// ANSWER

module CounterTester;

  timeunit 1ns;
  timeprecision 1ps;

  //__________________________________________________________________________
  initial
  begin : stimulus
    // This directed test controls clocking block signals directly
    //
    // CounterTB.cycles(1);  // Line up with the first clock edge
    // CounterTB.cb.Enable <= 0;
    // CounterTB.cb.Load <= 0;
    // CounterTB.cb.UpDn <= 1;
    // CounterTB.cb.Reset <= 1;
    // CounterTB.cycles(1); // Should be reset
    // CounterTB.cb.Reset <= 0;
    // CounterTB.cycles(1); // Should do nothing - not enabled
    // CounterTB.cb.Enable <= 1;
    // CounterTB.cycles(2); // Should count up to 2
    // CounterTB.cb.UpDn <= 0;
    // CounterTB.cycles(4); // Should count down to 254
    // CounterTB.cb.UpDn <= 1;
    // CounterTB.cycles(4); // Should count up to 2
    // CounterTB.cb.Reset <= 1;
    // CounterTB.cycles(1); // Should be reset, overriding enable
    // CounterTB.cb.Reset <= 0;
    // CounterTB.cycles(3); // Should count up to 3
    // CounterTB.cb.Enable <= 0;
    // CounterTB.cycles(1); // Should do nothing - not enabled
    // CounterTB.cb.Data <= 8'b01111111;
    // CounterTB.cb.Load <= 1;
    // CounterTB.cycles(1); // Should do nothing - not enabled
    // CounterTB.cb.Load <= 0;
    // CounterTB.cb.Enable <= 1;
    // CounterTB.cycles(1); // Should count from 3 to 4
    // CounterTB.cb.Load <= 1;
    // CounterTB.cycles(1); // Should load 127
    // CounterTB.cb.Load <= 0;
    // CounterTB.cycles(2); // Should count from 127 to 129
    // CounterTB.cb.Enable <= 0;
    // CounterTB.cycles(1); // Should do nothing - not enabled
    // CounterTB.cb.UpDn <= 0;
    // CounterTB.cycles(1); // Should do nothing - not enabled
    // CounterTB.cb.Enable <= 1;
    // CounterTB.cycles(2); // Should count down from 129 to 127
    // CounterTB.cb.Data <= 8'b11110000;
    // CounterTB.cb.Load <= 1;
    // CounterTB.cycles(1); // Should load 240
    // CounterTB.cb.Reset <= 1;
    // CounterTB.cycles(1); // Should be reset, overriding load
    // CounterTB.cb.Load <= 0;
    // CounterTB.cb.UpDn <= 1;
    // CounterTB.cycles(1); // Should stay at 0 - still reset
    // CounterTB.cb.Reset <= 0;
    // CounterTB.cycles(256); // Should count from 0 round to 0
    // CounterTB.cb.Enable <= 0;

    //___________________________________________________________________________
    // ANSWER: Replace the directed tests above with a loop containing a randcase
    //
    CounterTB.initialise();
    CounterTB.count_enable(1);
    repeat (1000)
    begin
      randcase
        3  : CounterTB.toggle_count_enable();
        3  : CounterTB.toggle_count_dir();
        1  : CounterTB.do_reset();
        10 : CounterTB.gen_random_load_value();
        74 : CounterTB.cycles(1); 
      endcase
    end
    //___________________________________________________________________________
 
    $finish;
  end : stimulus

endmodule : CounterTester
