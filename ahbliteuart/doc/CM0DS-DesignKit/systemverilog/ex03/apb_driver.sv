// apb_driver.sv

// Driver (master) for memory with APB slave interface.
// Paramterised address bus width and data width
// PCLK is provided by testbench (it is an input port for driver)

module APB_driver
(
APB.master_mp iport
);

  timeunit 1ns;
  timeprecision 1ns;

  import APB_trans_pkg::*;


  // Call these BFM tasks at the posedge of the clock right
  // at the beginning of the cycle. They return just after
  // the final posedge of the cycle.

  // _______________________________________________________ read() ___
  //
  task mem_read(input APB_addr_t rd_addr, output APB_data_t rd_data);

    iport.PSEL    <= 1'b1;
    iport.PADDR   <= rd_addr;
    iport.PWRITE  <= 1'b0;

    @(posedge iport.PCLK);
    iport.PENABLE <= 1'b1;

    @(posedge iport.PCLK);
    rd_data  = iport.PRDATA;
    iport.PADDR   <= {APB_ADDR_WIDTH{1'bx}};
    iport.PSEL    <= 1'b0;
    iport.PENABLE <= 1'b0;

  endtask

  // ______________________________________________________ write() ___
  //
  task mem_write(input APB_addr_t wr_addr, input APB_data_t wr_data);

    iport.PSEL    <= 1'b1;
    iport.PWRITE  <= 1'b1;
    iport.PADDR   <= wr_addr;
    iport.PWDATA  <= wr_data;

    @(posedge iport.PCLK);
    iport.PENABLE <= 1'b1;

    @(posedge iport.PCLK);
    iport.PSEL    <= 1'b0;
    iport.PENABLE <= 1'b0;
    iport.PWRITE  <= 1'b0;
    iport.PADDR   <= {APB_ADDR_WIDTH{1'bx}};
    iport.PWDATA  <= {APB_DATA_WIDTH{1'bx}};

  endtask

  // _______________________________________________________ idle() ___
  //
  task bus_idle (int unsigned n = 0);
    repeat (n) @(posedge iport.PCLK);
  endtask


  // task to receive APB transaction and drive bus

  task drive ( input APB_trans_t trans );
    APB_data_t actual_data;
    case (trans.bus_op)
      idle: bus_idle(1);

      read: mem_read(trans.addr, actual_data);

      write: mem_write(trans.addr, trans.data);

      check: begin
               mem_read(trans.addr, actual_data);
               assert (actual_data === trans.data)
                 $info ("Check for address %h passed", trans.addr);
               else
                 $error ("Check for address %h failed! Read %h, Expected %h",
                          trans.addr, actual_data, trans.data);
             end
    endcase

  endtask: drive


endmodule: APB_driver
