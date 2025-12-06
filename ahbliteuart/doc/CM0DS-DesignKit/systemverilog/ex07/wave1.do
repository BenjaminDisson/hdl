onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test/addr
add wave -noupdate /test/clk
add wave -noupdate /test/datar
add wave -noupdate /test/dataw
add wave -noupdate /test/fe
add wave -noupdate /test/period
add wave -noupdate /test/ram_re
add wave -noupdate /test/ram_we
add wave -noupdate /test/re
add wave -noupdate /test/reset
add wave -noupdate /test/rom_re
add wave -noupdate /test/we
add wave -noupdate /test/cpu1/a1
add wave -noupdate /test/cpu1/a2
add wave -noupdate /test/cpu1/a3
add wave -noupdate /test/cpu1/a5
add wave -noupdate /test/cpu1/a1
add wave -noupdate /test/cpu1/a2
add wave -noupdate /test/cpu1/a3
add wave -noupdate /test/cpu1/a4a
add wave -noupdate /test/cpu1/a4b
add wave -noupdate /test/cpu1/a5
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {525 ns} 0}
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
WaveRestoreZoom {0 ns} {52532 ns}
