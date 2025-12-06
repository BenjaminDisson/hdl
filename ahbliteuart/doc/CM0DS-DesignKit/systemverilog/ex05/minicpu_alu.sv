// minicpu_alu.sv

// YOU DO NOT NEED TO MODIFY THIS FILE

module miniCPU_alu (

    // Operands
    input  logic [15:0] opA,
    input  logic [15:0] opB,

    // Operation code
    input  miniCPU_types::T_ALU_Ops  Op,

    // Carry/borrow/increment input
    input  logic        cIn,

    // Ones-complement the A operand?
    input  logic        invA,

    // Result and condition code outputs
    output logic [15:0] result,
    output logic        cOut,
    output logic        overflow,
    output logic        zero
  );

  import miniCPU_types::*;

  // Invert the A operand if (invA) is set
  logic [15:0] A;
  assign A = invA ? ~opA : opA;

  // Main ALU logic
  //
  always_comb
  begin
    case (Op)
      opADD:
        {cOut, result} = cIn + A + opB;
      opAND:
        {cOut, result} = {1'b0, A & opB};
      opOR:
        {cOut, result} = {1'b0, A | opB};
      opXOR:
        {cOut, result} = {1'b0, A ^ opB};
      opLSRA:
        {cOut, result} = {A[0], cIn, A[15:1]};
      opASRA:
        {cOut, result} = {A[0], A[15], A[15:1]};
      opLSLA:
        {cOut, result} = {A[15:0], cIn};
      opBSWA:
        {cOut, result} = {1'b0, A[7:0], A[15:8]};
      default:
        {cOut, result} = 17'bx;
    endcase

    // Arithmetic overflow occurs if both operands' MSBs are
    // the same, but the result MSB is different.  Note this
    // is relevant only for ADD operations, junk otherwise.
    //
    overflow = (A[15] == opB[15]) && (A[15] != result[15]);
  end

  // Zero test
  assign zero = (result == 16'b0);

endmodule : miniCPU_alu
