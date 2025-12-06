// minicpu_reg_bank.sv

// YOU DO NOT NEED TO MODIFY THIS FILE

// Maps correctly to Spartan-2 RAM16X1D elements.  
// Note this means we can't have reset, so the CPU itself must implement reset.


module miniCPU_reg_bank (
  input  logic        clock,
  input  logic [2:0]  adrsWr,
  input  logic [2:0]  adrsRd, 
  input  logic [15:0] dataWr,
  output logic [15:0] dataRd,
  input  logic        WrEna
);

  logic [15:0] mem [0:7];

  // write
  always @(posedge clock)
    if (WrEna) mem[adrsWr] <= dataWr;

  // read
  assign dataRd = mem[adrsRd];

endmodule : miniCPU_reg_bank

