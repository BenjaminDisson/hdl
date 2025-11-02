onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_wrapper_fifo1c2/mi_clk
add wave -noupdate /tb_wrapper_fifo1c2/mi_areset_n
add wave -noupdate /tb_wrapper_fifo1c2/mi_sreset
add wave -noupdate /tb_wrapper_fifo1c2/mi_WrData
add wave -noupdate /tb_wrapper_fifo1c2/mi_WrReq
add wave -noupdate /tb_wrapper_fifo1c2/mi_RdReq
add wave -noupdate /tb_wrapper_fifo1c2/mo_RdData
add wave -noupdate /tb_wrapper_fifo1c2/mo_StatusFull
add wave -noupdate /tb_wrapper_fifo1c2/mo_StatusEmpty
add wave -noupdate /tb_wrapper_fifo1c2/mo_StatusAlmostFull
add wave -noupdate /tb_wrapper_fifo1c2/mo_StatusAlmostEmpty
add wave -noupdate /tb_wrapper_fifo1c2/mo_Overflow
add wave -noupdate /tb_wrapper_fifo1c2/mo_Underflow
add wave -noupdate /tb_wrapper_fifo1c2/mo_StatusWordCounter
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/i_WrData
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/i_WrReq
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/i_RdReq
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/o_RdData
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/o_StatusFull
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/o_StatusEmpty
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/o_StatusAlmostFull
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/o_StatusAlmostEmpty
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/o_Overflow
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/o_Underflow
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/o_StatusWordCounter
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/s_WrAddress
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/s_WrEn
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/s_RdAddress
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/s_RdEn
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/s_StatusFull
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/s_StatusEmpty
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/s_StatusAlmostFull
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/s_StatusAlmostEmpty
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/s_StatusWordCounter
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/s_Overflow
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/s_Underflow
add wave -noupdate /tb_wrapper_fifo1c2/inst_Wrapper_Fifo1c/inst_InferFifo1c/s_Loop
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 252
configure wave -valuecolwidth 76
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {8721 ps}
