// apb_classes.sv

// YOU DO NOT NEED TO MODIFY THIS FILE

`ifndef APB_CLASSES__SV
`define APB_CLASSES__SV

typedef enum bit {dir_Rd, dir_Wr} T_dir;
typedef logic [15:0] T_data;
typedef logic [15:0] T_addr;


typedef virtual APB_test_intf.test_mp APB_test_hook;
typedef virtual APB_test_intf.mon_mp APB_mon_hook;

typedef class APB_Trans;
typedef class APB_Driver;
typedef class APB_Stim;
typedef Channel #(APB_Trans) APB_Channel;


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// class APB_Trans
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class APB_Trans extends Transaction;
  
  rand  T_dir  dir;
  rand  T_addr addr;
  rand  T_data data;
  rand  int    idle_cycles;
  constraint reasonable_idles { idle_cycles inside {[0:6]} ;}
  
  extern function new(Component owner = null);
  extern function Transaction copy();
  extern function bit compare(Transaction other);
  extern function string psprint();

endclass : APB_Trans


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// class APB_Stim
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class APB_Stim extends Component;

  APB_Channel sink;
  APB_Trans   template;
  int num_trans = 10;
  
  extern function new(string _name, Component _parent);
  extern task body();
  
endclass : APB_Stim

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// class APB_Driver
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class APB_Driver extends Component;

  // Virtual interface variable to hold a reference
  // to the test access interface that exists in our test
  // harness module
  //
  
  APB_test_hook hook;

  // Storage for the read and write cycle counts
  //
  int trans_count[T_dir];


  APB_Channel source;

  extern function new(string _name, Component _parent,
                      APB_test_hook _hook);
  extern task body();

  // Task permitting the testbench to make the bus idle
  // for one or more clock cycle(s).  You can assume that this
  // task is always called at the moment of a clock event.
  // Ensure that the bus signals PSEL and PENABLE are set to
  // zero at the beginning of the idle time.
  //
  extern task idle(int N = 1);

  // drive(t) task, takes a transaction and
  // actions it on the physical APB bus.  If it's a write
  // transaction (t.dir == dir_Wr) then simply perform the
  // write transaction.  If it's a read, do the read and
  // fill in t.data with the value captured from the bus.
  // You can assume that this task is called at the moment
  // of a clock event.
  //
  extern task drive(APB_Trans t);

  // Function permitting the testbench to ask this
  // class how many read or write transactions it has n
  // completed so far.
  //
  extern function int get_trans_count(T_dir d);

endclass : APB_Driver


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//                          IMPLEMENTATIONS                       //
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// class APB_Trans
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function APB_Trans::new(Component owner = null);
  super.new(owner);
endfunction : new

function Transaction APB_Trans::copy();
  APB_Trans clone;
  clone = new(owner);
  clone.dir  = dir;
  clone.addr = addr;
  clone.data = data;
  clone.idle_cycles = idle_cycles;
  return clone;
endfunction : copy

function bit APB_Trans::compare(Transaction other);
  APB_Trans that;
  bit ok;
  ok = $cast(that, other);
  assert (ok) else 
    $error("Can't compare APB_Trans with other %s", other.psprint());
  if (that.dir  !== dir ) return 1'b0;
  if (that.addr !== addr) return 1'b0;
  if (that.data !== data) return 1'b0;
  // DON'T compare idle_cycles
  return 1'b1;
endfunction : compare

function string APB_Trans::psprint();
  string kind, result;
  kind = (dir == dir_Rd) ? "read"  : "write";
  $sformat(result, "APB_Trans %s #%0d: A='h%h, D='h%h, %0d idles",
                     kind,         ID,    addr, data, idle_cycles);
  return result;
endfunction : psprint


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// class APB_Stim
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function APB_Stim::new(string _name, Component _parent);
  super.new( _name, _parent );
  template = new(this);
endfunction : new

task APB_Stim::body();
  APB_Trans tr;
  $display("%s body begin", get_hier_name());
  repeat (num_trans) 
  begin
    bit ok;
    ok = template.randomize();
    assert (ok) else
      $error("randomization failure in %s:\n   %s",
                          get_hier_name(), template.psprint());
    //cast required since copy returns Transaction handle					
    ok = $cast(tr, template.copy());
    assert (ok) else
      $error("APB_Stim template is not derived from APB_Trans\n");
    sink.put(tr);
  end
  $display("%s body end", get_hier_name());
endtask


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// class APB_Driver
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function APB_Driver::new(string _name, Component _parent,
             APB_test_hook _hook);
  super.new( _name, _parent );
  hook = _hook;
endfunction : new

task APB_Driver::body();
  APB_Trans tr;
  $display("%s body begin", get_hier_name());
  idle(5);
  source.get(tr);
  do begin
    drive(tr);
  end while (source.try_get(tr));
  idle(5);
  $display("%s body end", get_hier_name());
$finish;  //end simulation
endtask

 // Task permitting the testbench to make the bus idle
// for one or more clock cycle(s).  You can assume that this
// task is always called at the moment of a clock event.
// Ensure that the bus signals PSEL and PENABLE are set to
// zero at the beginning of the idle time.
//
task APB_Driver::idle(int N = 1);
  assert (N >= 0) else $error("Bad argument to APB_driver.idle");
  hook.cb.PSEL <= 1'b0;
  hook.cb.PENABLE <= 1'b0;
  hook.cycles(N);
endtask : idle

// drive(t) task, takes a transaction and
// actions it on the physical APB bus.  If it's a write
// transaction (t.dir == dir_Wr) then simply perform the
// write transaction.  If it's a read, do the read and
// fill in t.data with the value captured from the bus.
// You can assume that this task is called at the moment
// of a clock event.
//
task APB_Driver::drive(APB_Trans t);
  //
  // Implement any idle cycles called-for by the object.
  //
  idle(t.idle_cycles);
  //
  // Start of phase 1.  ASSUME we're already aligned to clock.
  // Make PADDR valid, PSEL=1, PENABLE=0.
  // For a write cycle, PWRITE=1 and PWDATA valid.
  // For a read cycle, PWRITE=0.
  hook.cb.PSEL <= 1'b1;
  hook.cb.PENABLE <= 1'b0;
  hook.cb.PADDR <= t.addr;
  if (t.dir == dir_Wr) 
  begin
    hook.cb.PWRITE <= 1'b1;
    hook.cb.PWDATA <= t.data;
  end 
  else 
  begin // read
    hook.cb.PWRITE <= 1'b0;
  end
  //
  // Hang around until the end of phase 1, start of phase 2.
  hook.cycles(1);
  //
  // Start of phase 2.  All signals remain the same,
  // except PENABLE=1.
  hook.cb.PENABLE <= 1'b1;
  //
  // Hang around until the end of phase 2.
  hook.cycles(1);
  //
  // End of phase 2, end of bus cycle.
  // If it's a read cycle, capture the value on PRDATA
  // and store it in t.data.
  if (t.dir == dir_Rd) 
  begin
    t.data = hook.cb.PRDATA;
  end

  // Increment the transaction count.
  trans_count[t.dir]++;

endtask : drive

// Function permitting the testbench to ask this
// class how many read or write transactions it has n
// completed so far.
//
function int APB_Driver::get_trans_count(T_dir d);
  return trans_count[d];
endfunction : get_trans_count


`endif
