// apb_mem.sv

// YOU DO NOT NEED TO MODIFY THIS FILE	

// Synchronous memory model with APB slave interface.
// Paramterised address and data size.
// Parameterised depth, can be overridden to 
// reduce simulation resources.
//
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
  // APB interface
  input		logic PCLK,
  input		logic [APB_ADDR_WIDTH-1:0] PADDR,
  input		logic [APB_DATA_WIDTH-1:0] PWDATA,
  input		logic PWRITE,
  input		logic PENABLE,
  input		logic PSEL,
  output	logic [APB_DATA_WIDTH-1:0] PRDATA
);

  timeunit 1ns;
  timeprecision 1ns;


  localparam Depth = 2 ** APB_ADDR_WIDTH;  // Number of memory elements

  // Memory array
  logic [APB_DATA_WIDTH-1:0] mem [0:Depth-1];

  always @(posedge PCLK)
  begin
    // Read new data at end of first cycle of a read
    if (PSEL && !PENABLE && !PWRITE)
      PRDATA <= #Tco mem[PADDR];

    // Write data at end of second cycle of a write
    if (PSEL && PENABLE && PWRITE)
      mem[PADDR] = PWDATA;
  end

endmodule: APB_mem
