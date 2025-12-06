onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TopUartAhbLite_tb/HCLK
add wave -noupdate /TopUartAhbLite_tb/HRESETn
add wave -noupdate -divider {AHB Lite}
add wave -noupdate /TopUartAhbLite_tb/HADDR
add wave -noupdate /TopUartAhbLite_tb/HWRITE
add wave -noupdate /TopUartAhbLite_tb/HSIZE
add wave -noupdate /TopUartAhbLite_tb/HBURST
add wave -noupdate /TopUartAhbLite_tb/HPROT
add wave -noupdate /TopUartAhbLite_tb/HTRANS
add wave -noupdate /TopUartAhbLite_tb/HMASTLOCK
add wave -noupdate /TopUartAhbLite_tb/HREADY
add wave -noupdate /TopUartAhbLite_tb/HREADYOUT
add wave -noupdate /TopUartAhbLite_tb/HRESP
add wave -noupdate /TopUartAhbLite_tb/HWDATA
add wave -noupdate /TopUartAhbLite_tb/HRDATA
add wave -noupdate /TopUartAhbLite_tb/HSEL
add wave -noupdate -divider UART
add wave -noupdate /TopUartAhbLite_tb/i_UartRx
add wave -noupdate /TopUartAhbLite_tb/o_UartTx
add wave -noupdate /TopUartAhbLite_tb/o_UartIrq
add wave -noupdate /TopUartAhbLite_tb/VarDataRead
add wave -noupdate /TopUartAhbLite_tb/VarDataExpected
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 267
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
WaveRestoreZoom {0 ps} {124796 ps}
