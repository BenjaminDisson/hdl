// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Mon Jun 10 13:46:10 2024
// Host        : Parnet03 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/ariane/TTE/SimpleFifoStr/SimpleFifoStr.gen/sources_1/ip/XilMem232Ram1c2p/XilMem232Ram1c2p_stub.v
// Design      : XilMem232Ram1c2p
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z015clg485-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_7,Vivado 2023.2" *)
module XilMem232Ram1c2p(clka, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="wea[0:0],addra[3:0],dina[15:0],enb,addrb[3:0],doutb[15:0]" */
/* synthesis syn_force_seq_prim="clka" */
/* synthesis syn_force_seq_prim="clkb" */;
  input clka /* synthesis syn_isclock = 1 */;
  input [0:0]wea;
  input [3:0]addra;
  input [15:0]dina;
  input clkb /* synthesis syn_isclock = 1 */;
  input enb;
  input [3:0]addrb;
  output [15:0]doutb;
endmodule
