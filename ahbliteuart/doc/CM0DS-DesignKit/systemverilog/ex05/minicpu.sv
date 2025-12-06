// minicpu.sv

// STARTING POINT for miniCPU Packed Structs exercise


module miniCPU (
    input             reset,
    input             PCLK,
    output reg [15:0] PADDR,
    output reg [15:0] PWDATA,
    output reg        PWRITE,
    output reg        PENABLE,
    output reg        PSEL,
    input  [15:0]     PRDATA,
    output            halted,
    output            fetch,
    output            branch
  );
import miniCPU_types::*;

  // _________________________________________________ INSTRUCTION BUFFER ___
  //
  // Holds instruction word from each fetch, ready to be decoded
  //
  //reg [15:0] IR;

    IR_t  IR;

  // __________________________________________________________ SHADOW PC ___
  //
  // Keeps a local copy of contents of register 7 (PC).
  // This makes it a bit easier to generate addresses for fetch cycles.
  //
  logic [15:0] shadowPC;


  // ________________________________________________ ALU CONDITION CODES ___
  //
  // These registers capture the ALU condition code outputs at the moment
  // when any OPERATE instruction writes its result to the register file.
  // These flags are updated even if the target register is r0.
  //
  logic carry, overflow, zero;


  // __________________________________________________ CPU STATE MACHINE ___
  //

    typedef enum {
    init  ,
    fetch0,
    fetch1,
    decode,
    load0 ,
    load1 ,
    store0,
    store1,
    exec  ,
    halt  ,
    initZ } state_t;
  //
 state_t state;



  // _______________________________________________________ ALU DATAPATH ___
  //
  // ALU DATAPATH SIGNALS
  //
  // ALUout - output data from ALU
  logic [15:0] ALUout;
  //
  // Condition code outputs from ALU
  logic ALUoverflow, ALUcarry, ALUzero;
  //
  //
  // ALU OPERAND INPUTS
  //
  // opA, opB: operands are always taken from register bank
  logic [15:0] opA, opB;
  //
  // cIn: carry input, derived from carry flag, or constant in IR
  //wire cIn = IR[13] ? (carry ^ IR[12]) : IR[12];

  //Carry fabriqué dans l'instruction operate
    logic cIn;
    assign cIn = IR.Operate.carryInControl[1] ? (carry ^ IR.Operate.carryInControl[0]) : IR.Operate.carryInControl[0];


  // _________________________________ REGISTER FILE DATAPATH AND CONTROL ___
  //
  // Flag set to write to a register on this clock...
  logic WrReg;
  //
  // Register bank write address and data,
  // determined by the instruction
  logic [2:0] regWrAdrs;
  logic [15:0] regWrData;
  //
  // Register bank outputs (read ports):
  logic [15:0] RdA, RdB;
  //
  // Register bank read addresses:
  logic [2:0] adrsRdA, adrsRdB;
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
  //wire [15:0] offsetAdrs = RdA + { {10{IR[5]}}, IR[5:0] };

  logic [15:0] offsetAdrs;
  assign offsetAdrs = RdA + { {10{IR.LoadFromMemory.offset[5]}}, IR.LoadFromMemory.offset[5:0] };

  // _______________________________________________________ ALU INSTANCE ___
  //
  miniCPU_alu alu (
      .opA(opA),
      .opB(opB),
      .Op(miniCPU_types::T_ALU_Ops'(IR[2:0])),
      .cIn(cIn),
      .invA(IR[14]),
      .result(ALUout),
      .cOut(ALUcarry),
      .overflow(ALUoverflow),
      .zero(ALUzero)
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
  //always @(carry or zero or overflow or IR[11:9])
  always_comb //@(carry or zero or overflow or IR.ConditionnalBranch.conditionSource[2:0])
  begin
    case (IR[11:9])
      3'b000:  // If overflow
        ConditionalsOK = overflow;
      3'b001:  // If zero
        ConditionalsOK = zero;
      3'b010:  // If carry
        ConditionalsOK = carry;
      3'b011:  // unsigned borrow
        ConditionalsOK = ~carry && ~overflow;
      3'b100:  // Not overflow
        ConditionalsOK = ~overflow;
      3'b101:  // Non-zero
        ConditionalsOK = ~zero;
      3'b110:  // No carry
        ConditionalsOK = ~carry;
      3'b111:  // Unconditionally true
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
  assign adrsRdA = IR[8:6];
  assign adrsRdB = (IR[15:12] == 4'b1110) ? IR[11:9] : IR[5:3];  // store


  // _____________________________________________________ REGISTER WRITE ___
  //
  // Destination is always r[7] (PC) for branches, otherwise
  // specified by destination field of IR
  //
  //assign regWrAdrs = (IR[15:12] == 4'b1111) ? 3'b111 : IR[11:9];
  assign regWrAdrs = (IR.LoadConstant.flag[3:0] == 4'b1111) ? 3'b111 : IR[11:9];
  assign updatePC = WrReg && (regWrAdrs == 3'b111);


  // Selection of write data source
  //
  always_comb// @(IR or ALUout or PRDATA or offsetAdrs)
  begin

    // Data to be written is determined by instruction opcode
    casez (IR[15:12])
      4'b0???: // OPERATE: get data from ALU output
        regWrData = ALUout;
      4'b1100: // LOAD CONSTANT: data constructed from IR contents
        regWrData = { {8{IR[8]}}, IR[7:0] };
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

  always_comb// @(state or IR or ConditionalsOK or WriteableReg)
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
  always_ff @(posedge PCLK, posedge reset)

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
            IR <= 16'b1100_000_000000000;  // Loads 0 to r0
            state <= initZ;
          end

        initZ:
          begin
            IR <= 16'b1100_111_000000000;  // Loads 0 to r7
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
            IR <= 16'b1111_111_111_000001;
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
    begin
      state  <= fetch0;
      PWRITE <= 0;
      PSEL   <= 1;
      PADDR  <= updatePC ? regWrData : shadowPC;
    end
  endtask // startFetch

endmodule // miniCPU
//___________________________________________________________________________

