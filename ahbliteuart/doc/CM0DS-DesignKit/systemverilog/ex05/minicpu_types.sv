// minicpu_types.sv

// YOU DO NOT NEED TO MODIFY THIS FILE

package miniCPU_types;

  // Data and address types - 16-bit unsigned
  typedef logic [15:0] T_word;

  // Register-file address
  typedef logic [2:0] T_reg_a;

  // CONDITION CODES
  //
  typedef enum logic [2:0] {
    ccV=3'b000, ccZ, ccC, ccB, ccNV, ccNZ, ccNC, ccU
  } T_Cond;

  // ALU OPERATION CODES
  //
  typedef enum logic [2:0] {
    opADD,
    opAND,
    opOR,
    opXOR,
    opLSRA,
    opASRA,
    opLSLA,
    opBSWA
  } T_ALU_Ops;


  typedef struct packed{
    logic   flag;
    logic   invA;
    logic   [1:0]carryInControl;
    logic   [2:0]target;
    logic   [2:0]OpA;
    logic   [2:0]OpB;
    logic   [2:0]OpCode;
  } Operate_t;

  typedef struct packed{
    logic   [3:0]flag;
    logic   [2:0]target;
    logic   [8:0]constant ;
  } LoadConstant_t;

  typedef struct packed{
    logic   [3:0]flag;
    logic   [2:0]target;
    logic   [2:0]srcAdrReg;
    logic   [5:0]offset;
  } LoadFromMemory_t;

  typedef struct packed{
    logic   [3:0]flag;
    logic   [2:0]source;
    logic   [2:0]tarAdrReg;
    logic   [5:0]offset;
  } StoreFromMemory_t;

  typedef struct packed{
    logic   [3:0]flag;
    logic   [2:0]conditionSource;
    logic   [2:0]srcReg;
    logic   [5:0]offset;
  } ConditionnalBranch_t;

  typedef union packed {
    Operate_t             Operate;
    LoadConstant_t        LoadConstant;
    LoadFromMemory_t      LoadFromMemory;
    StoreFromMemory_t     StoreFromMemory;
    ConditionnalBranch_t  ConditionnalBranch;
  } IR_t;

endpackage
