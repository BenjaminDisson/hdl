// apb_mem.sv

// Synchronous memory model with APB slave interface.
// Paramterised address and data size.
// Parameterised depth, can be overridden to
// reduce simulation resources.
//
// Typically, the test fixture will use hierarchical name
// access to the memory array "mem" and fill it with a suitable
// instruction stream (program) at startup.


module APB_mem #(
    parameter APB_ADDR_WIDTH = 8,   // Width of address bus
    parameter APB_DATA_WIDTH = 32,  // Width of data bus
    parameter Tco = 1               // Clock to output delay on PRDATA
)
(
  // TO DO - replace ports with APB interface modport
  // (remember to add modport references where bus is accessed in the tasks)
APB.slave_mp iport
);

  timeunit 1ns;
  timeprecision 1ns;
  import APB_trans_pkg::*;
  localparam Depth = 2 ** APB_ADDR_WIDTH;  // Number of memory elements

  // Memory array
  logic [APB_DATA_WIDTH-1:0] mem [0:Depth-1];

  always @(posedge iport.PCLK)
  begin

    // Read new data at end of first cycle of a read
    //
    if (iport.PSEL && !iport.PENABLE && !iport.PWRITE)
      iport.PRDATA <= #Tco mem[iport.PADDR];

    // Write data at end of second cycle of a write
    //
    if (iport.PSEL && iport.PENABLE && iport.PWRITE)
      mem[iport.PADDR] = iport.PWDATA;

  end

endmodule: APB_mem
