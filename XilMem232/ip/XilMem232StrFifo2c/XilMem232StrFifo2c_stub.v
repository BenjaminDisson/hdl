// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Mon Jun 10 14:19:26 2024
// Host        : Parnet03 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/ariane/TTE/SimpleFifoStr/SimpleFifoStr.gen/sources_1/ip/XilMem232StrFifo2c/XilMem232StrFifo2c_stub.v
// Design      : XilMem232StrFifo2c
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z015clg485-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_9,Vivado 2023.2" *)
module XilMem232StrFifo2c(wr_rst_busy, rd_rst_busy, m_aclk, s_aclk, 
  s_aresetn, s_axis_tvalid, s_axis_tready, s_axis_tdata, s_axis_tstrb, s_axis_tkeep, 
  s_axis_tlast, s_axis_tuser, m_axis_tvalid, m_axis_tready, m_axis_tdata, m_axis_tstrb, 
  m_axis_tkeep, m_axis_tlast, m_axis_tuser, axis_wr_data_count, axis_rd_data_count, 
  axis_prog_full, axis_prog_empty)
/* synthesis syn_black_box black_box_pad_pin="wr_rst_busy,rd_rst_busy,s_aresetn,s_axis_tvalid,s_axis_tready,s_axis_tdata[31:0],s_axis_tstrb[3:0],s_axis_tkeep[3:0],s_axis_tlast,s_axis_tuser[3:0],m_axis_tvalid,m_axis_tready,m_axis_tdata[31:0],m_axis_tstrb[3:0],m_axis_tkeep[3:0],m_axis_tlast,m_axis_tuser[3:0],axis_wr_data_count[10:0],axis_rd_data_count[10:0],axis_prog_full,axis_prog_empty" */
/* synthesis syn_force_seq_prim="m_aclk" */
/* synthesis syn_force_seq_prim="s_aclk" */;
  output wr_rst_busy;
  output rd_rst_busy;
  input m_aclk /* synthesis syn_isclock = 1 */;
  input s_aclk /* synthesis syn_isclock = 1 */;
  input s_aresetn;
  input s_axis_tvalid;
  output s_axis_tready;
  input [31:0]s_axis_tdata;
  input [3:0]s_axis_tstrb;
  input [3:0]s_axis_tkeep;
  input s_axis_tlast;
  input [3:0]s_axis_tuser;
  output m_axis_tvalid;
  input m_axis_tready;
  output [31:0]m_axis_tdata;
  output [3:0]m_axis_tstrb;
  output [3:0]m_axis_tkeep;
  output m_axis_tlast;
  output [3:0]m_axis_tuser;
  output [10:0]axis_wr_data_count;
  output [10:0]axis_rd_data_count;
  output axis_prog_full;
  output axis_prog_empty;
endmodule
