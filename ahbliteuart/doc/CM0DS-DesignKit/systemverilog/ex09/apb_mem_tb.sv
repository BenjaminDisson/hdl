// apb_mem_tb.sv
//
// YOU DO NOT NEED TO MODIFY THIS FILE
// 
// Testbench for synchronous memory model with APB slave interface.
// Paramterised address bus width = 8 bits, data width = 16 bits

module APB_mem_tb;

  timeunit 1ns;
  timeprecision 1ns;

  import APB_trans_pkg::*;

  logic  PCLK;

  APB bus (.PCLK);

  initial
  begin: stim
    int fd;
    APB_trans_t trans;
  
    fd = $fopen("apb_stim.txt", "r");
    #5ns;
    while ( !$feof(fd) )
    begin
      trans = get_APB_trans(fd);
      drv0.drive(trans);
    end
    $finish;
  end: stim
  
  APB_clock_gen gen0 (.enable(1'b1), .PCLK);
  
  APB_mem #( APB_ADDR_WIDTH, APB_DATA_WIDTH, 1 ) mem0 ( .bus(bus.slave_mp) );
  APB_driver drv0 (.bus);

endmodule: APB_mem_tb
