// iface.sv

// YOU DO NOT NEED TO MODIFY THIS FILE

// This version contains errors, so your assertions should fail

module master (
  input  logic clk, reset,
  output logic req,
  input  logic ack, grant
);

  timeunit 1ns;
  timeprecision 1ns;

  function flip_coin (input int sides);
    int r, n;
    r = $random;
    n = r % sides;
    return (n == 0);
  endfunction

  always
  begin : escape

    req <= 0;
    while (reset)
      @(posedge clk);
    while (!flip_coin(5))
    begin
      @(posedge clk);
      if (reset) disable escape;
    end
    req <= 1;
    @(posedge clk);
    if (reset) disable escape;
    if (flip_coin(3))
      req <= 0;
    while (ack == 0)
    begin
      @(posedge clk);
      if (reset) disable escape;
      if (flip_coin(3))
        req <= 0;
    end
    while (grant == 0)
    begin
      @(posedge clk);
      if (reset) disable escape;
      if (!flip_coin(20))         // req doesn't return to 0
        req <= 0;
    end
    while (grant)
    begin
      @(posedge clk);
      if (reset) disable escape;
      if (!flip_coin(20))         // req doesn't return to 0
        req <= 0;
      if (flip_coin(200))         // spurious req whilst grant is still high
        req <= 1;
    end

  end : escape

endmodule



module arbiter (
  input  logic clk, reset, req,
  output logic ack, grant
);

  timeunit 1ns;
  timeprecision 1ns;

  function flip_coin (input int sides);
    int r, n;
    r = $random;
    n = r % sides;
    return (n == 0);
  endfunction

  always
  begin: escape
    logic going;

    ack <= 0;
    grant <= 0;
    while (reset)
      @(posedge clk);

    @(posedge clk);
    if (reset) disable escape;
    while (req == 0)
    begin
      if (flip_coin(1000))            // spurious ack without a req
      begin
        ack <= 1;
        @(posedge clk);
        if (reset) disable escape;
        ack <= 0;
      end
      @(posedge clk);
      if (reset) disable escape;
    end
    if (flip_coin(2))
      ack <= 1;
    else if (!flip_coin(15))         // req -> ack takes > 2 cycles
    begin
      @(posedge clk);
      if (reset) disable escape;
      ack <= 1;
    end
    else
    begin
      @(posedge clk);
      if (reset) disable escape;
      @(posedge clk);
      if (reset) disable escape;
      ack <= 1;
    end
    for (int i = 7; i > 1; i--)
    begin
      if (flip_coin(i) || flip_coin(i))    // ack -> grant > 5 cycles
        grant <= 1;
      @(posedge clk);
      if (reset) disable escape;
      if (!flip_coin(50))             // ack pulse width > 1
        ack <= 0;
    end
    grant <= 1;
    @(posedge clk);
    if (reset) disable escape;
    going = 1;
    while (going)
    begin
      if (flip_coin(2))
      begin
        grant <= 0;
        going = 0;
      end
      @(posedge clk);
      if (reset) disable escape;
    end

  end : escape

endmodule



module iface;

  timeunit 1ns;
  timeprecision 1ns;

  logic clk, reset;
  logic req, ack, grant;

  parameter period = 10;

  always
  begin
    clk = 0;
    #(period/2);
    clk = 1;
    #(period/2);
  end

  initial
  begin: init
    reset = 1;
    #(period*3);
    reset = 0;
    for (int i = 1; i <= 10000; i = i + 1)
    begin
      @(negedge clk);
      if ((i % 1000) == 0)
      begin
        reset = 1;
        @(negedge clk);
        reset = 0;
      end
    end
    $stop;
    $finish;
  end

  master master1 (
                 .clk(clk),
                 .reset(reset),
                 .req(req),
                 .ack(ack),
                 .grant(grant)
          );

  arbiter arbiter1 (
                 .clk(clk),
                 .reset(reset),
                 .req(req),
                 .ack(ack),
                 .grant(grant)
          );

endmodule
