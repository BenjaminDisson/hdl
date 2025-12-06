// mem_map_apb_trans.sv

// YOU DO NOT NEED TO MODIFY THIS FILE

`ifndef MEM_MAP_APB_TRANS__SV
`define MEM_MAP_APB_TRANS__SV

  
// Derived class for constrained stimulus, use in the "IF YOU HAVE TIME"
// part of the exercise.  You do not need to change this file, but you could easily
// add further derived transaction classes if you wish.

class Mem_map_APB_Trans extends APB_Trans;

  function new(Component owner = null);
    super.new(owner);
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


`endif
