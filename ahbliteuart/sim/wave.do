onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TopUartAhbLite_tb/HCLK
add wave -noupdate /TopUartAhbLite_tb/HRESETn
add wave -noupdate -divider Top
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/i_UartRx
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/o_UartTx
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/o_UartIrq
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/s_AhbToFifoTxWData
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/s_AhbToFifoTxWR
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/s_FifoTxFull
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/s_FifoRxToAhbRData
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/s_FifoRxToAhbRD
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/s_FifoTxToUartTxData
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/s_UartTxRqData
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/s_FifoTxEmpty
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/s_UartRxToFifoRxData
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/s_UartRxDone
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/s_FifoRxEmpty
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/s_FifoRxFull
add wave -noupdate -divider {AHB Lite}
add wave -noupdate -radix hexadecimal /TopUartAhbLite_tb/TopUartAhbLite/HADDR
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/HWRITE
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/HSIZE
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/HBURST
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/HPROT
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/HTRANS
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/HMASTLOCK
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/HREADY
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/HREADYOUT
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/HRESP
add wave -noupdate -radix hexadecimal /TopUartAhbLite_tb/TopUartAhbLite/HWDATA
add wave -noupdate -radix hexadecimal /TopUartAhbLite_tb/TopUartAhbLite/HRDATA
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/HSEL
add wave -noupdate -divider FifoTx
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartFifoTx/data
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartFifoTx/rdreq
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartFifoTx/wrreq
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartFifoTx/empty
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartFifoTx/full
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartFifoTx/q
add wave -noupdate -divider UartTx
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartTx/t_CurrentState
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartTx/i_StartSending
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartTx/i_Data
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartTx/o_RequestData
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartTx/o_UartTx
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartTx/s_CountBaudRate
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartTx/s_DataCounter
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartTx/s_Done
add wave -noupdate -divider UartRx
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartRx/i_Clk
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartRx/i_ResetN
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartRx/i_UartRx
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartRx/o_Done
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartRx/o_Data
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartRx/t_CurrentState
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartRx/s_DataCounter
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartRx/s_Countbyte
add wave -noupdate -divider FifoRx
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartFifoRx/data
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartFifoRx/rdreq
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartFifoRx/wrreq
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartFifoRx/empty
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartFifoRx/full
add wave -noupdate /TopUartAhbLite_tb/TopUartAhbLite/InstUartFifoRx/q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2573938078 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {0 ps} {2916700500 ps}
