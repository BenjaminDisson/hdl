// apb_mem_tb.sv

// Testbench for synchronous memory model with APB slave interface.
// Paramterised address bus width = 8 bits, data width = 16 bits

module APB_mem_tb;
  timeunit 1ns;
  timeprecision 1ns;

  //
     import APB_trans_pkg::*;
  //
  // ...
  logic      PCLK;
  logic      PSEL;
  APB_addr_t PADDR;
  APB_data_t PWDATA;
  logic      PWRITE;
  logic      PENABLE;
  APB_data_t PRDATA;

  initial
  begin: stim
    int fd;
    APB_trans_t trans;

    fd = $fopen("apb_stim.txt", "r");
    #5ns;
    while ( !$feof(fd) )
    begin
      // TO DO - call get_APB_trans to fetch next transaction from file and
      // pass to the driver's drive task
      trans = get_APB_trans(fd);
      drv0.drive(trans);
    end
    $finish;
  end: stim

  APB_clock_gen gen0 (.enable(1'b1), .PCLK);

  APB_mem #( APB_ADDR_WIDTH, APB_DATA_WIDTH, 1 ) mem0 ( .* );
  APB_driver drv0 ( .* );

endmodule: APB_mem_tb

