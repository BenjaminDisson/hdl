// apb_driver.sv
//
// Driver (master) for memory with APB slave interface.
// Paramterised address bus width and data width
// PCLK is provided by testbench (it is an input port for driver)

// TO DO  - replace assignments to modport items with "clocking drives"
// TO DO  - synchronize tasks to clocking block event rather than clock edge


module APB_driver
(
  // APB interface
  APB.master_mp bus
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

    bus.my_cb.PSEL    <= 1'b1;
    bus.my_cb.PADDR   <= rd_addr;
    bus.my_cb.PWRITE  <= 1'b0;

    @(bus.my_cb);
    bus.my_cb.PENABLE <= 1'b1;

    @(bus.my_cb);
    rd_data  = bus.my_cb.PRDATA;
    bus.my_cb.PADDR   <= {APB_ADDR_WIDTH{1'bx}};
    bus.my_cb.PSEL    <= 1'b0;
    bus.my_cb.PENABLE <= 1'b0;

  endtask

  // ______________________________________________________ write() ___
  //
  task mem_write(input APB_addr_t wr_addr, input APB_data_t wr_data);

    bus.my_cb.PSEL    <= 1'b1;
    bus.my_cb.PWRITE  <= 1'b1;
    bus.my_cb.PADDR   <= wr_addr;
    bus.my_cb.PWDATA  <= wr_data;

    @(bus.my_cb);
    bus.my_cb.PENABLE <= 1'b1;

    @(bus.my_cb);
    bus.my_cb.PSEL    <= 1'b0;
    bus.my_cb.PENABLE <= 1'b0;
    bus.my_cb.PWRITE  <= 1'b0;
    bus.my_cb.PADDR   <= {APB_ADDR_WIDTH{1'bx}};
    bus.my_cb.PWDATA  <= {APB_DATA_WIDTH{1'bx}};

  endtask

  // _______________________________________________________ bus_idle() ___
  //
  task bus_idle (int unsigned n = 0);
    repeat (n) @(bus.my_cb);
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
