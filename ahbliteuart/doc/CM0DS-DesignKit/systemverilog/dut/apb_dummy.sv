// apb_dummy.sv

// YOU DO NOT NEED TO MODIFY THIS FILE.

// Dummy APB slave module to act as a device-under-test for
// testbench lab exercises, reporting on the console all
// activity it sees on the APB bus so that you can easily
// see what your testbench did.

// This module merely reports bus activity to the console,
// and supplies dummy readback data that is the XOR of the
// most recently written data and the current read address.

module APB_dummy (
    input   bit   PCLK,
    input   logic PENABLE,
    input   logic PSEL,
    input   logic PWRITE,
    input   logic [15:0] PADDR,
    input   logic [15:0] PWDATA,
    output  logic [15:0] PRDATA
  );

  logic [15:0] last_write_data;

  function logic [15:0] make_data();
    make_data = PADDR ^ last_write_data;
    if (PADDR >= 'hFF80) make_data ^= 'hxx00;
  endfunction

  // This "always" block provides the dummy functionality.
  //
  always @(posedge PCLK) 
  begin : dummy_device
    if (PSEL && PENABLE && PWRITE) 
    begin
      // second cycle of a write: capture the data
      last_write_data = PWDATA;
    end 
    else if (PSEL && !PENABLE && !PWRITE) 
    begin
      // First cycle of a read: drive data
      PRDATA <= #2 make_data();
    end
  end : dummy_device

  // This code reports every active bus cycle to the console.
  //
  initial 
  begin : cycle_reporting
    int clocks;
    forever @(posedge PCLK) 
    begin
      clocks++;
      if (PSEL && PENABLE && PWRITE) 
      begin // it's a write
        $display("--------\nAPB write at clocks %0d/%0d, t=%0d:",
                                       clocks-1, clocks, $time);
        $display("  A='h%h, D='h%h", PADDR, PWDATA);
      end 
      else if (PSEL && PENABLE && !PWRITE) 
      begin
        // second clock of read, report it
        $display("--------\nAPB read at clocks %0d/%0d, t=%0d:",
                                      clocks-1, clocks, $time);
        $display("  A='h%h, D='h%h", PADDR, PRDATA);
      end
    end
  end : cycle_reporting

endmodule : APB_dummy
