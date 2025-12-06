onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /CounterTB/Clock
add wave -noupdate /CounterTB/Data
add wave -noupdate /CounterTB/Enable
add wave -noupdate /CounterTB/Load
add wave -noupdate -format Analog-Step -height 74 -max 30.0 -radix decimal /CounterTB/Q
add wave -noupdate /CounterTB/Reset
add wave -noupdate /CounterTB/UpDn
add wave -noupdate /CounterTB/count_dir
add wave -noupdate /CounterTB/count_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {130984 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {2725024 ps}
