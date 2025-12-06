// constants.sv

package constants;

  timeunit 1ns;
  timeprecision 1ns;

  parameter ww = 16;
  parameter iw =  4;
  parameter rw =  4;

  parameter rom_aw = 8;
  parameter ram_aw = 12;

  parameter init_store = 1'b0; // initial sim value of register file and sram

  // Instruction format oooo111122223333
  // oooo = opcode
  // 1111 = src
  // 2222 = src2
  // 3333 = dst

  parameter n_reg = (1 << rw);
  parameter nop_op   = 4'b0000; //nop
  parameter load_op  = 4'b0001; //load  M(R(src))           R(dst)
  parameter store_op = 4'b0010; //store R(src)              M(R(dst))
  parameter move_op  = 4'b0011; //move  R(src)              R(dst)
  parameter movi_op  = 4'b0100; //movi  src[7:0]            R(dst)[15:0]
  parameter movhi_op = 4'b0101; //movhi src[7:0]            R(dst)[15:8]

  parameter add_op   = 4'b0110; //add   R(src)    R(src2)   R(dst)
  parameter addi_op  = 4'b0111; //addi  R(src)    src2      R(dst)
  parameter sub_op   = 4'b1000; //sub   R(src)    R(src2)   R(dst)
  parameter subi_op  = 4'b1001; //subi  R(src)    src2      R(dst)
  parameter mul_op   = 4'b1010; //mul   R(src)    R(src2)   R(dst)
  parameter and_op   = 4'b1011; //and   R(src)    R(src2)   R(dst)
  parameter or_op    = 4'b1100; //or    R(src)    R(src2)   R(dst)

  parameter jump_op  = 4'b1101; //jump                      R(dst)
  parameter jzero_op = 4'b1110; //jzero R(src)              R(dst)
  parameter jneg_op  = 4'b1111; //jneg  R(src)              R(dst)

  // load_direct addr,dst == movei addr_low,r; movehi addr_high,r; load r,dst

endpackage
