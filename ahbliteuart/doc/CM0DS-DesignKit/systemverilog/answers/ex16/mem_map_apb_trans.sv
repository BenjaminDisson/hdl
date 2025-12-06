// mem_map_apb_trans.sv

`ifndef MEM_MAP_APB_TRANS__SV
`define MEM_MAP_APB_TRANS__SV

// Derived class for constrained stimulus
//
class Mem_map_APB_Trans extends APB_Trans;

  // ANSWER:
  function new(APB_Stream owner = null);
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
      
  virtual function APB_Trans copy();
    Mem_map_APB_Trans clone;
    clone = new(owner);
    clone.dir  = dir;
    clone.addr = addr;
    clone.data = data;
    clone.idle_cycles = idle_cycles;
    clone.area = area;
    $display("Mem_map_APB_Trans.copy()");
    return clone;
  endfunction : copy
                

  virtual function string psprint();
    string kind, result;
    kind = (dir == dir_Rd) ? " read"  : "write";
    $sformat(result, "Mem_map_Trans.psprint() ==>>>  APB %s #%0d: A='h%h, D='h%h, %0d idles",
                                                      kind,    ID,    addr, data, idle_cycles);
    return result;
  endfunction : psprint
  

endclass : Mem_map_APB_Trans

`endif
