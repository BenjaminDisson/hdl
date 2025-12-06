// apb_mem_tb.sv
//
// Testbench for synchronous memory model with APB slave interface.
// Parameterised address bus width = 8 bits, data width = 16 bits


module APB_mem_tb;

  timeunit 1ns;
  timeprecision 1ns;

  localparam APB_ADDR_WIDTH = 8;   // Width of address bus
  localparam APB_DATA_WIDTH = 16;  // Width of data bus
  localparam master_Tco = 1;

  logic PCLK;
  logic PSEL = 0;
  logic [APB_ADDR_WIDTH-1:0] PADDR;
  logic [APB_DATA_WIDTH-1:0] PWDATA;
  logic PWRITE = 0;
  logic PENABLE = 0;
  logic [APB_DATA_WIDTH-1:0] PRDATA;

  logic [APB_DATA_WIDTH-1:0] actual_data, expected_data;

// __________________________________________________________________________

  // memory read task
  // input: address to read from
  // output: data value on PRDATA bus signal
    task mem_read (input [APB_ADDR_WIDTH-1:0]ADDRR_DFM, output [APB_DATA_WIDTH-1:0] DATAREAD);
      PADDR = ADDRR_DFM;
      PENABLE = 1'b0;
      PWRITE= 1'b0;
      PSEL  = 1'b1;

      @(posedge PCLK);
      PENABLE = 1'b1;
      @(posedge PCLK);
      PENABLE = 1'b0;
      PSEL  = 1'b0;
      PWRITE= 1'b1;

      DATAREAD = PRDATA;
    endtask: mem_read

  //task bus_idle
  // ...
  //endtask

    //task mem_write (input [APB_ADDR_WIDTH-1:0]ADDRW_DFM, input [APB_DATA_WIDTH-1:0]DATAW_BFM);
    task mem_write (int ADDRW_DFM, int DATAW_BFM);
      PADDR = ADDRW_DFM;
      PWDATA= DATAW_BFM;
      PSEL  = 1'b1;
      PWRITE= 1'b1;
      PENABLE = 1'b0;

      @(posedge PCLK);
      PENABLE = 1'b1;
      @(posedge PCLK);
      PSEL  = 1'b0;
      PWRITE= 1'b0;
      PENABLE = 1'b0;
    endtask: mem_write



// __________________________________________________________________________

  //
  // TO DO - stim process writes to every memory location and checks that
  // expected data is read back
  //

  initial
  begin: stim


    // ...
    repeat (4) @(posedge PCLK);

    for (int i = 0;i< 16; i++)
    mem_write(i, i*4);
    //end

    for (int i = 0;i< 16; i++)
    begin
      mem_read(i,actual_data);
      assert (i*4 === actual_data) $display("ok");else $error("erreur a corriger");
    end

    $finish;
  end: stim

  initial
  begin: clock_gen
    PCLK = 0;
    forever
      #10ns PCLK = !PCLK;
  end: clock_gen

  APB_mem #( APB_ADDR_WIDTH, APB_DATA_WIDTH, 1 ) mem0 ( .* );

endmodule: APB_mem_tb