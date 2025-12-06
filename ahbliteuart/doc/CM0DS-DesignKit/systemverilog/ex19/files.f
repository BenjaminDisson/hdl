// This file contains a list of Verilog or SystemVerilog files
// use with the -f option to compile the exercise
//
// Commands to compile and simulate SystemVerilog and view functional coverage
// ---------------------------------------------------------------------------

// Cadence Incisive:
// irun -coverage all -covoverwrite -f files.f
// iccr -gui &
//   Select menu File->Open Test...
//   Select directory cov_work/scope/test  (you may need to select a different path) 

// Mentor Graphics QuestaSim:
// qverilog -novopt -gui -f files.f &
//   Select menu View->Coverage->Covergroups  (unless the Covergroups tab is already visible)
//   Run

// Synopsys VCS:
// vcs -R -sverilog -f files.f
// dve -cov -dir simv.vdb &

// ---------------------------------------------------------------------------
// OR CHECK WITH YOUR TOOL VENDOR FOR THE BEST WAY TO VIEW FUNCTIONAL COVERAGE
// ---------------------------------------------------------------------------

// Files to compile
// ----------------

../dut/apb_dummy.sv
apb_pkg.sv
apb_harness.sv
apb_tb.sv
