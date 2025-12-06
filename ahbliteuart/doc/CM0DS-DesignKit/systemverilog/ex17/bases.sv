// bases.sv

// YOU DO NOT NEED TO MODIFY THIS FILE

`ifndef BASES__SV
`define BASES__SV


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//
// Transaction - base class for all transaction data classes

class Transaction;

  static int next_ID;
  const int  ID;

  // psprint() - return human-readable string representation
  //
  virtual function string psprint();
    return $sformatf("BASE CLASS TRANSACTION OBJECT, id=%0d", ID);
  endfunction

  // copy() - return a clone of the current object
  //
  virtual function Transaction copy();
    copy = new this;
  endfunction

  // compare() - compare this object with another of the same class
  //
  virtual function bit compare(Transaction other);
    return this.ID == other.ID;
  endfunction

  function new();
    ID = next_ID++;
  endfunction : new

endclass : Transaction

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//
// Channel - FIFO channel that components can use to communicate.
// Passes objects of Transaction (base class) type, therefore
// can also pass objects of any derived class.

class Channel #(type Tr = Transaction);

  // PUBLIC METHODS - This is how you use the channel:

  // Constructor: bound=0 for unbounded, bound=1 for single-place FIFO, etc
  extern function     new(int _bound = 0);

  // Push data onto the FIFO:
  // ~~~~~~~~~~~~~~~~~~~~~~~~
  // put: block until space free, then push the data
  extern task         put(Tr t);
  // try_put: if no free space, return 0 immediately;
  //          if some free space, push data and return 1 immediately
  extern function bit try_put(Tr t);

  // Pop data off the FIFO:
  // ~~~~~~~~~~~~~~~~~~~~~~
  // get: block until data available, then pop the data into (t)
  extern task         get(output Tr t);
  // try_get: if no data, return 0 immediately;
  //          if data available, pop data into (t) and return 1
  extern function bit try_get(output Tr t);

  // Peek: like get, but leave the data on the FIFO (don't pop)
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // peek: block until data available, then return data in (t)
  extern task         peek(output Tr t);
  // try_peek: if no data, return 0 immediately;
  //           if data available, pass data in (t) and return 1
  extern function bit try_peek(output Tr t);

  // PRIVATE DATA MEMBERS AND METHODS OF THE CHANNEL CLASS
  // Users cannot touch these

  local Tr fifo[$];
  local event e_get, e_put;
  local int bound;

  extern local function        Tr pop();
  extern local function        void push(Tr t);
  extern local function         bit empty();
  extern local function         bit full();
  extern local task                 await_not_full();
  extern local task                 await_not_empty();

endclass : Channel

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
// IMPLEMENTATIONS
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function Channel::Tr Channel::pop();
  -> e_get;
  return fifo.pop_front();
endfunction : pop

function void Channel::push(Tr t);
  fifo.push_back(t);
  -> e_put;
endfunction : push

function bit Channel::empty();
  return (fifo.size() == 0);
endfunction : empty

function bit Channel::full();
  return (bound && (fifo.size() >= bound));
endfunction : full

task Channel::await_not_empty();
  while (empty()) @e_put;
endtask : await_not_empty

task Channel::await_not_full();
  while (full()) @e_get;
endtask : await_not_full

function Channel::new(int _bound = 0);
  bound = _bound;
endfunction : new

task Channel::put(Tr t);
  await_not_full();
  push(t);
endtask : put

task Channel::get(output Tr t);
  await_not_empty();
  t = pop();
endtask : get

function bit Channel::try_get(output Tr t);
  if (empty()) return 0;
  t = pop();
  return 1;
endfunction : try_get

function bit Channel::try_put(Tr t);
  if (full()) return 0;
  push(t);
  return 1;
endfunction : try_put

task Channel::peek(output Tr t);
  await_not_empty();
  t = fifo[0];
endtask : peek

function bit Channel::try_peek(output Tr t);
  if (empty()) return 0;
  t = fifo[0];
  return 1;
endfunction : try_peek

`endif
