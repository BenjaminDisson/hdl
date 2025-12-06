// mem_map_apb_trans.sv

`ifndef MEM_MAP_APB_TRANS__SV
`define MEM_MAP_APB_TRANS__SV

// Derived class for constrained stimulus
//
class Mem_map_APB_Trans extends APB_Trans;

  // TO DO:
  // Constraints, control knobs...
  rand enum{ROM, RAM, IO} area;
  constraint address_map {
   area == ROM -> addr inside {[16'h0000:16'h5FFF]};
   area == RAM -> addr inside {[16'h8000:16'hDFFF]};
   area == IO ->  addr inside {[16'hFF80:16'hFFFF]};
  }

  constraint ROM_read_only {area == ROM -> dir == dir_Rd;}
  constraint IO_byte_wide {area == IO -> data [15:8] == 0;}
  constraint area_choice {area dist {ROM:=60,RAM:=30,IO:=10};}


  // overridden virtual methods...
  /*virtual function APB_Trans copy();
    APB_Trans clone;
    clone = new(owner);
    clone.dir  = dir;
    clone.addr = addr;
    clone.data = data;
    clone.idle_cycles = idle_cycles;
    return clone;
  endfunction : copy
  */
  //

  //
  virtual function string psprint();
    $sformat(psprint,"area.name = %s - psprint de base = %s",area.name,super.psprint());
  endfunction : psprint

  // replacement constructor...
  function new(APB_Stream owner = null);
    super.new(owner);
  endfunction : new

endclass : Mem_map_APB_Trans

`endif
