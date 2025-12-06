vlib work
vlog CounterTB.sv
vlog CounterTester.sv
vlog CounterMonitor.sv

vsim -cvg63 -novopt -assertdebug -assertcover CounterTB CounterTester CounterMonitor
view assertions

do wave.do
#add wave cpu1/a1 cpu1/a2 cpu1/a3 cpu1/a4a cpu1/a4b cpu1/a5



run -all
wave zoomfull