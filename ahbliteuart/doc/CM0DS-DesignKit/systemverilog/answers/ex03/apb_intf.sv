// apb_intf.sv

interface APB (input logic PCLK); 

  timeunit 1ns;
  timeprecision 1ns;

  import APB_trans_pkg::*;

  logic PSEL, PENABLE, PWRITE;
  APB_addr_t PADDR;
  APB_data_t PWDATA;
  APB_data_t PRDATA;

  modport master_mp ( output PSEL, PENABLE,
    PWRITE, PADDR, PWDATA, input PCLK, PRDATA);

  modport slave_mp  ( input  PCLK, PSEL, PENABLE,
    PWRITE, PADDR, PWDATA, output PRDATA);
    
endinterface
