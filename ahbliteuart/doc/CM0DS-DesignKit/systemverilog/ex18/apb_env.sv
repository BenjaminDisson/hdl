// apb_env.sv

// YOU DO NOT NEED TO MODIFY THIS FILE (unless you do the IF YOU HAVE TIME)


`ifndef APB_ENV__SV
`define APB_ENV__SV

// This environment class only contains one APB_Component.  Consequently
// it is rather straightforward and has very little work to do.

class APB_env extends Component;

  // Instance variable for the child component
  //
  APB_Component apb_comp;
  
  // Constructor must call super.new() as usual, and then build
  // the APB_Component instance with this environment as its parent.
  // Virtual interface connection information is passed on directly
  // to the APB_Component, and is not held within this class.
  //
  function new(string _name, Component _parent, virtual APB_test_intf _hook);
    super.new( _name, _parent );
    apb_comp = new("apb_comp", this, _hook);
  endfunction : new
  
  // This is a container component and has no functionality of its own.
  // Consequently its body() method is empty.  For the sake of the
  // exercise we add a diagnostic message. 
  // You do not need to change this task.
  //
  task body();
    $display("%s body begin", get_hier_name());
  endtask
  
  // IF YOU HAVE TIME:
  // Function allowing user code to configure
  // how many transactions to run
  //
  //     function void set_num_trans(int N);
  
  // IF YOU HAVE TIME:
  // Function allowing user code to configure the template
  // generator object by replacing it with a different one
  //
  //     function void set_stim_template(APB_Trans t);
  
endclass : APB_env

`endif
