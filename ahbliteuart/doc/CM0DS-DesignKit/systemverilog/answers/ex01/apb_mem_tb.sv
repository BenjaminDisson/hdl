// apb_mem_tb.sv
// 
// Testbench for synchronous memory model with APB slave interface.
// Paramterised address bus width = 8 bits, data width = 16 bits


module APB_mem_tb;

  timeunit 1ns;
  timeprecision 1ns;

  localparam APB_ADDR_WIDTH = 8;   // Width of address bus
  localparam APB_DATA_WIDTH = 16;  // Width of data bus
  localparam master_Tco = 1;
  localparam DEBUG = 0;            // Control diagnostic messages

  logic PCLK;
  logic PSEL = 0;
  logic [APB_ADDR_WIDTH-1:0] PADDR;
  logic [APB_DATA_WIDTH-1:0]PWDATA;
  logic PWRITE = 0;
  logic PENABLE = 0;
  logic [APB_DATA_WIDTH-1:0]PRDATA;  
  
  logic [APB_DATA_WIDTH-1:0] actual_data, expected_data;

  // ANSWER - memory read task
  // input: address to read from
  // output: data value on PRDATA bus signal
  //
  task mem_read(input logic [APB_ADDR_WIDTH-1:0] rd_addr, output logic [APB_DATA_WIDTH-1:0] rd_data);
    if (DEBUG) $display("Doing APB read");

    PSEL    <= 1'b1;
    PADDR   <= rd_addr;
    PWRITE  <= 1'b0;
  
    @(posedge PCLK);
    PENABLE <= 1'b1;
  
    @(posedge PCLK);
    rd_data  = PRDATA;
    PADDR   <= {$bits(PADDR) {1'bx}};
    PSEL    <= 1'b0;
    PENABLE <= 1'b0;
  
    if (DEBUG) $display("Done APB read");
  endtask

  // ANSWER - memory write task
  // input: address to write to and data to write
  task mem_write(input logic [APB_ADDR_WIDTH-1:0] wr_addr, logic [APB_DATA_WIDTH-1:0] wr_data);
    if (DEBUG) $display("Doing APB write");
     
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
    PADDR   <= {$bits(wr_addr) {1'bx}};
    PWDATA  <= {$bits(wr_data) {1'bx}};
  
    if (DEBUG) $display("Done APB write");
  endtask

  // TO DO - bus idle task
  // input: number of clock cycles to remain idle
  //
  task bus_idle (int unsigned n = 0);
    if (DEBUG) $display("Doing APB idle for %0d cycles", n);

    repeat (n) @(posedge PCLK);
  endtask

// __________________________________________________________________________

  //
  // ANSWER: stim process writes to every memory location and checks that
  // expected data is read back
  //
  // Actually this code reads and writes at random. It checks that the read address has alread been
  // written to.
  //
  // ANSWER: Allow some reads from unwritten addresses and check result
  // ANSWER: Change distribution of write addresses to favour addresses alread written to
  //    
  initial
  begin: stim

    int n_checks;
  
    bus_idle(1);

    for (int i = 0; i < 2**APB_ADDR_WIDTH; i++)
    begin
      mem_write(i, i << 4);
    end
  
    bus_idle(10);

    for (int i = 0; i < 2**APB_ADDR_WIDTH; i++)
    begin
      mem_read(i,actual_data);
      expected_data = i << 4;
      assert (actual_data === expected_data) 
        n_checks++;
      else $error("data read: %0h does not match expected %0h",
                  actual_data,expected_data);
    end

    bus_idle(5);
    $display("%0d checks completed", n_checks);

    $finish;
  end: stim

  initial
  begin: clock_gen
    PCLK = 0;
    forever 
      #10ns PCLK = !PCLK;  
  end: clock_gen

  APB_mem #( APB_ADDR_WIDTH, APB_DATA_WIDTH, 1 ) mem0 ( .PCLK(PCLK), .* );

endmodule: APB_mem_tb

