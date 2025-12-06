// cpu_part2.sv

module cpu (
  input  logic clk, reset,
  input  logic [constants::ww-1:0] datai,

  output logic [constants::ww-1:0] addr,
  output logic [constants::ww-1:0] datao,
  output logic we, re, // write and read enables for synch. memory
  output logic fe     // instruction fetch mem cycle
);

  timeunit 1ns;
  timeprecision 1ns;

  import constants::*;

  logic [ww-1:0] pc;
  logic [ww-1:0] ir;

  logic [ww-1:0] regf [0:n_reg-1]; // signed!

  initial
    for (int i = 0; i < n_reg; i++)
      regf[i] = init_store;

  always
  begin : processor
    logic [rw-1:0] src, src2, dst;
    logic [ww+ww-1:0] wide_result; // signed!

    @(posedge clk)
    if (reset)
    begin
      pc <= 'b0;
      we <= 0;
      re <= 0;
      fe <= 0;
      @(negedge reset);
      @(posedge clk);
    end

    addr <= pc;
    re <= 1;
    fe <= 1;
    pc <= pc + 1;
    @(posedge clk)
    re <= 0;
    fe <= 0;
    @(posedge clk) //wait for memory
    ir <= datai;
    @(posedge clk)
    src  = ir[11:8];
    src2 = ir[7:4];
    dst  = ir[3:0];

    case (ir[15:12])

      nop_op:

        ;

      load_op:
      begin
        addr <= regf[src];
        re <= 1;
        pc <= pc + 1;
        @(posedge clk)
        re <= 0;
        @(posedge clk) // wait for memory
        regf[dst] <= datai;
      end

      store_op:
      begin
        datao <= regf[src];
        addr  <= regf[dst];
        we <= 1;
        @(posedge clk) // wait for memory
        we <= 0;
      end

      move_op:
      begin
        regf[dst] <= regf[src];
      end

      movi_op:
      begin
        regf[dst] <= ir[11:4];
      end

      movhi_op:
      begin: blk
        logic [ww-1:0] tmp;
        tmp       = regf[dst];
        tmp[15:8] = ir[11:4];
        regf[dst] <= tmp;
      end

      add_op:
      begin
        regf[dst] <= regf[src] + regf[src2];
      end

      addi_op:
      begin
        regf[dst] <= regf[src] + {{ww-4{ir[7]}}, ir[7:4]};
      end

      sub_op:
      begin
        regf[dst] <= regf[src] - regf[src2];
      end

      subi_op:
      begin
        regf[dst] <= regf[src] - {{ww-4{ir[7]}}, ir[7:4]};
      end

      mul_op:
      begin
        wide_result = regf[src] * regf[src2];
        regf[dst] <= wide_result[ww-1:0];
      end

      and_op:
      begin
        regf[dst] <= regf[src] & regf[src2];
      end

      or_op:
      begin
        regf[dst] <= regf[src] | regf[src2];
      end

      jump_op:
      begin
        pc <= regf[dst];
      end

      jzero_op:
      begin
        if (regf[src] == 0)
          pc <= regf[dst];
      end

      jneg_op:
      begin: jneg_blk
        logic [ww-1:0] tmp;
        tmp = regf[src];
        if (tmp[ww-1]) // i.e. negative
          pc <= regf[dst];
      end

      default:
        ;

    endcase
  end : processor

  // Assertions
  default clocking cb @(posedge clk);
  endclocking
    a1 : assert property (disable iff (reset) we |-> !re);
 // a2 : assert property (disable iff (reset) re |-> !we);
  a2 : assert property (disable iff (reset) we ##1 !we |-> !re);
  a3 : assert property (disable iff (reset) re ##1 !re |-> !re[*2:$]);
  a4a : assert property (disable iff (reset) we |=> !we );
  a4b : assert property (disable iff (reset) re |=> !re );
  a5 : assert property (disable iff (reset) fe |-> re);
  b1 : assert property (disable iff (reset) $fell(fe) & (datai[15:12] == nop_op) |-> (!re & !we)[*3] );
  b2 : assert property (disable iff (reset) $fell(fe) & (datai[15:12] == load_op) |=> ##1 re & !fe && (addr == regf[ir[11:8]]) );
  b5 : assert property ($fell(reset) |-> pc === 'b0);



endmodule


module rom (
  input  logic clk, reset,
  input  logic [constants::rom_aw-1:0] addr,
  output logic [constants::ww-1:0]     datao,
  input  logic re
);

  timeunit 1ns;
  timeprecision 1ns;

  import constants::*;

  initial
  begin: processor

    logic [ww-1:0] store [0:(2**rom_aw)-1];

    logic  do_random;

    for (int i = 0; i < 2**rom_aw; i++)
      store[i] = 0;

    $readmemb("store.txt", store);

    forever @(posedge clk)
      if (re)
      begin
        do_random = 0;
        for (int i = 0; i < rom_aw; i++)
          if (addr[i] === 1'bx)
            do_random = 1;
        if (!do_random)
        begin
          if (addr < 32)
            datao <= store[addr];
          else
            do_random = 1;
        end
        if (do_random)
          datao <= $random;
      end
      else
        datao <= 'bz;

  end : processor

endmodule


module sram (
  input  logic                         clk, reset,
  input  logic [constants::ww-1:0]     datai,
  input  logic [constants::ram_aw-1:0] addr,
  output logic [constants::ww-1:0]     datao,
  input  logic                         we, re
);

  timeunit 1ns;
  timeprecision 1ns;

  import constants::*;

  initial
  begin: processor

    logic [ww-1:0] store [0:(2**ram_aw)-1];

    for (int i = 0; i < 2**ram_aw; i++)
      store[i] = init_store;

    forever @(posedge clk)
    begin
      if (we)
        store[addr] = datai;
      if (re)
        datao <= store[addr];
      else
        datao <= 'bz;
    end
  end : processor

endmodule


module test;

  timeunit 1ns;
  timeprecision 1ns;

  import constants::*;

  logic clk, reset;
  wire  [ww-1:0] datar;
  logic [ww-1:0] addr;
  logic [ww-1:0] dataw;
  logic we, re, fe;
  logic rom_re;
  logic ram_re;
  logic ram_we;

  parameter period = 10;

  always
  begin
    clk = 0;
    #(period/2);
    clk = 1;
    #(period/2);
  end

  initial
  begin
    reset = 1;
    #(period*4);
    reset = 0;
    #(period*25000);
    reset = 1;
    #(period*4);
    reset = 0;
    #(period*2500);
    $stop;
    $finish;
  end

  assign rom_re = fe & re;
  assign ram_re = ~fe & re;
  assign ram_we = ~fe & we;

  cpu cpu1 (
             .clk(clk),
             .reset(reset),
             .datai(datar),
             .addr(addr),
             .datao(dataw),
             .we(we),
             .re(re),
             .fe(fe)
           );

  rom rom1 (
             .clk(clk),
             .reset(reset),
             .addr(addr[rom_aw-1:0]),
             .datao(datar),
             .re(rom_re)
          );

  sram ram1 (
             .clk(clk),
             .reset(reset),
             .datai(dataw),
             .addr(addr[ram_aw-1:0]),
             .datao(datar),
             .we(ram_we),
             .re(ram_re)
          );

endmodule
