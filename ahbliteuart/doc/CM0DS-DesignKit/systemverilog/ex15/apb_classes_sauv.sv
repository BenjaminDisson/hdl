// apb_classes.sv

// YOU NEED TO COMPLETE THIS FILE -
// see comments containing "TO DO:"


// Class and related definitions for building verification
// components around a simple APB bus model.
//
// This file contains one package APB_pkg containing the
// following definitions:
//
// - some useful typedefs
// - a class 'APB_Trans' representing a single
//   bus transaction on the APB bus
// - a class 'APB_Stream' representing a generator
//   of APB_Trans objects
// - a class 'APB_Driver' representing a bus functional model
//   that can drive transactions on to the APB
//
// TO DO: In this exercise you need to complete the APB_Driver class.
// You will find it near the bottom of the file - search forward for
// the string "TO DO".  The other two classes are taken directly
// from the answer to the previous exercise.

`ifndef APB_CLASSES__SV
`define APB_CLASSES__SV

typedef enum bit {dir_Rd, dir_Wr} T_dir;
typedef logic [15:0] T_data;
typedef logic [15:0] T_addr;

typedef class APB_Stream;

//_____________________________________________ class APB_Trans ___
//
class APB_Trans;
  //
  static int       next_ID;
  //
  const int        ID;
  const APB_Stream owner;
  rand  T_dir      dir;
  rand  T_addr     addr;
  rand  T_data     data;
  //
  function new(APB_Stream owner = null);
    this.owner = owner;
    ID = next_ID++;
  endfunction : new
  //
  function APB_Trans copy();
    APB_Trans clone;
    clone = new(owner);
    clone.dir  = dir;
    clone.addr = addr;
    clone.data = data;
    return clone;
  endfunction : copy
  //
  function bit compare(APB_Trans other);
    if (other.dir  !== dir ) return 1'b0;
    if (other.addr !== addr) return 1'b0;
    if (other.data !== data) return 1'b0;
    return 1'b1;
  endfunction : compare
  //
  function string psprint();
    string kind, result;
    kind = (dir == dir_Rd) ? " read"  : "write";
    $sformat(result, "%s APB_Trans #%0d: A=%h, D=%h",
                       kind,         ID,    addr, data);
    return result;
  endfunction : psprint
  //
endclass : APB_Trans


//____________________________________________ class APB_Stream ___
//
class APB_Stream;
  //
  string    name;
  APB_Trans history[$];
  //
  function APB_Trans get_trans(bit print = 1'b0);
    APB_Trans t;
    t = new(this);
    void'(t.randomize());
    history.push_back(t);
    if (print)
      $display("Stream %s generated %s", name, t.psprint());
    return t;
  endfunction : get_trans
  //
  function new(string name = "<anon>");
    this.name = name;
  endfunction : new
  //
endclass : APB_Stream

//____________________________________________ class APB_Driver ___
//
// TO DO: class APB_Driver representing bus-functional model that
// can drive APB transactions through a virtual interface when
// the testbench calls the drive() method of this class, and
// can generate idle (inactive) clock cycles when the testbench
// calls the idle() method.  Also, log the number of read and
// write cycles successfully generated, and make those logged
// counts available by the testbench calling the get_trans_count()
// method.
//
class APB_Driver;

  // TO DO: Virtual interface variable to hold a reference
  // to the test access interface that exists in our test
  // harness module
  //
  virtual APB_test_intf.test_mp my_virtual_intf;

  // TO DO: Storage for the read and write cycle counts
  //
  int count_read;
  int count_write;

  // TO DO: Constructor, sets up virtual interface variable
  // to reference the interface instance specified in
  // the call to new(...)
  //
  function new(virtual APB_test_intf.test_mp my_virtual_intf);
    this.my_virtual_intf = my_virtual_intf;
  endfunction : new

  // TO DO: drive(t) task, takes a transaction and
  // actions it on the physical APB bus.  If it's a write
  // transaction (t.dir == dir_Wr) then simply perform the
  // write transaction.  If it's a read, do the read and
  // fill in t.data with the value captured from the bus.
  // You can assume that this task is called at the moment
  // of a clock event.
  //
  task drive(APB_Trans t);
    //
    // Start of phase 1.  ASSUME we're already aligned to clock.
    // Make PADDR valid, PSEL=1, PENABLE=0.
    // For a write cycle, PWRITE=1 and PWDATA valid.
    // For a read cycle, PWRITE=0.
    my_virtual_intf.cb.PENABLE <= 0 ;
    my_virtual_intf.cb.PSEL    <= 1 ;
    my_virtual_intf.cb.PADDR   <= t.addr ;

    if (t.dir == dir_Wr)
    begin // write
      my_virtual_intf.cb.PWRITE    <= 1 ;
      my_virtual_intf.cb.PWDATA    <= t.data ;
    end
    else
    begin // read
      my_virtual_intf.cb.PWRITE    <= 0 ;
    end
    //
    // Hang around until the end of phase 1, start of phase 2.
    my_virtual_intf.cycles(1);
    //
    // Start of phase 2.  All signals remain the same,
    // except PENABLE=1.
    my_virtual_intf.cb.PENABLE <= 1 ;
    //
    // Hang around until the end of phase 2.
    my_virtual_intf.cycles(1);
    //
    // End of phase 2, end of bus cycle.
    // If it's a read cycle, capture the value on PRDATA
    // and store it in t.data.
    if (t.dir == dir_Rd)
    begin
      t.data     <=  my_virtual_intf.cb.PRDATA;
    end

    // Increment the transaction counts.
    if (t.dir == dir_Wr)
      count_write++;
    else
      count_read++;



  endtask : drive

  // TO DO: Task permitting the testbench to make the bus idle
  // for one or more clock cycle(s).  You can assume that this
  // task is always called at the moment of a clock event.
  // Ensure that the bus signals PSEL and PENABLE are set to
  // zero at the beginning of the idle time.
  //
  task idle(int N = 1);
    my_virtual_intf.cb.PENABLE <= 0 ;
    my_virtual_intf.cb.PSEL    <= 0 ;
    my_virtual_intf.cycles(N);
  endtask : idle

  // TO DO: Function permitting the testbench to ask this
  // class how many read or write transactions it has
  // completed so far.
  //
  function int get_trans_count(T_dir d);
    if (d == dir_Wr)
      return count_write;
    else
      return count_read;
  endfunction : get_trans_count

endclass : APB_Driver


//_______________________________________________ class APB_Env ___
//
// TO DO: In this exercise you need to complete the APB_Env
// testbench environment class
//
class APB_Env;

  // TO DO: instances of stream and driver classes -
  // we suggest you call the stream "gen" and the driver "bfm"
  //
  APB_Driver bfm;
  APB_Stream gen;

  // TO DO: constructor function needs to build the
  // stream and driver objects.  The virtual interface
  // reference that is passed into this constructor
  // (referencing the test access interface's modport)
  // is not needed in the environment class, but must be
  // passed on to the BFM class's constructor.
  //
  function new(virtual APB_test_intf.test_mp my_virtual_intf);
    bfm = new(my_virtual_intf);
    gen = new("Générateur de données");
  endfunction : new

  // TO DO: Provide a run() method for the environment
  // class.  This run() method should do everything:
  // set up any initial conditions, then get a number of
  // random APB transactions from the generator object and
  // pass them on to the BFM object.  Ideally there should
  // be a randomized gap (which could be zero) between
  // successive transactions on the bus.  The number of bus
  // cycles should be passed as an argument to run(), but
  // this argument should have a default value of 20.
  //
  task run(int n_trans = 20);

    // TO DO: Declare any necessary local variables
    //
    /*int read_count;
    int write_count;
    APB_Trans mon_generateur;
    */
    int nb_idle;
    // TO DO: Line up the BFM with its clock
    //
    bfm.idle(1);

    // TO DO: Run the required number of transactions
    assert(std::randomize(n_trans));
    repeat(n_trans)
    begin
      // TO DO: Randomized gap between transactions, may be zero
      assert(std::randomize(nb_idle));
      // TO DO: Pull a transaction from the generator object
      // and pass it on to the BFM's drive() task.
      bfm.drive(gen.get_trans());

    end

    // TO DO: Finally, create a few clock cycles with no activity
    bfm.idle(20);

    // Report simulation statistics
    $display("\nGenerated %0d reads, %0d writes",
               bfm.get_trans_count(dir_Rd),
               bfm.get_trans_count(dir_Wr)
             );

    // That's All Folks.
  endtask : run

endclass : APB_Env

`endif

