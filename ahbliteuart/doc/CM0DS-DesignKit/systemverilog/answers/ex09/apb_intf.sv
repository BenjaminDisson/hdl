// apb_intf.sv

interface APB (input logic PCLK);

  timeunit 1ns;
  timeprecision 1ns;

  import APB_trans_pkg::*;

  logic PSEL, PENABLE, PWRITE;
  APB_addr_t PADDR;
  APB_data_t PWDATA;
  APB_data_t PRDATA;

  //
  // ANSWER - clocking block for bus master
  //
  clocking cb @ (posedge PCLK);
    default input #1step output #1ns;
    input  PRDATA;
    output PSEL, PENABLE, PWRITE;
    output PADDR, PWDATA;
  endclocking: cb

  //
  // ANSWER - master modport  signals replaced by clocking block
  //
  modport master_mp ( clocking cb );

  modport slave_mp  ( input  PCLK, PSEL, PENABLE,
    PWRITE, PADDR, PWDATA, output PRDATA);

endinterface
