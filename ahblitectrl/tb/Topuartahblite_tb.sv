


module TopUartAhbLite_tb;

  timeunit 1ns;
  timeprecision 1ns;

  localparam C_AhbAddrWidth = 32;   // Width of address bus
  localparam C_AhbDataWidth = 32;   // Width of data bus
  localparam DEBUG = 0;             // Control diagnostic messages
  localparam C_BaudRate     = 434; // 434 = 50Mhz/ 115200


  logic                      HCLK; 
  logic                      HRESETn; 
  logic [C_AhbAddrWidth-1:0] HADDR;
  logic                      HWRITE;  
  logic                [2:0] HSIZE;     
  logic                [2:0] HBURST;    
  logic                [3:0] HPROT;     
  logic                [1:0] HTRANS;  
  logic                      HMASTLOCK; 
  logic                      HREADY;   
  logic                      HREADYOUT;
  logic                      HRESP;     // To manage
  logic [C_AhbDataWidth-1:0] HWDATA;
  logic [C_AhbDataWidth-1:0] HRDATA; 
  logic                      HSEL; 
  logic                      i_UartRx;  //Input from RS-232 
  logic                      o_UartTx;  //Output to RS-232 
  logic                      o_UartIrq; //Interrupt 

  logic [C_AhbDataWidth-1:0] CounterUartRx,VarRdData;
   //logic [C_AhbDataWidth-1:0] VarDataExpected;
  logic [7:0] VarWrData;



  // Clock generator

  always
  begin
    #10 HCLK = 1;
    #10 HCLK = 0;
  end



  // Clocking block.
  // The control signals are "inout" clockvars here so that the tester 
  // can both sample and drive them
  //
  clocking cb @(posedge HCLK);
    default input #2 output #3;
  //  input Q;
  //  inout Reset, Enable, Load, UpDn, Data;
  endclocking
  
  // Task to wait for N clocks
  // NOTE the use of "automatic" here to allow more than one
  //      instance of the task to be run concurrently
  //
  task automatic cycles(int unsigned N);
    repeat (N)
    begin
      @(cb);
    end
  endtask

//_________________________________________________________________________  
//_________________________________________________________________________    
  // Memory read task
  // input: address to read from
  // output: data value on HRDATA bus signal
  //
  task MemReadTask(input logic [C_AhbAddrWidth-1:0] VarAddr, output logic [C_AhbDataWidth-1:0] VarRdData);
    if (DEBUG) $display("Doing AHB Lite read");


    HADDR     <= VarAddr;
    HREADY    <= 1'b1;
    HWRITE    <= 1'b0;   
    HTRANS    <= 2'b10;
    HSEL      <= 1'b1;
    HSIZE     <= 3'b000;
    HBURST    <= 3'b000;
    HPROT     <= 4'b0000;
    HMASTLOCK <= 1'b0; 

    @(posedge HCLK);
    HADDR     <= {$bits(HADDR) {1'bx}};  
    HREADY    <= 1'b1;
    HWRITE    <= 1'b0;
    HTRANS    <= 2'b00;   
    HSEL      <= 1'b0;
    VarRdData  = HRDATA;
    HSIZE     <= 3'b000;    
    HBURST    <= 3'b000;
    HPROT     <= 4'b0000;    
    HMASTLOCK <= 1'b0;

    if (DEBUG) $display("Done AHB Lite read");
  endtask

//_________________________________________________________________________  
//_________________________________________________________________________    
  // Memory write task
  // input: address to write to
  // input: data value on HWDATA bus signal
  //
  task MemWriteTask(input logic [C_AhbAddrWidth-1:0] VarAddr, input logic [7:0] VarWrData);
    if (DEBUG) $display("Doing AHB Lite read");


    HADDR     <= VarAddr;
    HREADY    <= 1'b1;
    HWRITE    <= 1'b1;   
    HTRANS    <= 2'b10;
    HSEL      <= 1'b1;
    HWDATA    <= {24'h0000_00,VarWrData}; //Assign AHB WRDATA to 8-bit Fifo  // {>>xx{}}  
    HSIZE     <= 3'b000;    
    HBURST    <= 3'b000;
    HPROT     <= 4'b0001;
    HMASTLOCK <= 1'b0;


    @(posedge HCLK);
    HADDR     <= {$bits(HADDR) {1'bx}};  
    HREADY    <= 1'b1;
    HWRITE    <= 1'b0;
    HTRANS    <= 2'b00;   
    HSEL      <= 1'b0;
    HSIZE     <= 3'b000;    
    HBURST    <= 3'b000;
    HPROT     <= 4'b0001;   
    HMASTLOCK <= 1'b0;     


    if (DEBUG) $display("Done AHB Lite Write");
  endtask
//_________________________________________________________________________  
//_________________________________________________________________________  
  task ReceiveRxUART (input logic Value);
    int unsigned i;//if (DEBUG) $display("Receive uart data %0h ", VarAddr);

    //for (i = 0; i < 7; i++)
    @(posedge HCLK);
    i_UartRx  <= Value;//VarAddr[i];
    cycles(C_BaudRate);
    $display("value receive %0h", Value);

  endtask
//_________________________________________________________________________  
//_________________________________________________________________________  
  // Bus idle task
  // input: number of clock cycles to remain idle
  //
  task BusIdle (int unsigned n = 0);
    if (DEBUG) $display("Doing AMBA idle for %0d cycles", n);

    repeat (n) @(posedge HCLK);

  endtask



  //_________________________________________________________________________
  // task to load a random value in the range 64 to 127
  //
 /* task gen_random_load_value();
    logic [7:0] value;
    bit ok;
    ok = std::randomize(value) with { value >= 64; value < 128; };
    assert (ok);
    load(value);
  endtask
  */
  //_________________________________________________________________________  
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
//  initial
//  begin: StimReadAHB
//
//    int n_checks;
//  
//    BusIdle(5);
///*
//    for (int i = 0; i < 2**APB_ADDR_WIDTH; i++)
//    begin
//      mem_write(i, i << 4);
//    end
//  
//    BusIdle(10);
//
//*/
//    for (int i = 0; i < 2**C_AhbAddrWidth; i++)
//    begin
//      MemReadTask(i,VarDataRead);
///*      VarDataExpected = i << 4;
//      assert (VarDataRead === VarDataExpected) 
//        n_checks++;
//      else $error("data read: %0h does not match expected %0h",
//                  VarDataRead,VarDataExpected);
//*/
//
//    end
//
//    BusIdle(5);
//    $display("%0d checks completed", n_checks);
//
//    //$finish;
//  end: StimReadAHB
//_________________________________________________________________________  
//_________________________________________________________________________  


  initial
  begin: StimReceiveRS
    i_UartRx  <= 1'b1;
    //CounterUartRx <= 8'h0000000b;
    CounterUartRx <= 0;
   // CounterAHLRd <= 0;

    BusIdle(6);
/*
    for (int i = 0; i < 2**APB_ADDR_WIDTH; i++)
    begin
      mem_write(i, i << 4);
    end
  
    BusIdle(10);

*/
   // $display("Test CounterUartRx : %8h", CounterUartRx);

    //for (int VarInstruction = 0 ; VarInstruction < 34 ; VarInstruction++)
    for (CounterUartRx = 8'h00000000; CounterUartRx < 8'h00000008; CounterUartRx++)
    begin
      //CounterUartRx <= VarInstruction;
     if (DEBUG)  $display("Test CounterUartRx : %8h", CounterUartRx);
      for (int VarInstruction = 4 ; VarInstruction > 0 ; VarInstruction--)
      begin
        if (DEBUG) $display("VarInstruction : %d ; CounterUartRx[VarInstruction] = %2h", VarInstruction-1, CounterUartRx>>((VarInstruction-1)*8));

        ReceiveRxUART(0); // start = 0
        for (int VarByte = 0 ; VarByte < 8 ; VarByte++)
        begin        
          ReceiveRxUART(CounterUartRx[VarInstruction * 8 - 1 - VarByte]);
          if (DEBUG) $display("CounterUartRx[VarInstruction * 8 - 1 - VarByte] : %d ", CounterUartRx[VarInstruction * 8 - 1 - VarByte]);
        end
        ReceiveRxUART(1); // stop = 1
      end
      //$display("CounterUartRx[%d] : %8h", VarInstruction, CounterUartRx);
      //ReceiveRxUART(CounterUartRx[i]);
    end

/*
    for (CounterAHLRd = 8'h00000000; CounterAHLRd = 8'h0000000b; CounterAHLRd <= CounterUartRx + 8'h00000001)
      for (int unsigned j = 0 ; j<32 ; j++)
      begin
        $display("j= %0h ; CounterUartRx[j] = %0h", j, CounterUartRx[j]);
        
      end
*/

      
/*      VarDataExpected = i << 4;
      assert (VarDataRead === VarDataExpected) 
        n_checks++;
      else $error("data read: %0h does not match expected %0h",
                  VarDataRead,VarDataExpected);
*/

    

    BusIdle(5);
    $finish;
  end: StimReceiveRS

//_________________________________________________________________________  
//_________________________________________________________________________  

 initial
  begin: StimRdAHB
    BusIdle(6);
    forever 
    begin
      @(posedge HCLK);
      if (o_UartIrq == 1'b1)
      begin
        MemReadTask(3, VarRdData);
        BusIdle(2);
      end
    end

  end: StimRdAHB    


//_________________________________________________________________________  
//_________________________________________________________________________  

 initial
  begin: StimWrAHB
    BusIdle(6);
    VarWrData <= 0;//4'h0000;
    forever 
    begin
      @(posedge HCLK);
      if (o_UartIrq == 1'b1)
      begin
        BusIdle(5);
        MemWriteTask(3, VarWrData);
        VarWrData <= VarWrData + 1;
      end
    end

  end: StimWrAHB

//_________________________________________________________________________  
//_________________________________________________________________________  
  initial
  begin: BusError

     BusIdle(7);

    forever 
    begin
      @(posedge HCLK);
      if (HRESP == 1'b1)
      begin
        $display("Erreur sur le bus");
        $finish;
      end
    end     
  end: BusError
/*
  initial
  begin: GenClock
    HCLK = 0;
    forever 
      #5ns HCLK = !HCLK;  
  end: GenClock
*/

  initial
  begin: GenResetN
    HRESETn = 0;
    #25ns 
    HRESETn = !HRESETn;
  end: GenResetN

  TopUartAhbLite #(C_AhbAddrWidth, C_AhbDataWidth) TopUartAhbLite ( .HCLK(HCLK), .HRESETn(HRESETn),
    .HADDR(HADDR),.HWRITE(HWRITE),.HSIZE(HSIZE),.HBURST(HBURST),.HPROT(HPROT),.HTRANS(HTRANS),.HMASTLOCK(HMASTLOCK),
    .HREADY(HREADY),.HREADYOUT(HREADYOUT),.HRESP(HRESP),.HWDATA(HWDATA),.HRDATA(HRDATA),.HSEL(HSEL),
    .i_UartRx(i_UartRx),.o_UartTx(o_UartTx),.o_UartIrq(o_UartIrq));

endmodule: TopUartAhbLite_tb

