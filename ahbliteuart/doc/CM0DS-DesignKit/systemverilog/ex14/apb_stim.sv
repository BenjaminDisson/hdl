// apb_stim.sv

// YOU NEED TO COMPLETE THIS FILE -
// see comments containing "TO DO:"

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

// TO DO: In this lab you need to complete the class definitions,
// and write a very simple test program to exercise them.


package APB_pkg;

  typedef enum bit {dir_Rd, dir_Wr} T_dir;
  typedef logic [15:0] T_data;
  typedef logic [15:0] T_addr;

  // TO DO: Forward type definition so that we can reference the
  // stream class from within the transaction class, and vice versa
  typedef class APB_Trans;
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
    // TO DO: Declaration of data members.  Members representing
    // physical attributes of the transaction (data, address etc)
    // are declared rand to allow for randomisation.  Also provide a
    // static variable for use in creating the next sequence number.
    //
    rand T_addr addr;
    rand T_data data;
    rand T_dir dir;
    const int ID;
    static int next_ID;

    //const APB_Stream owner;

    // TO DO: Constructor function.  The constructor should take an
    // optional argument that is a reference to the creating stream.
    // The constructor must allocate the next sequence number and
    // copy it into the sequence number (ID) of the new object.
    //
    function new();
      next_ID++;
      ID = next_ID;

    endfunction : new

    // TO DO: Copy method to create a completely new
    // transaction object (with its own new sequence number)
    // having the same data values, and the same creator stream,
    // as the current object.  Return a reference to the newly
    // copied object.
    //
    function APB_Trans copy();
      copy = new this;
    endfunction : copy

    // TO DO: Comparison method, returns a boolean (bit) result
    // of TRUE (1'b1) if its argument object has identical
    // contents to the current object, FALSE (1'b0) if not.
    // Only the physical data memebrs (address, data, direction)
    // should be compared; other data members should be ignored.
    //
    function bit compare(APB_Trans other);
      return (other.addr == this.addr && other.data == this.data && other.dir == this.dir) ? 1'b1 : 1'b0;
    endfunction : compare

    // TO DO: String representation method, returns a string
    // that is a human-readable representation of the transaction
    // including its sequence number, direction and data.  This
    // method DOES NOT display the string on the console - it
    // simply returns a string result that can then be displayed,
    // logged to a file etc.
    //
    function string psprint();
       $sformat(psprint,"ID = %h, addr = %h, data = %h, dir = %b",ID,addr,data,dir);
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

    // TO DO: Data members of the class: a human-readable name string
    // that is assigned once and for all by the constructor, and a
    // queue variable containing a log of all transactions that have
    // ever been created by this stream.
    //
    string name;
    APB_Trans my_queue_of_APB_Trans[$];
    APB_Trans my_APB_Trans_obj;

    // TO DO: get_trans() method that can be called to produce a
    // new, randomly-generated transaction object.  Returns a
    // reference to the newly created object.  An optional argument
    // to this method (defaulted to zero) chooses whether the newly
    // created transaction object should be displayed on the console.
    // The method also needs to add the newly created transaction
    // to the history queue.
    //
    function APB_Trans get_trans(bit print = 1'b0);
      my_APB_Trans_obj = new;
      assert(my_APB_Trans_obj.randomize());

      if (print == 1'b1)
        $display("%s",my_APB_Trans_obj.psprint());

      return my_APB_Trans_obj;
    endfunction : get_trans

    // TO DO: Constructor function, takes a name string and assigns
    // it to the name field of the newly created stream object.
    //
    function new(string name = "<anon>");

      this.name = name;
    endfunction : new
    //
  endclass : APB_Stream

endpackage : APB_pkg


// TO DO: Top-level module that instantiates one (or more?)
// stream objects and uses it to create a stream of transactions.
// Display each transaction as it is generated.  When finished,
// display every transaction in the history log that's stored in
// the stream object.
//
module APB_top;

  import APB_pkg::*;

  // TO DO: Stream object created here
  //

  // TO DO: Variable(s) to hold created object(s)
  //
  APB_Stream my_queue_of_APB_Trans[$];
  APB_Stream current;


  initial
  begin

    // TO DO: Get the stream object to create 10 transactions,
    // displaying each one as it is generated

    repeat (10)
    begin
      current = new("Stream n°");
      //current.get_trans(1'b1);
      my_queue_of_APB_Trans.push_back(current);
    end

    // TO DO: Display every transaction in the history log
    //
    $display("HISTORY------------------");
    for (int i=0 ;i<10;i++)
      $display("%p",my_queue_of_APB_Trans[i].get_trans(1'b1));


      $display("%d",my_queue_of_APB_Trans.size);

    // TO DO: If You Have Time:  Test the copy and compare methods
    //
    //...

  end

endmodule : APB_top
