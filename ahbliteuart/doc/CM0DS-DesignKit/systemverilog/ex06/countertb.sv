// countertb.sv

// YOU DO NOT NEED TO MODIFY THIS FILE

module Countertb;

  timeunit 1ns;
  timeprecision 1ns;

  logic Clock, Reset, Enable, Load, UpDn;
  logic [7:0] Data;
  logic [7:0] Q;

  always
  begin
    #5 Clock = 1;
    #5 Clock = 0;
  end

  initial
  begin
    Enable = 0;
    Load = 0;
    UpDn = 1;
    Reset = 1;
    #10; // Should be reset
    Reset = 0;
    #10; // Should do nothing - not enabled
    Enable = 1;
    #20; // Should count up to 2
    UpDn = 0;
    #40; // Should count downto 254
    UpDn = 1;
    #40; // Should count up to 2
    Reset = 1;
    #10; // Should be reset, overriding enable
    Reset = 0;
    #30; // Should count up to 3
    Enable = 0;
    #10; // Should do nothing - not enabled
    Data = 8'b01111111;
    Load = 1;
    #10; // Should do nothing - not enabled
    Load = 0;
    Enable = 1;
    #10; // Should count from 3 to 4
    Load = 1;
    #10; // Should load 127
    Data = 8'bx;
    Load = 0;
    #20; // Should count from 127 to 129
    Enable = 0;
    #10; // Should do nothing - not enabled
    UpDn = 0;
    #10; // Should do nothing - not enabled
    Enable = 1;
    #20; // Should count down from 129 to 127
    Data = 8'b11110000;
    Load = 1;
    #10; // Should load
    Reset = 1;
    #10; // Should be reset, overriding load
    Data = 8'bx;
    Load = 0;
    UpDn = 1;
    #10; // Should stay at 0 - still reset
    Reset = 0;
    #2560; // Should count from 0 round to 0
    Enable = 0;
    $stop;
    $finish;
  end

  Counter G1 (Clock, Reset, Enable, Load, UpDn, Data, Q);

endmodule
