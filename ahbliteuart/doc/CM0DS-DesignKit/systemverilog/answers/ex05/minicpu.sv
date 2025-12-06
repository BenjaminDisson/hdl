// minicpu.sv

// ANSWER for miniCPU Packed Structs exercise


// Instruction register is now a union of packed structs,
// with resulting changes to various parts of the code

module miniCPU (
    input  logic                  reset,
    input  logic                  PCLK,
    output miniCPU_types::T_word  PADDR,
    output miniCPU_types::T_word  PWDATA,
    output logic                  PWRITE,
    output logic                  PENABLE,
    output logic                  PSEL,
    input  miniCPU_types::T_word  PRDATA,
    output logic                  halted,
    output logic                  fetch,
    output logic                  branch
  );

  import miniCPU_types::*;

  // _________________________________________________ INSTRUCTION BUFFER ___
  //
  // Holds instruction word from each fetch, ready to be decoded

  // ANSWER:

  // OPERATE instruction
  //
  typedef struct packed {
    logic [15:15] Ocode;       // constant 0
    logic [14:14] InvA;        // invert operand A before ALU
    logic [13:13] UseCarryIn;  // ) carry-in
    logic [12:12] InvCarry;    // )   control
    T_reg_a       Tgt;         // target register number [11:9]
    T_reg_a       OpA;         // operand A register number [8:6]
    T_reg_a       OpB;         // operand B register number [5:3]
    T_ALU_Ops     Subcode;     // ALU operation
  } T_instr_OPR;

  // LOAD CONSTANT instruction
  //
  typedef struct packed {
    logic [15:12] Opcode;      // constant 4'b1100
    T_reg_a       Tgt;         // target register number
    logic signed [ 8: 0] N;    // signed 9-bit constant
  } T_instr_LDC;

  // LOAD FROM MEMORY instruction
  //
  typedef struct packed {
    logic [15:12] Opcode;      // constant 4'b1101
    T_reg_a       Tgt;         // target address register number
    T_reg_a       Src;         // source (mem) address register number
    logic signed [ 5: 0] Ofs;  // signed 6-bit address offset
  } T_instr_LDM;

  // STORE TO MEMORY instruction
  //
  typedef struct packed {
    logic [15:12] Opcode;      // constant 4'b1110
    T_reg_a       Src;         // source address register number
    T_reg_a       Tgt;         // target address register number
    logic signed [ 5: 0] Ofs;  // signed 6-bit address offset
  } T_instr_STM;

  // CONDITIONAL BRANCH instruction
  //
  typedef struct packed {
    logic [15:12] Opcode;      // constant 4'b1111
    T_Cond        Cond;        // condition code
    T_reg_a       Src;         // jump target address register number
    logic signed [ 5: 0] Ofs;  // signed 6-bit address offset
  } T_instr_JMP;


  // Union for instruction buffer etc
  //
  typedef union packed {
    T_instr_OPR  OPR;
    T_instr_LDC  LDC;
    T_instr_LDM  LDM;
    T_instr_STM  STM;
    T_instr_JMP  JMP;
  } T_instr;

  T_instr IR;


  // __________________________________________________________ SHADOW PC ___
  //
  // Keeps a local copy of contents of register 7 (PC).
  // This makes it a bit easier to generate addresses for fetch cycles.
  //
  T_word  shadowPC;


  // ________________________________________________ ALU CONDITION CODES ___
  //
  // These registers capture the ALU condition code outputs at the moment
  // when any OPERATE instruction writes its result to the register file.
  // These flags are updated even if the target register is r0.
  //
  logic carry, overflow, zero;


  // __________________________________________________ CPU STATE MACHINE ___
  //
  parameter
    state_width = 4,
    init       = 0,
    fetch0     = 1,
    fetch1     = 2,
    decode     = 3,
    load0      = 4,
    load1      = 5,
    store0     = 6,
    store1     = 7,
    exec       = 8,
    halt       = 9,
    initZ      = 10;
  //
  logic [state_width-1:0] state;



  // _______________________________________________________ ALU DATAPATH ___
  //
  // ALU DATAPATH SIGNALS
  //
  // ALUout - output data from ALU
  T_word  ALUout;
  //
  // Condition code outputs from ALU
  logic ALUoverflow, ALUcarry, ALUzero;
  //
  //
  // ALU OPERAND INPUTS
  //
  // opA, opB: operands are always taken from register bank
  T_word  opA, opB;
  //
  // cIn: carry input, derived from carry flag, or constant in IR
  logic cIn;
  assign cIn = IR.OPR.UseCarryIn ? (carry ^ IR.OPR.InvCarry) : IR.OPR.InvCarry;


  // _________________________________ REGISTER FILE DATAPATH AND CONTROL ___
  //
  // Flag set to write to a register on this clock...
  logic WrReg;
  //
  // Register bank write address and data,
  // determined by the instruction
  T_reg_a regWrAdrs;
  T_word  regWrData;
  //
  // Register bank outputs (read ports):
  T_word  RdA, RdB;
  //
  // Register bank read addresses:
  T_reg_a adrsRdA, adrsRdB;
  //
  // PC update control, used to maintain shadowPC register
  // and for PC forwarding to fetch address
  logic updatePC;
  //
  // Writeable register indicator is simply a decode off the register
  // write address regWrAdrs asserted when the address is not zero.
  // This signal is used to prevent modification of r0 after startup.
  logic WriteableReg;


  // ___________________________________________ ADDRESS CALCULATION UNIT ___
  //
  // Several instructions generate an address using a register's contents
  // added to a signed 6-bit offset.  This calculation is performed by the
  // address calculation unit, independently of the ALU.
  T_word  offsetAdrs;
  assign offsetAdrs = $signed(RdA) + $signed(IR.LDM.Ofs);


  // _______________________________________________________ ALU INSTANCE ___
  //
  
  miniCPU_alu alu (
      .Op(IR.OPR.Subcode),
      .invA(IR.OPR.InvA),
      .result(ALUout),
      .cOut(ALUcarry),
      .overflow(ALUoverflow),
      .zero(ALUzero),
      .*
    );


  // ____________________________________________ REGISTER BANK INSTANCES ___
  //
  // Two completely independent register banks are kept in step by
  // giving them identical write address, data and enable.  They have
  // independent read ports, hence providing a 3-port register file.

  miniCPU_reg_bank reg_bankA (
      .clock (PCLK),
      .adrsWr(regWrAdrs),
      .adrsRd(adrsRdA),
      .dataWr(regWrData),
      .dataRd(RdA),
      .WrEna (WrReg)
    );

  miniCPU_reg_bank reg_bankB (
      .clock (PCLK),
      .adrsWr(regWrAdrs),
      .adrsRd(adrsRdB),
      .dataWr(regWrData),
      .dataRd(RdB),
      .WrEna (WrReg)
    );


  // ________________________________________________ BRANCH CONDITIONALS ___
  //
  // This block of combinational logic is used only during
  // conditional branch instructions, when the ALU status flags
  // are checked against a condition code in the instruction word.

  logic ConditionalsOK;
  //
  always_comb 
  begin
    case (IR.JMP.Cond)
      ccV:   // If overflow
        ConditionalsOK = overflow;
      ccZ:   // If zero
        ConditionalsOK = zero;
      ccC:   // If carry
        ConditionalsOK = carry;
      ccB:   // unsigned borrow
        ConditionalsOK = ~carry && ~overflow;
      ccNV:  // Not overflow
        ConditionalsOK = ~overflow;
      ccNZ:  // Non-zero
        ConditionalsOK = ~zero;
      ccNC:  // No carry
        ConditionalsOK = ~carry;
      ccU:   // Unconditionally true
        ConditionalsOK = 1;
      default:
        ConditionalsOK = 1'bx;
    endcase
  end

  // ______________________________________________________ DEBUG OUTPUTS ___
  //
  // Fetch indicator output (probably just for debug, but could
  // be used to select between address spaces)
  assign fetch = (state == fetch0) || (state == fetch1);
  //
  // Halt indication
  assign halted = (state == halt);
  //
  // Branch indication, only for debug, has #1 inertial delay to de-glitch
  assign #1 branch = updatePC && (state == decode);


  // ____________________________________________ REGISTER READ ADDRESSES ___
  //
  assign adrsRdA = IR.OPR.OpA;
  assign adrsRdB = (IR[15:12] == 4'b1110) ? IR.STM.Src : IR.OPR.OpB;  // store


  // _____________________________________________________ REGISTER WRITE ___
  //
  // Destination is always r[7] (PC) for branches, otherwise
  // specified by destination field of IR
  //
  assign regWrAdrs = (IR[15:12] == 4'b1111) ? 3'b111 : IR.OPR.Tgt;
  assign updatePC = WrReg && (regWrAdrs == 3'b111);


  // Selection of write data source
  //
  always_comb 
  begin

    // Data to be written is determined by instruction opcode
    casez (IR[15:12])
      4'b0???: // OPERATE: get data from ALU output
        regWrData = ALUout;
      4'b1100: // LOAD CONSTANT: data constructed from IR contents
        regWrData = IR.LDC.N;
      4'b1101: // LOAD FROM MEM: data direct from memory
        regWrData = PRDATA;
      4'b1111: // CONDITIONAL BRANCH: data from address calculation unit
        regWrData = offsetAdrs;
      default:
        regWrData = 16'bx;
    endcase
  end

  // WrReg: determines when to write to registers.
  // Asserted during the state when register write data is being calculated.

  assign WriteableReg = (regWrAdrs != 0);
  
  always_comb 
  begin
    WrReg = 0;
    case (state)
      initZ:
        WrReg = 1;
      decode:     // Only if it's a LOAD CONSTANT or successful CONDBRANCH
        case (IR[15:12])
          4'b1100:  // LOAD CONSTANT
            WrReg = WriteableReg;
          4'b1111:  // CONDBRANCH
            if (ConditionalsOK)
              WrReg = WriteableReg;
        endcase
      fetch1,     // Incrementing the PC
      load1,      // Load reg from memory
      exec:       // OPERATE
        WrReg = WriteableReg;
    endcase
  end


  // __________________________________________________________ SHADOW PC ___
  //
  always_ff @(posedge PCLK)
    if (updatePC)
      shadowPC <= regWrData;


  // __________________________________________________ CPU CONTROL LOGIC ___
  //
  always_ff @(posedge PCLK or posedge reset)

    if (reset) 
    begin
      IR <= 0;
      PSEL <= 0;
      PENABLE <= 0;
      PWRITE <= 0;
      PADDR <= 0;
      PWDATA <= 0;
      state <= init;
      opA <= 0;
      opB <= 0;
      carry <= 0;
      overflow <= 0;
      zero <= 0;
    end 
    else 
    begin
      // Default action to clear down controls
      PSEL <= 0;
      PENABLE <= 0;
      PWRITE <= 0;

      case (state)

        init:
          begin
            // ANSWER:
            IR.LDC <= '{Opcode: 4'b1100, Tgt: 3'd0, N: 9'b0};  // Loads 0 to r0
            state <= initZ;
          end

        initZ:
          begin
            // ANSWER:
            IR.LDC <= '{Opcode: 4'b1100, Tgt: 3'd7, N: 9'b0};  // Loads 0 to r7
            state <= decode;               // Jumps to 0
          end

        fetch0:
          begin
            // Go unconditionally to fetch1
            state <= fetch1;
            // in fetch1, run 2nd phase of APB read cycle
            PENABLE <= 1;
            PSEL <= 1;
            // Use address calculation unit to increment the PC
            // by faking a "branch to r7+1" instruction during fetch1
            // ANSWER:
            IR.JMP <= '{Opcode: 4'b1111, Cond: ccU, Src: 3'd7, Ofs: 6'd1};
          end

        fetch1:
          begin
            // Go unconditionally to decode
            state <= decode;
            // At start of decode, capture bus data to IR
            IR <= PRDATA;
          end

        decode:
          begin
            casez (IR[15:12])
              4'b0???: // OPERATE
                begin
                  // go into Writeback (exec) state
                  state <= exec;
                  // capture ALU inputs to op registers
                  opA <= RdA;
                  opB <= RdB;
                end
              4'b1100: // LOAD CONSTANT
                begin
                  // go to fetch0 state
                  startFetch;
                end
              4'b1101: // LOAD FROM MEM
                begin
                  PSEL <= 1;
                  PADDR <= offsetAdrs;
                  state <= load0;
                end
              4'b1110: // STORE TO MEM
                begin
                  PWRITE <= 1;
                  PSEL <= 1;
                  PADDR <= offsetAdrs;
                  state <= store0;
                  PWDATA <= RdB;
                end
              4'b1111: // CONDITIONAL BRANCH
                begin
                  // Take the branch if condition flags match
                  startFetch;
                end
              default:
                state <= halt;
            endcase
          end

        exec:
          begin
            carry    <= ALUcarry;
            overflow <= ALUoverflow;
            zero     <= ALUzero;
            startFetch;
          end

        load1, store1:
          begin
            startFetch;
          end

        load0:
          begin
            state <= load1;
            PSEL <= 1;
            PENABLE <= 1;
          end

        store0:
          begin
            state <= store1;
            PSEL <= 1;
            PWRITE <=  1;
            PENABLE <= 1;
          end

        halt:
          // we executed an illegal instruction, so we stop
          ;

        default:
          state <= halt;

      endcase

    end

  // task startFetch is ONLY called from within the main clocked
  // process. It gathers together a few transition actions that
  // must be performed whenever going into state fetch0.
  //
  task startFetch;
    state  <= fetch0;
    PWRITE <= 0;
    PSEL   <= 1;
    PADDR  <= updatePC ? regWrData : shadowPC;
  endtask : startFetch

endmodule : miniCPU
//___________________________________________________________________________

