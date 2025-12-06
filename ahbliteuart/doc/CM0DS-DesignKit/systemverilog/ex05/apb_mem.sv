// apb_mem.sv

// YOU DO NOT NEED TO MODIFY THIS FILE

module APB_mem (
  // APB interface
    input  logic                  PCLK,
    input  miniCPU_types::T_word  PADDR,
    input  miniCPU_types::T_word  PWDATA,
    input  logic                  PWRITE,
    input  logic                  PENABLE,
    input  logic                  PSEL,
    output miniCPU_types::T_word  PRDATA
  );

  import miniCPU_types::*;

  localparam Abits = $bits(PADDR);  // Width of address bus
  localparam Dbits = $bits(PWDATA); // Width of data bus
    
  parameter Depth = 2 ** Abits;     // Number of memory elements
  parameter Tco = 1;                // Clock to output delay on PRDATA
    
  // Memory array
  logic [Dbits-1:0] mem [0:Depth-1];

  // always_ff is not being used because in one simulator this prevents 
  // the use of $readmemb to initialize the memory
  always @(posedge PCLK)
  begin

    // Read new data at end of first cycle of a read
    //
    if (PSEL && !PENABLE && !PWRITE)
      PRDATA <= #Tco mem[PADDR];

    // Write data at end of second cycle of a write
    //
    if (PSEL && PENABLE && PWRITE)
      mem[PADDR] = PWDATA;

  end

endmodule : APB_mem
