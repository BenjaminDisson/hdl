// apb_intf.sv

// APB interface

interface APB (input logic PCLK);

  timeunit 1ns;
  timeprecision 1ns;

  // Bus APB

  APB_trans_pkg::APB_addr_t PADDR;
  APB_trans_pkg::APB_data_t PWDATA;
  logic PWRITE;
  logic PSEL;
  logic PENABLE;
  APB_trans_pkg::APB_data_t PRDATA;


  //mastermodports
  modport master_mp(input PCLK, output PADDR, output PWDATA, output PWRITE, output PSEL, output PENABLE, input PRDATA);

  //slave modports
  modport slave_mp(input PCLK, input PADDR, input PWDATA, input PWRITE, input PSEL, input PENABLE,output PRDATA);

endinterface
