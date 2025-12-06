vlib work
vlog constants.sv
vlog cpu_part2.sv

vsim -novopt -assertdebug -assertcover test
view assertions
#add wave cpu1/a1 cpu1/a2 cpu1/a3 cpu1/a4 cpu1/a5 cpu1/a6 cpu1/a7
do wave2.do
run -all
wave zoomfull