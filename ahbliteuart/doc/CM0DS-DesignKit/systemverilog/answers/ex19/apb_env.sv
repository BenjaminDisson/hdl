// apb_env.sv

// Environment class


`ifndef APB_ENV__SV
`define APB_ENV__SV

// This environment class only contains one APB_Component.  Consequently
// it is rather straightforward and has very little work to do.

class APB_env extends Component;

  // Instance variable for the child component
  //
  APB_Component apb_comp;
  
  // ANSWER: Declare variables for the checker and channel

  APB_Checker checker_;
  APB_Channel mon_chan;
  
  // Constructor must call super.new() as usual, and then build
  // the APB_Component instance with this environment as its parent.
  // Virtual interface connection information is passed on directly
  // to the APB_Component, and is not held within this class.
  //
  function new(string _name, Component _parent, virtual APB_test_intf _hook);
    super.new( _name, _parent );
    apb_comp = new("apb_comp", this, _hook);

    // ANSWER: Instantiate and connect the checker and channel
    mon_chan  = new(1);
    checker_ = new("checker_", this);
    
    apb_comp.monitor.sink = mon_chan;
    checker_.source       = mon_chan;

  endfunction : new
  
  // This is a container component and has no functionality of its own.
  // Consequently its body() method is empty.  For the sake of the
  // exercise we add a diagnostic message. 
  // You do not need to change this task.
  //
  task body();
    $display("%s body begin", get_hier_name());
  endtask
  
  // Function allowing user code to configure
  // how many transactions to run
  //
  function void set_num_trans(int N);
    apb_comp.stim_gen.num_trans = N;
    $display("configured %s.num_trans = %0d",
               apb_comp.stim_gen.get_hier_name(), N );
  endfunction : set_num_trans
    
  // Function allowing user code to configure the template
  // generator object by replacing it with a different one
  //
  function void set_stim_template(APB_Trans t);
    apb_comp.stim_gen.template = t;
    $display("configured %s.template =\n     %s",
               apb_comp.stim_gen.get_hier_name(), t.psprint() );
  endfunction : set_stim_template
  
endclass : APB_env

`endif
