// bases.sv

// YOU DO NOT NEED TO MODIFY THIS FILE

`ifndef BASES__SV
`define BASES__SV

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
// This file defines three classes.

// Component is the virtual base class for all testbench components.

// Transaction is the virtual base class for all transaction data objects.

// Channel is a parameterised, concrete FIFO channel class.
// It is not strictly a base class, since there is no need to extend it,
// but it is in this file for convenience.

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//

virtual class Component;

  extern       function           new (string _instance_name, Component _parent);
  pure virtual task               body(); 
  extern       function    string get_name();
  extern       function Component get_parent();
  extern       function    string get_hier_name();
  extern       task               run();

  local     string    instance_name;
  local     Component parent;
  protected Component children[$];

endclass : Component

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
// Transaction - base class for all transaction data classes

virtual class Transaction;

  extern       function             new(Component owner = null);
  pure virtual function      string psprint();                  
  pure virtual function Transaction copy();                     
  pure virtual function         bit compare(Transaction other); 

  virtual function void sample_cov();
    // this function intentionally does nothing, but can be overridden
    int dummy;
  endfunction

  local static int       next_ID;
  protected    int       ID;
  protected    Component owner;

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

  extern local function   Tr pop();
  extern local function void push(Tr t);
  extern local function  bit empty();
  extern local function  bit full();
  extern local task          await_not_full();
  extern local task          await_not_empty();

endclass : Channel

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//                    METHOD IMPLEMENTATIONS                   //
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function Transaction::new(Component owner = null);
  this.owner = owner;
  ID = next_ID++;
endfunction : new

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function string Component::get_name();
  return instance_name;
endfunction : get_name

function Component Component::get_parent();
  return parent;
endfunction : get_parent

function string Component::get_hier_name();
  if (parent == null)
    return instance_name;
  else
    return {parent.get_hier_name(), ".", instance_name};
endfunction : get_hier_name

task Component::run();

  // Launch all my children, if any (they will in turn do likewise)
  //
  foreach (children[i])
    children[i].run();

  // Launch my own body() method
  //
  fork
    body();
  join_none
  $display("component %s body() task launched", get_hier_name() );

  // If I'm a top-level instance, I know that all body() methods
  // have started - so it's appropriate to wait for them to finish
  //
  if (parent == null)  // This is a top-level instance.
    wait fork;
  // NOTE: Because of some tool limitations, this use of "wait fork"
  //       must NOT be inside a begin...end block of any kind.

endtask : run

function Component::new (string _instance_name, Component _parent);
  instance_name = _instance_name;
  parent = _parent;
  if (parent != null)
    // This is not a top-level component.
    //  Add it to its parent's list of children.
    parent.children.push_back(this);
  $display("Constructed %s", get_hier_name());
endfunction : new

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
