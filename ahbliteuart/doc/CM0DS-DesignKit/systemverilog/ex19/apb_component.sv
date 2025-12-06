// apb_component.sv


`ifndef APB_COMPONENT__SV
`define APB_COMPONENT__SV

// Component class, wrapper for APB_Driver and APB_Stim
// together with the channel that they use to communicate
//
class APB_Component extends Component;

  // Instance variables for stimulus generator,
  //         driver (BFM) and channel
  //
  APB_Stim    stim_gen;
  APB_Driver  driver;
  APB_Channel stim_chan;

  // TO DO: Declare a variable for the monitor
  APB_Monitor my_monitor;

  function new(string _name, Component _parent,
               virtual APB_test_intf _hook);
    super.new( _name, _parent );
    stim_chan = new(1);
    stim_gen = new("stim_gen", this);
    driver   = new("driver", this, _hook);

    stim_gen.sink   = stim_chan;
    driver.source   = stim_chan;

    // TO DO: Instantiate the monitor
  my_monitor = new("monitor", this, _hook);

  endfunction : new

  task body();
    $display("%s body begin", get_hier_name());
  endtask


endclass : APB_Component

`endif
