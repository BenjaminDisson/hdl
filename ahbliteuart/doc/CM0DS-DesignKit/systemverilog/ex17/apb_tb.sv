// apb_tb.sv  

// YOU DO NOT NEED TO MODIFY THIS FILE

// Top-level module definition for a testbench
// around a simple APB bus model

module APB_TB;

  import APB_pkg::*;

  // Derived class for constrained stimulus
  //
  class Mem_map_APB_Trans extends APB_Trans;

    function new();
      super.new();
    endfunction : new

    rand enum {ROM, RAM, IO} area;

    constraint address_area {
      area == ROM -> addr inside {['h0000:'h5FFF]};
      area == RAM -> addr inside {['h8000:'hDFFF]};
      area == IO  -> addr inside {['hFF80:'hFFFF]};
    }

    constraint ROM_read {
      area == ROM -> dir == dir_Rd;
    }
    constraint IO_bytewide_slow {
      area == IO -> data[15:8] == 0;
      area == IO -> idle_cycles == 5;
    }

    constraint area_dist {
      area dist { ROM := 6, RAM := 3, IO := 1 };
    }
        
    virtual function Transaction copy();
      Mem_map_APB_Trans clone = new();
      clone.dir  = dir;
      clone.addr = addr;
      clone.data = data;
      clone.idle_cycles = idle_cycles;
      clone.area = area;
      $display("Mem_map_APB_Trans.copy()");
	    $display(clone.psprint);
      return clone;
    endfunction : copy
                  

    virtual function string psprint();
      string kind = (dir == dir_Rd) ? " read"  : "write";
      return $sformatf("Mem_map_Trans.psprint() ==>>>  APB %s %s #%0d: A='h%h, D='h%h, %0d idles",
                                                        area.name(), kind,    ID,    addr, data, idle_cycles);
    endfunction : psprint
    

  endclass : Mem_map_APB_Trans

// _________________________________________________ TB body ___

  initial
  begin

    // Environment object
    APB_env tb;

    // Stimulus generator's template object.
    Mem_map_APB_Trans test_tr;

    // Create the environment object, hook it to the test harness...
    tb = new(APB_harness.TB_intf.test_mp);

    // Create new template object.
    test_tr = new();

    // Install our template object in the stimulus generator
    tb.gen.template = test_tr;
	
	  // Set the number of transactions generated
	  tb.gen.num_trans = 100;

    // and let it run.
    tb.run();
    $display("returned from top level run()");
    
    $finish();

  end

endmodule : APB_TB
