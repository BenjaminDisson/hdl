onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Countertb/G1/a1
add wave -noupdate /Countertb/G1/a2
add wave -noupdate /Countertb/G1/a3
add wave -noupdate /Countertb/G1/a4
add wave -noupdate /Countertb/G1/a5
add wave -noupdate /Countertb/G1/a6
add wave -noupdate /Countertb/Clock
add wave -noupdate /Countertb/Data
add wave -noupdate /Countertb/Enable
add wave -noupdate /Countertb/Load
add wave -noupdate /Countertb/Q
add wave -noupdate /Countertb/Reset
add wave -noupdate /Countertb/UpDn
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {302 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ns} {2065 ns}
