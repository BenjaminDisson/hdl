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
  // TO DO - add a clocking block for bus master
  clocking my_cb@(posedge PCLK);
    output #1ns PSEL;
    output #1ns PENABLE;
    output #1ns PWRITE;
    output #1ns PADDR;
    output #1ns PWDATA;
    input  #1   PRDATA;
  endclocking

  //
  // TO DO - replace master modport signals with clocking block ...
  //
/*  modport master_mp ( output my_cb.PSEL, my_cb.PENABLE,
    my_cb.PWRITE, my_cb.PADDR, my_cb.PWDATA, input my_cb, my_cb.PRDATA);
*/
  modport master_mp (clocking my_cb);

  modport slave_mp  ( input  PCLK, PSEL, PENABLE,
    PWRITE, PADDR, PWDATA, output PRDATA);

endinterface
