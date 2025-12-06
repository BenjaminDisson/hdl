vlib work
vlog counter.sv
vlog countertb.sv
vsim -novopt -assertdebug -assertcover Countertb
view assertions
#add wave G1/a1 G1/a2 G1/a3 G1/a4 G1/a5
do wave.do
run -all
wave zoomfull