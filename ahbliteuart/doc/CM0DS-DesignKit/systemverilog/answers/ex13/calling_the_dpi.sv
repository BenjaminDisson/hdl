// calling_the_dpi.sv

module calling_the_DPI;

  // ANSWER: Add an import declaration to allow the C function count1s to be called from SystemVerilog  
  //         Note that the C function will itself make a call back into SystemVerilog
  import "DPI-C" context function int count1s(int v);
  
  // ANSWER: Add an export declaration to allow the sv_debug function to be called from C
  export "DPI-C" function sv_debug;

  // ANSWER: Add an import declaration to allow the C function delay_via_C to be called from SystemVerilog  
  //         This C function calls the SystemVerilog task sv_delay
  import "DPI-C" context task delay_via_c(int d);

  // ANSWER: Add an export declaration to allow the task sv_delay to be called from C
  export "DPI-C" task sv_delay;


  function void sv_debug(string msg);
    $display("sv_debug: %s", msg);
  endfunction


  // ANSWER: Add a SystemVerilog task that executes a delay and then displays a message showing the time
  task sv_delay( int n );
    #n;
    $display("sv_delay: time is now %0d", $time);
  endtask


  initial
  begin
    int v;
    int from_c;
    $display("Starting simulation");
  
    v = 32'b00000000_00000000_00000000_00000000;
    from_c = count1s(v);
    assert( from_c == 0 );

    v = 32'b00000001_00000001_00000001_00000001;
    from_c = count1s(v);
    assert( from_c == 4 );

    v = 32'b00000000_11111111_11111111_00000000;
    from_c = count1s(v);
    assert( from_c == 16 );

    v = 32'b11111111_00000000_00000000_11111111;
    from_c = count1s(v);
    assert( from_c == 16 );

    // ANSWER: call the imported task to execute a delay
    delay_via_c(999);

    $display("Ending simulation");
  end

endmodule
