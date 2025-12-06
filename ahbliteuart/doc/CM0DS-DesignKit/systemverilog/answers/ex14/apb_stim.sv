// apb_stim.sv

// ANSWER

// Class and related definitions for building stimulus
// generator for APB.
//
// This file contains one package APB_pkg containing the
// following definitions:
//
// - some useful typedefs
// - a class 'APB_Trans' representing a single
//   bus transaction on the APB bus
// - a class 'APB_Stream' representing a generator
//   of APB_Trans objects


package APB_pkg;

  typedef enum bit {dir_Rd, dir_Wr} T_dir;
  typedef logic [15:0] T_data;
  typedef logic [15:0] T_addr;

  // ANSWER: Forward type definition so that we can reference the
  // stream class from within the transaction class, and vice versa
  typedef class APB_Stream;

  //_____________________________________________ class APB_Trans ___
  //
  // Class to represent the transaction associated with one data
  // transfer on the APB.  It contains the address and data values,
  // and transfer direction (read or write) - these values will
  // really appear on the physical bus - and some auxiliary information
  // for use only in the testbench: an identifying sequence number,
  // and a reference to the stream generator object that created it.
  //
  class APB_Trans;
    //
    // ANSWER: Declaration of data members.  Members representing
    // physical attributes of the transaction (data, address etc)
    // are declared rand to allow for randomisation.  Also provide a
    // static variable for use in creating the next sequence number.
    //
    static int       next_ID;
    const int        ID;
    const APB_Stream owner;
    rand  T_dir      dir;
    rand  T_addr     addr;
    rand  T_data     data;

    // ANSWER: Constructor function.  The constructor should take an
    // optional argument that is a reference to the creating stream.
    // The constructor must allocate the next sequence number and
    // copy it into the sequence number (ID) of the new object.
    //
    function new(APB_Stream owner = null);
      this.owner = owner;
      ID = next_ID++;
    endfunction : new

    // ANSWER: Copy method to create a completely new
    // transaction object (with its own new sequence number)
    // having the same data values, and the same creator stream,
    // as the current object.  Return a reference to the newly
    // copied object.
    //
    function APB_Trans copy();
      APB_Trans clone;
      clone = new(owner);
      clone.dir  = dir;
      clone.addr = addr;
      clone.data = data;
      return clone;
    endfunction : copy

    // ANSWER: Comparison method, returns a boolean (bit) result
    // of TRUE (1'b1) if its argument object has identical
    // contents to the current object, FALSE (1'b0) if not.
    // Only the physical data memebrs (address, data, direction)
    // should be compared; other data members should be ignored.
    //
    function bit compare(APB_Trans other);
      if (other.dir  !== dir ) return 1'b0;
      if (other.addr !== addr) return 1'b0;
      if (other.data !== data) return 1'b0;
      return 1'b1;
    endfunction : compare

    // ANSWER: String representation method, returns a string
    // that is a human-readable representation of the transaction
    // including its sequence number, direction and data.  This
    // method DOES NOT display the string on the console - it
    // simply returns a string result that can then be displayed,
    // logged to a file etc.
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
  // Class to represent a generator of APB_Trans objects.  The stream
  // has a human-readable name string that can be set by its constructor.
  // It also keeps a record (in a queue variable) of all the objects it
  // has ever created.  Generation is performed by calling a method
  // get_trans() which returns a reference to the newly-created object.
  // The newly created transaction object should reference this stream
  // object as its "owner".
  //
  class APB_Stream;

    // ANSWER: Data members of the class: a human-readable name string
    // that is assigned once and for all by the constructor, and a
    // queue variable containing a log of all transactions that have
    // ever been created by this stream.
    //
    string name;
    APB_Trans history[$];

    // ANSWER: get_trans() method that can be called to produce a
    // new, randomly-generated transaction object.  Returns a
    // reference to the newly created object.  An optional argument
    // to this method (defaulted to zero) chooses whether the newly
    // created transaction object should be displayed on the console.
    // The method also needs to add the newly created transaction
    // to the history queue.
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

    // ANSWER: Constructor function, takes a name string and assigns
    // it to the name field of the newly created stream object.
    //
    function new(string name = "<anon>");
      this.name = name;
    endfunction : new
    //
  endclass : APB_Stream

endpackage : APB_pkg


// ANSWER: Top-level module that instantiates one (or more?)
// stream objects and uses it to create a stream of transactions.
// Display each transaction as it is generated.  When finished,
// display every transaction in the history log that's stored in
// the stream object.
//
module APB_top;

  import APB_pkg::*;

  // ANSWER: Stream object created here
  //
  APB_Stream gen = new("Test Generator");

  // ANSWER: Variable(s) to hold created object(s)
  //
  APB_Trans t, t1, t2;

  initial 
  begin

    // ANSWER: Get the stream object to create 10 transactions,
    // displaying each one as it is generated
    //
    repeat (10)
      t = gen.get_trans(1);

    // ANSWER: Display every transaction in the history log
    //
    $display("HISTORY------------------");
    for (int i = 0; i < gen.history.size(); i++)
      $display( "[%0d]: %s", i, gen.history[i].psprint() );

    // ANSWER: If You Have Time:  Test the copy and compare methods
    //
    $display("Testing copy and compare methods:");
    t = gen.get_trans();
    t1 = t.copy();         // this one should be the same
    t2 = gen.get_trans();  // this one should be different
    $display("transaction t  : %s", t.psprint() );
    $display("t1 (copy of t) : %s", t1.psprint() );
    $display("transaction t2 : %s", t2.psprint() );
    $display("t.compare(t1) expected 1'b1, actual 1'b%b", t.compare(t1));
    $display("t1.compare(t) expected 1'b1, actual 1'b%b", t1.compare(t));
    $display("t.compare(t2) expected 1'b0, actual 1'b%b", t.compare(t2));
    $display("t1.compare(t2) expected 1'b0, actual 1'b%b", t1.compare(t2));

  end

endmodule : APB_top

