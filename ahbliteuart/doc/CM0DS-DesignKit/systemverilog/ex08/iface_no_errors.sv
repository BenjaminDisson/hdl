// iface_no_errors.sv

// YOU DO NOT NEED TO MODIFY THIS FILE

// This version does not contain any errors, so your assertions should pass

module master (
  input  logic clk, reset,
  output logic req,
  input  logic ack, grant
);

  timeunit 1ns;
  timeprecision 1ns;

  typedef enum logic [1:0] {IDLE, REQUEST, WAITING_FOR_GRANT} state_type;
  state_type state;

  function flip_coin (input int sides);
    int r, n;
    r = $random;
    n = r % sides;
    return (n == 0);
  endfunction


  always_ff @(posedge clk or posedge reset)
    if (reset)
      state <= IDLE;
    else
    if (state == IDLE)
      begin
        if (!grant && flip_coin(10))
          state <= REQUEST;
      end
      else
        if (state == REQUEST)
          if (ack)
            state <= WAITING_FOR_GRANT;
          else
            state <= REQUEST;
        else
          if (state == WAITING_FOR_GRANT)
            if (grant == 1)
              state <= IDLE;
            else
              state <= WAITING_FOR_GRANT;
          else
            state <= IDLE;

  always_comb
  begin
    if (state == REQUEST)
      req <= 1'b1;
    else
      req <= 1'b0;
  end

endmodule



module arbiter (
  input  logic clk, reset, req,
  output logic ack, grant
);

  timeunit 1ns;
  timeprecision 1ns;

  typedef enum logic [2:0] {IDLE, ACKNOWLEDGE1, ACKNOWLEDGE2,
                            GRANTING1, GRANTING2, GRANTING3, GRANTING4} state_type;
  state_type state;


  function flip_coin (input int sides);
    int r, n;
    r = $random;
    n = r % sides;
    return (n == 0);
  endfunction


  always_ff @(posedge clk or posedge reset)
    if (reset)
      state <= IDLE;
    else
      case (state)
        IDLE :
           if (req == 1'b1)
           begin
             state <= ACKNOWLEDGE1;
             if (flip_coin(2))
               state <= ACKNOWLEDGE2;
           end

        ACKNOWLEDGE1 :
          state <= ACKNOWLEDGE2;

        ACKNOWLEDGE2 :
          begin
            state <= GRANTING1;
            if (flip_coin(4))
              state <= GRANTING4;
          end
        GRANTING1 :
          begin
            state <= GRANTING2;
            if (flip_coin(3))
              state <= GRANTING4;
          end
        GRANTING2 :
          begin
            state <= GRANTING3;
            if (flip_coin(2))
              state <= GRANTING4;
          end
        GRANTING3 :
          state <= GRANTING4;

        GRANTING4 :
          state <= IDLE;
      endcase

  always_comb
  begin
    ack <= 1'b0;
    grant <= 1'b0;

    case (state)
      ACKNOWLEDGE2 : ack <= 1'b1;
      GRANTING4    : grant <= 1'b1;
    endcase
  end

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
