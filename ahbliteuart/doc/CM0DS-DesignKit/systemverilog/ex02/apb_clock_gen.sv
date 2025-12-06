// apb_clock_gen.sv
// A clock generator module

// YOU DO NOT NEED TO MODIFY THIS FILE


module APB_clock_gen(input bit enable, output logic PCLK);

  timeunit 1ns;
  timeprecision 1ns;

  initial
  begin: clock_gen
    PCLK = 0;
    #0; //make sure enable has been initialized
    while (enable)
    begin 
      #10ns PCLK = !PCLK;
    end
  end: clock_gen

endmodule: APB_clock_gen
