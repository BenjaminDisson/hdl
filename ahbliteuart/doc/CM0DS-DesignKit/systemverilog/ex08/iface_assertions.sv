// iface_assertions.sv

module iface_assertions ( input clk, reset, req, ack, grant );

  timeunit 1ns;
  timeprecision 1ns;

  // Add properties, sequences, assertions here
  default clocking cb @(posedge clk);
  endclocking

  a1 : assert property (disable iff (reset) $rose(req) |-> (##1 ack) or (##2 ack));//##[1:2] $rose(ack)
  a2 : assert property (disable iff (reset) ack |=> !ack);
  a3 : assert property (disable iff (reset) $rose(ack) |-> $past(req) or $past(req,2));
  a4 : assert property (disable iff (reset) ack |-> $fell(req) or (##1 $fell(req)));
  a5 : assert property (disable iff (reset) grant |-> !req);
  a6 : assert property (disable iff (reset) $rose(grant) |-> $rose(ack) or $past(ack) or $past(ack,2) or $past(ack,3) or $past(ack,4) or $past(ack,5));
  a7 : assert property ($fell(reset) |-> (req === 'b0) and (ack === 'b0) and (grant === 'b0));
endmodule

// This must be explicitly added as a top-level module
module bindings;

  timeunit 1ns;
  timeprecision 1ns;

  bind iface iface_assertions iface_assertions_inst ( .* );
endmodule

