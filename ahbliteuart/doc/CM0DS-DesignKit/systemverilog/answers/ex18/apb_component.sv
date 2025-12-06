// apb_component.sv

`ifndef APB_COMPONENT__SV
`define APB_COMPONENT__SV


// Component class, wrapper for APB_Driver and APB_Stim
// together with the channel that they use to communicate
//
class APB_Component extends Component;

  // ANSWER: Instance variables for stimulus generator,
  //         driver (BFM) and channel
  //
  APB_Stim    stim_gen;
  APB_Driver  driver;
  APB_Channel chan;
  
  // ANSWER: Constructor should build all three sub-components,
  //         remembering to pass on the virtual interface reference
  //         to any component(s) that need it.  Then it should
  //         connect the channel to the driver and BFM.
  //
  function new(string _name, Component _parent,
               virtual APB_test_intf _hook);
    super.new( _name, _parent );
    chan = new(1);
    stim_gen = new("stim_gen", this);
    driver = new("driver", this, _hook);
    stim_gen.sink = chan;
    driver.source = chan;
  endfunction : new
  
  // ANSWER: Like all classes derived from Component, this class
  //         needs an implementation of the body() method.  However,
  //         since this is a wrapper class the body() method has
  //         almost no work to do.  It's probably a good idea to
  //         generate some diagnostic message.
  //
  task body();
    $display("%s body begin", get_hier_name());
  endtask

  
endclass : APB_Component

`endif
