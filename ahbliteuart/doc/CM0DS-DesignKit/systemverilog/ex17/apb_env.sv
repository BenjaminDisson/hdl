// apb_env.sv

`ifndef APB_ENV__SV
`define APB_ENV__SV

class APB_env;

  // Environment class


  // TO DO:  Instance variables for stimulus generator,
  //         driver (BFM) and a channel connecting them.
  //         SUGGESTION: use the name "gen" for the generator
  //         instance, and "bfm" for the driver/BFM instance
  //
  APB_Stim gen;
  APB_Driver bfm;
  APB_Channel ch;



  //
  // TO DO:  Constructor should build the internal
  //         instances (generator, BFM, channel) and
  //         make all necessary connections among them
  //
  function new(virtual APB_test_intf.test_mp hook);
    bfm = new(hook);
    gen = new();
    ch  = new(0);
    gen.sink = ch;
    bfm.source = ch;
  endfunction : new



  // TO DO:  Provide a run() task that executes the body()
  //         methods of both generator and BFM in parallel
  //         in parallel using fork...join
  //
  task run;
    fork
      bfm.body();
      gen.body();
    join
  endtask;


  //
endclass : APB_env

`endif
