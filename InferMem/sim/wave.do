onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_wrapper_fifo1c/mi_clk
add wave -noupdate /tb_wrapper_fifo1c/mi_areset_n
add wave -noupdate /tb_wrapper_fifo1c/mi_sreset
add wave -noupdate /tb_wrapper_fifo1c/mi_RdReq
add wave -noupdate /tb_wrapper_fifo1c/mo_RdData
add wave -noupdate /tb_wrapper_fifo1c/mo_StatusFull
add wave -noupdate /tb_wrapper_fifo1c/mo_StatusAlmostFull
add wave -noupdate /tb_wrapper_fifo1c/mo_StatusAlmostEmpty
add wave -noupdate /tb_wrapper_fifo1c/mi_WrReq
add wave -noupdate /tb_wrapper_fifo1c/mi_WrData
add wave -noupdate /tb_wrapper_fifo1c/mo_StatusEmpty
add wave -noupdate /tb_wrapper_fifo1c/mo_StatusWordCounter
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb_wrapper_fifo1c/inst_Wrapper_Fifo1c/inst_InferFifo1c/i_WrData
add wave -noupdate /tb_wrapper_fifo1c/inst_Wrapper_Fifo1c/inst_InferFifo1c/i_WrReq
add wave -noupdate /tb_wrapper_fifo1c/inst_Wrapper_Fifo1c/inst_InferFifo1c/o_StatusFull
add wave -noupdate /tb_wrapper_fifo1c/inst_Wrapper_Fifo1c/inst_InferFifo1c/o_StatusEmpty
add wave -noupdate /tb_wrapper_fifo1c/inst_Wrapper_Fifo1c/inst_InferFifo1c/o_StatusAlmostFull
add wave -noupdate /tb_wrapper_fifo1c/inst_Wrapper_Fifo1c/inst_InferFifo1c/o_StatusAlmostEmpty
add wave -noupdate /tb_wrapper_fifo1c/inst_Wrapper_Fifo1c/inst_InferFifo1c/o_StatusWordCounter
add wave -noupdate /tb_wrapper_fifo1c/inst_Wrapper_Fifo1c/inst_InferFifo1c/s_WrEn
add wave -noupdate /tb_wrapper_fifo1c/inst_Wrapper_Fifo1c/inst_InferFifo1c/s_WrData
add wave -noupdate /tb_wrapper_fifo1c/inst_Wrapper_Fifo1c/inst_InferFifo1c/s_StatusEmpty
add wave -noupdate /tb_wrapper_fifo1c/inst_Wrapper_Fifo1c/inst_InferFifo1c/s_WrAddress
add wave -noupdate /tb_wrapper_fifo1c/inst_Wrapper_Fifo1c/inst_InferFifo1c/s_RdAddress
add wave -noupdate /tb_wrapper_fifo1c/inst_Wrapper_Fifo1c/inst_InferFifo1c/s_RdEn
add wave -noupdate /tb_wrapper_fifo1c/inst_Wrapper_Fifo1c/inst_InferFifo1c/s_StatusFull
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb_wrapper_fifo1c/inst_Wrapper_Fifo1c/inst_InferFifo1c/inst_WrapperRam1c2p/inst_InferRam1c2p/i_WrAddress
add wave -noupdate /tb_wrapper_fifo1c/inst_Wrapper_Fifo1c/inst_InferFifo1c/inst_WrapperRam1c2p/inst_InferRam1c2p/i_WrData
add wave -noupdate /tb_wrapper_fifo1c/inst_Wrapper_Fifo1c/inst_InferFifo1c/inst_WrapperRam1c2p/inst_InferRam1c2p/i_RdAddress
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5369785 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 159
configure wave -valuecolwidth 89
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
WaveRestoreZoom {5266004 ps} {5653996 ps}
