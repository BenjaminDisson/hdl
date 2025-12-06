// This file contains a list of Verilog or SystemVerilog files
// use with the -f option to compile the exercise
//
// Commands to compile and simulate SystemVerilog 
// -----------------------------------------
// Cadence Incisive:          irun -f files.f
// Mentor Graphics QuestaSim: qverilog -f files.f
// Synopsys VCS:              vcs -R -sverilog -f files.f
// Aldec Riviera:             vsimsa -do "alib work; alog -f files.f; asim; run -all; quit"
//
// Commands to compile and simulate SystemVerilog in the gui:
// -----------------------------------------
// Cadence Incisive:          irun +access+rwc -gui -f files.f 
// Mentor Graphics QuestaSim: qverilog -novopt -gui -f files.f
// Synopsys VCS:              vcs -R -sverilog +acc -gui -f files.f
// Aldec Riviera:             riviera -do "alib work; alog -dbg -O0 -f files.f; asim -dbg +access +r"
//
// Optional flags
// -----------------------------------------
// Cadence Incisive:          -q     suppresses certain messages during compilation
// Mentor Graphics QuestaSim: -quiet suppresses certain messages during compilation
// Mentor Graphics QuestaSim: -sv    interprets .v files as containing SystemVerilog code
// Synopsys VCS:              -quiet suppresses certain messages during compilation
// 
// Files to compile
// ----------------
// Edit this list to compile your own copies of the files:

// The minCPU design
minicpu_types.sv
minicpu_alu.sv
minicpu_reg_bank.sv
minicpu.sv

// The testbench, including the APB memory model
apb_mem.sv
minicpu_tb.sv

// The test case - which is the top-level module and reads fibonacci.mca
minicpu_test_fibonacci.sv
