// apb_component.sv

`ifndef APB_COMPONENT__SV
`define APB_COMPONENT__SV


// Component class, wrapper for APB_Driver and APB_Stim
// together with the channel that they use to communicate
//
class APB_Component extends Component;

  //  TO DO: Instance variables for stimulus generator,
  //         driver (BFM) and channel
  //
  APB_Stim    stim_gen;
  APB_Driver  driver;
  APB_Channel chan;

  //  TO DO: Constructor should build all three sub-components,
  //         remembering to pass on the virtual interface reference
  //         to any component(s) that need it.  Then it should
  //         connect the channel to the driver and BFM.
  //
  function new(string instance_name,Component parent,
              virtual APB_test_intf hook);

    super.new(instance_name, parent);
    chan      = new();
    driver    = new("Mon_driver", this, hook);
    stim_gen  = new("Mon_genérateur", this);
    driver.source = chan;
    stim_gen.sink = chan;
  endfunction : new


  //  TO DO: Like all classes derived from Component, this class
  //         needs an implementation of the body() method.  However,
  //         since this is a wrapper class the body() method has
  //         almost no work to do.  It's probably a good idea to
  //         generate some diagnostic message.
  //
  task body;
    $display("Nom de mon composant : %s et mon parent est : %p",get_hier_name(), get_parent());
    //$display("Nom de mon composant : %s et mon parent est",get_hier_name());
  endtask


endclass : APB_Component

`endif
