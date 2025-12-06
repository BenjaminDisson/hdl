// apb_classes.sv

// ANSWER

// This file contains three class definitions:
//
// APB_Trans  - You don't need to alter this.  It is almost exactly
//              the same as the previous exercise, except that the "owner" data member
//              has been removed for simplicity.
//
// APB_Driver - BFM class, receives APB_Trans objects over a Channel
//              and actions each transaction on the bus.  You need
//              to complete the body() method of this class.
//
// APB_Stim   - Stimulus generator, creates randomised APB_Trans objects
//              and sends them out over a Channel.  You need to complete
//              the body() method of this class.


`ifndef APB_CLASSES__SV
`define APB_CLASSES__SV


typedef class APB_Trans;
typedef class APB_Driver;
typedef class APB_Stim;
typedef Channel #(APB_Trans) APB_Channel;

typedef enum bit {dir_Rd, dir_Wr} T_dir;
typedef logic [15:0] T_data;
typedef logic [15:0] T_addr;

typedef virtual APB_test_intf.test_mp APB_test_hook;

//_____________________________________________ class APB_Trans ___
//

class APB_Trans extends Transaction;

  rand  T_dir  dir;
  rand  T_addr addr;
  rand  T_data data;
  rand  int    idle_cycles;
  constraint reasonable_idles { idle_cycles inside {[0:6]} ;}

  function new();
    super.new();
  endfunction : new

  function Transaction copy();
    APB_Trans clone;
    clone = new();
    clone.dir  = dir;
    clone.addr = addr;
    clone.data = data;
    clone.idle_cycles = idle_cycles;
    return clone;
  endfunction : copy

  function bit compare(Transaction other);
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

  function string psprint();
    string kind, result;
    kind = (dir == dir_Rd) ? "read"  : "write";
    $sformat(result, "APB_Trans %s #%0d: A='h%h, D='h%h, %0d idles",
                       kind,         ID,    addr, data, idle_cycles);
    return result;
  endfunction : psprint

endclass : APB_Trans


//____________________________________________ class APB_Stim ___
//

class APB_Stim;

  APB_Channel sink;
  APB_Trans   template;
  int num_trans = 10;

  function new();
    // Provide a default generator object, which may be
    // replaced later by code in a test-case.
    template = new();
  endfunction : new

  // ANSWER:  Complete the body() method of this class.  It should
  //          generate an appropriate number of randomised APB_Trans
  //          objects, sending each in turn to the "sink" channel.
  task body();
    APB_Trans tr;
    $display("APB_Stim body begin");
    repeat (num_trans) 
    begin
      // ANSWER: Randomise the object, send a copy of it
      //         to the sink channel
      bit ok;
      ok = template.randomize();
      assert (ok) else
        $error("randomization failure in APB_Stim:\n   %s",
                            template.psprint());
	    //cast required since copy returns Transaction handle					
	    ok = $cast(tr, template.copy());
	    assert (ok) else
        $error("APB_Stim template is not derived from APB_Trans\n");
      sink.put(tr);
    end
    $display("APB_Stim body end");
  endtask

endclass : APB_Stim

//____________________________________________ class APB_Driver ___
//
// Class APB_Driver representing bus-functional model that
// can drive APB transactions through a virtual interface when
// the testbench calls the drive() method of this class, and
// can generate idle (inactive) clock cycles when the testbench
// calls the idle() method.  Also, log the number of read and
// write cycles successfully generated, and make those logged
// counts available by the testbench calling the get_trans_count()
// method.
//
class APB_Driver;

  // Virtual interface variable to hold a reference
  // to the test access interface that exists in our test
  // harness module
 
  APB_test_hook hook;

  // Storage for the read and write cycle counts
  //
  int trans_count[T_dir];

  APB_Channel source;

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

  function new(APB_test_hook _hook);
    hook = _hook;
  endfunction : new

  // ANSWER: Complete the body() method of this class.
  //
  task body();
    // ANSWER: Any necessary variable declarations.
	  APB_Trans tr;

    $display("APB_Driver body begin");
    idle(5);

    // ANSWER: Repeatedly...
    //         get a transaction from the channel;
    //         use $cast to downcast it to APB_Trans type;
    //         use this class's drive() method to action it on the bus.
    //
    // ANSWER: The simple loop
    //
    //           forever 
    //           begin
    //             source.get(...)   // blocking get
    //             drive(...)        // use the transaction
    //           end
    //
    //         is OK, but it will never terminate.  Instead,
    //         consider the alternative:
    //
    //           source.get        // get the first transaction
    //           do
    //             drive(...)      // use the transaction
    //           while (source.try_get(...))  // exit if no more data
    //
    source.get(tr);
    do begin
 	    drive(tr);
    end while (source.try_get(tr));
    idle(5);
    $display("APB_Driver body end: %0d Reads, %0d Writes",get_trans_count(dir_Rd),get_trans_count(dir_Wr));
  endtask

endclass : APB_Driver

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Implementations of "extern" methods
//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function int APB_Driver::get_trans_count(T_dir d);
  return trans_count[d];
endfunction : get_trans_count

task APB_Driver::idle(int N = 1);
  assert (N >= 0) else $error("Bad argument to APB_driver.idle");
  hook.cb.PSEL <= 1'b0;
  hook.cb.PENABLE <= 1'b0;
  hook.cycles(N);
endtask : idle

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

`endif
