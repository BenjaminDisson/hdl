// This file contains a list of Verilog or SystemVerilog files
// use with the -f option to compile the exercise
//
// To View Assertions
// -----------------------------------------
// Cadence Incisive:
//   irun -gui -debug -f files.f
//   In the Console - SimVision window, select menu Windows -> New -> Assertion Browser
//   In the Design Browser - SimVision window, select your assertions, right-click, Send to Waveform Window
//
// Mentor Graphics QuestaSim:
//   qverilog -novopt -f files.f -R -gui -assertdebug
//   In the QuestaSim window, select menu View -> Coverage -> Assertions (UNLESS ALREADY OPEN)
//   In the Assertion window, select your assertions, right-click, Add Wave
//
// Synopsys VCS:
//   vcs -R -sverilog -gui -f files.f
//   In the DVE window, select menu Window -> Panes -> Assertion
//   In the DVE window, select your assertions, right-click, Add To Waves -> New Wave View
// 
// Files to compile
// ----------------
// Edit this list to compile your own copies of the files:

counter.sv
countertb.sv
