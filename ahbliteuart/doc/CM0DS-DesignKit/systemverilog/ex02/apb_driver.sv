// apb_driver.sv
//
// Driver (master) for memory with APB slave interface.
// Paramterised address bus width and data width
// PCLK is provided by testbench (it is an input port for driver)

module APB_driver
(
  // APB interface
  input   logic PCLK,
  output  APB_trans_pkg::APB_addr_t PADDR,
  output  APB_trans_pkg::APB_data_t PWDATA,
  output  logic PWRITE,
  output  logic PENABLE,
  output  logic PSEL,
  input   APB_trans_pkg::APB_data_t PRDATA
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

    PSEL    <= 1'b1;
    PADDR   <= rd_addr;
    PWRITE  <= 1'b0;

    @(posedge PCLK);
    PENABLE <= 1'b1;

    @(posedge PCLK);
    rd_data  = PRDATA;
    PADDR   <= {APB_ADDR_WIDTH{1'bx}};
    PSEL    <= 1'b0;
    PENABLE <= 1'b0;

  endtask

  // ______________________________________________________ write() ___
  //
  task mem_write(input APB_addr_t wr_addr, input APB_data_t wr_data);

    PSEL    <= 1'b1;
    PWRITE  <= 1'b1;
    PADDR   <= wr_addr;
    PWDATA  <= wr_data;

    @(posedge PCLK);
    PENABLE <= 1'b1;

    @(posedge PCLK);
    PSEL    <= 1'b0;
    PENABLE <= 1'b0;
    PWRITE  <= 1'b0;
    PADDR   <= {APB_ADDR_WIDTH{1'bx}};
    PWDATA  <= {APB_DATA_WIDTH{1'bx}};

  endtask

  // _______________________________________________________ idle() ___
  //
  task bus_idle (int unsigned n = 0);
    repeat (n) @(posedge PCLK);
  endtask


  //
  // TO DO
  // task to receive APB transaction and drive bus
  //

  task drive (input APB_trans_t my_transaction);
    APB_data_t actual_data;  //variable to hold read data value


    case(my_transaction.my_bus)
      idle:bus_idle (1);
      read:mem_read(my_transaction.my_addr, actual_data);
      write:mem_write( my_transaction.my_addr, my_transaction.my_data);
      check:
        begin
        mem_read(my_transaction.my_addr, actual_data);
        assert (my_transaction.my_data === actual_data) $display("ok");else $error("erreur a corriger");
        end
    endcase
  endtask: drive

endmodule: APB_driver
