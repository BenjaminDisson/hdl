onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /test_bench/inst_cos_sin/i_clk
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /test_bench/inst_cos_sin/i_x
add wave -noupdate -format Literal /test_bench/inst_cos_sin/i_y
add wave -noupdate -format Literal /test_bench/inst_cos_sin/i_z
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -expand /test_bench/inst_cos_sin/s_x
add wave -noupdate -format Literal -expand /test_bench/inst_cos_sin/s_y
add wave -noupdate -format Literal -expand /test_bench/inst_cos_sin/s_z
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /test_bench/inst_cos_sin/o_x
add wave -noupdate -format Literal /test_bench/inst_cos_sin/o_y
add wave -noupdate -format Literal /test_bench/inst_cos_sin/o_z
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 107
configure wave -valuecolwidth 162
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
update
WaveRestoreZoom {0 ps} {3982 ps}
