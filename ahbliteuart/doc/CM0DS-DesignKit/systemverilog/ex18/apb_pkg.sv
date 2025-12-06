// apb_pkg.sv 

// YOU DO NOT NEED TO MODIFY THIS FILE (unless you do the IF YOU HAVE TIME)

package APB_pkg;

  `include "bases.sv"
  `include "apb_classes.sv"
  `include "apb_component.sv"
  `include "apb_env.sv"
  
  // IF YOU HAVE TIME:  this file included to get the definition
  // of a derived transaction class with additional constraints etc
  `include "mem_map_apb_trans.sv"  
  
endpackage : APB_pkg
