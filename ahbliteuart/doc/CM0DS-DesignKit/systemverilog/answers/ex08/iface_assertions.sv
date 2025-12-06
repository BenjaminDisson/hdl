// iface_assertions.sv

// ANSWER:

module iface_assertions ( input clk, reset, req, ack, grant );

  timeunit 1ns;
  timeprecision 1ns;

  default clocking cb @(posedge clk); endclocking

  // A rising edge on req must be followed after one or two cycles by a rising edge on ack.
  property ack_after_req;
    $rose(req) |-> ##[1:2] ack;
  endproperty
  a_ack_after_req : assert property ( disable iff (reset) ack_after_req );

  // ack must remain high for exactly one clock cycle, and no more.
  property ack_only_one_cycle;
    $rose(ack) |=> !ack;
  endproperty
  a_ack_only_one_cycle : assert property ( disable iff (reset) ack_only_one_cycle );

  // ack must be low at all other times ("req before ack"?)
  property ack_usually_low;
    ack |-> $past(req) || $past(req,2);
  endproperty
  a_ack_usually_low : assert property ( disable iff (reset) ack_usually_low );

  // A falling edge on req must occur no later than two clock cycles after the rising edge of ack.
  // req may return to zero earlier.
  property req_return_after_ack;
    $rose(ack) |-> ##2 !req;
  endproperty
  a_req_return_after_ack : assert property ( disable iff (reset) req_return_after_ack );

  // req must remain at zero until grant has returned to zero. A falling edge on grant may
  // coincide with a rising edge on req
  property req_zero_until_grant_zero;
    //$fell(req) |-> (!req throughout ##[0:$] grant) ##1 !grant;
    $fell(req) |-> !req[*0:$] ##1 $fell(grant);
    // $fell(req) |=> grant[=1] ##1 req;
  endproperty
  a_req_zero_until_grant_zero : assert property ( disable iff (reset) req_zero_until_grant_zero );

  // grant must go high (a rising edge) either in the same cycle in which ack goes high, or within
  // five cycles (inclusive).
  property grant_with_5_of_ack;
    $rose(ack) |-> ##[0:5] grant;
  endproperty
  a_grant_with_5_of_ack : assert property ( disable iff (reset) grant_with_5_of_ack );

  // If reset is high, then req, ack and grant all return low, overriding all the above.
  property reset_req_ack_grant;
    $rose(reset) |-> !req && !ack && !grant;
  endproperty
  a_reset_req_ack_grant : assert property ( reset_req_ack_grant );
 
endmodule : iface_assertions


// This must be explicitly added as a top-level module
module bindings;

  timeunit 1ns;
  timeprecision 1ns;

  bind iface iface_assertions iface_assertions_inst ( .* );
endmodule

