vlib work
vlog constants.sv
vlog cpu_part1.sv

vsim -novopt -assertdebug -assertcover test
view assertions

do wave1.do
#add wave cpu1/a1 cpu1/a2 cpu1/a3 cpu1/a4a cpu1/a4b cpu1/a5
run -all
wave zoomfull