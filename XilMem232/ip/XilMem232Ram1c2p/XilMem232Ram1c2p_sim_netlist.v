// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Mon Jun 10 13:46:10 2024
// Host        : Parnet03 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/ariane/TTE/SimpleFifoStr/SimpleFifoStr.gen/sources_1/ip/XilMem232Ram1c2p/XilMem232Ram1c2p_sim_netlist.v
// Design      : XilMem232Ram1c2p
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z015clg485-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "XilMem232Ram1c2p,blk_mem_gen_v8_4_7,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_7,Vivado 2023.2" *) 
(* NotValidForBitStream *)
module XilMem232Ram1c2p
   (clka,
    wea,
    addra,
    dina,
    clkb,
    enb,
    addrb,
    doutb);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [3:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [15:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [3:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [15:0]doutb;

  wire [3:0]addra;
  wire [3:0]addrb;
  wire clka;
  wire clkb;
  wire [15:0]dina;
  wire [15:0]doutb;
  wire enb;
  wire [0:0]wea;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [15:0]NLW_U0_douta_UNCONNECTED;
  wire [3:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [15:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "4" *) 
  (* C_ADDRB_WIDTH = "4" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "1" *) 
  (* C_COUNT_36K_BRAM = "0" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     3.01735 mW" *) 
  (* C_FAMILY = "zynq" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "0" *) 
  (* C_HAS_ENB = "1" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "1" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "XilMem232Ram1c2p.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "16" *) 
  (* C_READ_DEPTH_B = "16" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "16" *) 
  (* C_READ_WIDTH_B = "16" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "16" *) 
  (* C_WRITE_DEPTH_B = "16" *) 
  (* C_WRITE_MODE_A = "NO_CHANGE" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "16" *) 
  (* C_WRITE_WIDTH_B = "16" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  XilMem232Ram1c2p_blk_mem_gen_v8_4_7 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(NLW_U0_douta_UNCONNECTED[15:0]),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(1'b0),
        .enb(enb),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[3:0]),
        .regcea(1'b0),
        .regceb(1'b0),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[3:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[15:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2023.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
jLV29U0rrfMIZhYJzdoUrPoqB9eHQ5NXmWyCdqnN3Wgm+GU4C3zthrN1m4QGiaj0thPCIynZbX+0
7yjtkv+T5ByJ6NhiofAwWseGLvPXlYu6ERAPvi4SAYpF2VUqQHtPAbPmnPubGdDRgIEpeobF7hsz
rEcpEru1pyiScUriyuo=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
vsoizVrOONWw/DhjRLEYrtRmtji+Ok63CbpSg/l9VnoKAi8tAzqRbQ57atGB2N6IGGbKHkbK2Uzh
EHgWvYZeyt4hE+bpQX91vc9PNxfjQMGzPoFD3jCWk30EmEk+AND39eWx+DhJ8xhFuucoOQ2GwyAk
B+Mjs15naPE7DvlHel8hnD4dfSdYhGKp96oozu8JeBto8aHG6poOuYkxSwaut7NCI+mabCkMxtMp
RrydgmRuTvhRTbJMyx5CxFSZTRDrS5aU1vaRlnMiqKCI7g2KY9pemYaJsFeVodBuo6IyKGynyEhs
wr+VtUhQDtaVhMkwB95WwmMoDk9F2L5Au1I+TQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
W081dPMCWhKs5YlQD7n3zvf7+PTcnb8eFWxoVs8+zHLkxDMA1klITbsfztGYvJFce8Yao5XQLLqZ
oUE5Pq2arq+zwICFUcLjdMsmP1WmL82znHOPHm83zNwrxWMloHkySAqzFbgJeHa973uZqj0M8ydc
sYmzCYVlGVjt0QX0xqA=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Zpc3MmdLWaVOv+S4z2POuoyslYoAbWc+Npxq2UyQRtDwf566IId3uwAetolMAgfLo/G3ezuSOXMn
8NznS37h9XvmVrxA50SAux68P87WgkLtiUYqM3CMBKkxNlZ/TR8WzTuQyFdvzkOE9lp8HC7LXnk5
RDsnOM+su46FW7ysY01COslo9Xc7rhs6WFqx29+Xcqk8+ZMLSzaJfuwZdNmJFS3Q1vhlq3ZeYqMl
wMieB731KsPxjxp7VKNHpTbgFryC2isqc4ohBDOt52M/Bz4B/rIpFeHfZ7X3jWSiKtSuBsDN2NXf
EMjfAT248dlK7NxJ+NBNPhS5sLxTiGyQhta57A==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
rPMYqnkKhJKV1wltOfDrKos9ZbucaoX3WGTuqsdLkGpcKObzslHBwlGrKtWV7bZYmS2SM+QuEMfa
CE+tCUdsSiprp+n5BuSQlJa6BJ8mlqccjoo/JLw2QEmUhyMXQ3TLGomGGoZdeTmMPXhUBAOyLPea
Ddc8mgtTN8Kpy117GOTXDKP+IKJqW01fLrPJpgEhFiJCbyElLgtCRWmI94gX+y4XNVS0Cd1YwNw6
4nHgnEdC7fXARDKcYO3VsWC/pdzPQgursXloNLrVYa6i2xr+8E1V0+nSWwNYQZP7XUIVqXKMU8Ea
bT4acXrRCF/5tJJ5B9JparYI0zxXSbaakn1dIw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2022_10", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
mfroTgL8g2pyIXQ/mGO9YHm19cd5mOlJ++qpusOYeVxGmkIhvF4aKx+AyIUz2yGGAeCtOzIasHty
pyqKgZhibSqxcpHgR0m6GOxXXOXJiHaK8NzxUzXeRJovcBI/WjtDhXeb1LRMI1J97jVBtJPJQH0Y
fGOD7jWvkvQwxnrZdyLp6kPWgSIcavHHDbO7iJv4gnyGp6W3/FCDo2RKWNLoW+SNjSdLZ6YRP8a+
ldaGU8TYvJ03KWlmik7repuN6AwxCjg2KeQ+x1sBAEXzROXomuSbvX3ZAo8UiIKAQY1SJumHLG3L
QI/S4Wbl1Hz6LDTsttMwP480gq6+tb6s1E4oWw==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
QJIabgm8dx/gVHbOQFwt8maOKVHFgkpZTPR6dzD8fqoGo9M9oGPTqBqchtPZWgv2UYFF2KEUSlV4
L3SDXBKrLs+NsAVTcICaEMiEi6j82zj/C1LsPkQfS8RLrg0ab8lbDMb5YqJ7lkHs3iM65x2iN1Mf
66cTgCbkAdl3rDpab75btpTQt5ZKiq5CSY3RZfyIW0uWbTGTELm6liuRKM9+K8BQwTU7A+FFFQBA
/9eJwQYzNNA/iwoYJ2WTPd6pBlzXriNLu9M+/2bYicNBSuH1PBR9v2ESrTB6k7EiV1zvBXV9NuG/
sFt4MumWMuSNwP2W38bQATxxW/l0IrmaXGOC/w==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
lhKf/Vgj6pHpme1ji4HVe36BU8pMkam/2I9lFeyOiBnIbzgdEGfLJBcEvkL33A7s0hxa6LFbHnkT
upgMpPjmIghBz3xUQ13vpiY152thFec6qvlcdg1r+GTmnBOSFl6g/OfZ3eFUhfsve6ZjQHpXnKFo
a55hN2+eP1EG9+VxGeM7XkHaeFhEIry52qtnmg072KEFIwRiGs2d/TJ4AqupuIdIiP1kTN9k+oqa
2ta1vdtqPY0dDHqrf+5YSd0CejkhQeCqg/bauLP3755SwdOPRgooG5ANT8hUpTiFMFXtU+GC9NSp
evJtMHUy1NbgMmhFHO+w3URLEdjSaBxZPD7YLdWkF65jY526tJzoek+BzEKoBaGfCaY7O1nHKXm+
89k3rPUy0Xo4/0nHpno+N/Db09heJPbnGsCwN/l+KnR6Lz8kvWziBjZe0ijOkKI+T12y3T1VeOtY
H/aqtNlQt1mhFwrbw6ezaAiDPVbCQXnly6b4tbb8+nFsxWOGIGAfLozB

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
PNsQ8uEcQYrl+GaDuBaq1tQ5br5aAdaqHnyrc0NVu/JnQUk53jaiLx8Oz5fNACvWelUUk2/C+P5I
b2rbU1bb/dC6TqC5J1N0yoMYRYw58u4Lrl8Kgqgt9Rlph5Qgzzfxp+oblXF/pO4mRyAXpZhpNkFT
0Ar9BUtPOTOtJ9/g53SRnZ6GjxzfeD+25J4fcXBNo2gCTgUkwiLSsJRwTB/cJmn+dZPwPdIOHEP9
TkfDK+OrbLYO3T+DFBTCMRNH2NB1J9sc5s+nPU8iYnjgPTo6HoGW+LIlCz6yNJMZzJzoeW708utc
0fJXkT7vLDVh7olvy3V9AAY8Do0YR1kiZlhVhQ==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
zAz8RnGHFebkJFAS+gjC+mXHW7m7We+JgSmIz15mS01u/4+9Ng0sJfkeXOClmVPTQ2Mp2Yuv6/6f
ehzUTcANilWsqLM6Q1FToCPNX/NTqodlcHirGM7b5R9yevouNT/aqH12nmbunBQmBHmehNutdCjG
r6Z7kZgeZ2ZE7MMOF0rTy1XHEPkqgMNTRoS8R/pPWPTW4/j+bn3aJj0Q/fTz4Gi3mbSUKWs2fREQ
UKiuolNJkN6DiDvhlVYHUyytXNJG44ikmBXehoQQRLapkYaxnQmMRT1ok9uY6pKoy71CtvJ3Mt2x
EQv1GU2i4qQyAOwa0mkEohWXduicU6tDz3zQwQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
TK3eE9V+v1z2P1KjG4GrjhA1n3qDOpNzLGXdtjnjhF0QBFPSuhC+nmNqTPOb3p2a9r5KD0miY3Cd
+KpjH6Ao09E2/LD2Go4aLQh6vP+9BldlSKEwCGfx2NjBQrXWVH21lQR7IRjOvyTOclpd7SgtUJLw
dvebETyLiKr9C6RfnIBeptuCA3iJlXfwkh6I0JfzD5WBizQkotioZmmrXv5105pCXQ4Ta1WThFsA
2ll9dZeSjEDHUxxhfyfjryv9m4VL89ZDU/rGITsdptwB1BC1jLqmPDymY05lyECnjA6NIR5GGfI4
K2y2f4GfikKoN5r9IOvFzw963Wm82ZZPtXOKGg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 21008)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
