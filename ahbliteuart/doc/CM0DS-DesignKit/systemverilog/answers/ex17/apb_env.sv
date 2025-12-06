// apb_env.sv

// ANSWER

`ifndef APB_ENV__SV
`define APB_ENV__SV

class APB_env;

  // Environment class

  // ANSWER: Instance variables for stimulus generator,
  //         driver (BFM) and a channel connecting them.
  //         SUGGESTION: use the name "gen" for the generator
  //         instance, and "bfm" for the driver/BFM instance
  //
  APB_Stim    gen;
  APB_Driver  bfm;
  APB_Channel chan;

  // ANSWER: Constructor should build the internal
  //         instances (generator, BFM, channel) and
  //         make all necessary connections among them
  //
  function new( APB_test_hook _hook );
    chan = new(1);      // Create the channel as a 1-place FIFO
    gen = new();        // Create the generator
    bfm = new(_hook);   // Create and connect the driver/BFM
    gen.sink = chan;    // Connect the channel to generator ...
    bfm.source = chan;  // ... and BFM
  endfunction : new

  // ANSWER: Provide a run() task that executes the body()
  //         methods of both generator and BFM in parallel
  //         in parallel using fork...join
  //
  task run();
    fork
      gen.body();
      bfm.body();
    join
  endtask

endclass : APB_env

`endif
