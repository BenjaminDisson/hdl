// countertester.sv

// Use a dynamic array, a queue, and an associative array

module CounterTester;

  timeunit 1ns;
  timeprecision 1ps;

  // TO DO: Declare an enum type to represent the command type
  typedef enum {TOGGLE_COUNT_ENABLE, TOGGLE_COUNT_DIR, DO_RESET, GEN_RANDOM_LOAD_VALUE, CYCLES } command_t;






  // TO DO: Declare a dynamic array of commands, a queue of commands,
  //        and an associative array indexed by command
  command_t DynamicArray_command[];
  command_t Queue_command[$];
  int iQueue=0;
  int AssociativeArray_command[command_t];

  int RandValue;
  command_t RandCommand;
  command_t generated;

  initial
  begin : stimulus
    bit ok;
    CounterTB.initialise();
    CounterTB.count_enable(1);


    // TO DO: Generate a random value in the range 10-20 to represent the number of commands
    assert (randomize(RandValue) with {9<RandValue;RandValue<20;})

    // TO DO: Once you know the number of commands, allocate a dynamic array to store the commands
    DynamicArray_command = new[RandValue];

    // TO DO: Generate each command at random and store all the commands in the dynamic array
    foreach(DynamicArray_command[i])
      assert(randomize(RandCommand))
      DynamicArray_command[i] = RandCommand;

    // TO DO: Execute all the commands from the dynamic array
    execute(DynamicArray_command);


    // TO DO: This time put the generated commands into a queue
    //        and stop generation only when you get two consecutive DO_RESET commands
    do
      assert(randomize(generated))
      Queue_command.push_back(generated);
      //iQueue++;
    while (~(Queue_command[$] == DO_RESET && Queue_command[$-1] == DO_RESET));


    // TO DO: Remove all the DO_RESET commands from the queue
    //        Don't use foreach when you are going to remove elements!
    for (int i=Queue_command.size-1;i>=0;i--)
    begin
    $display("valeur de  Queue_command = %p",Queue_command[i]);
      if (Queue_command[i] == DO_RESET)
        Queue_command.delete(i);
    end



    $display("\nDO_RESET commands removed");
    execute(Queue_command);


    // TO DO: Increment a count for each command type using an associative array
    foreach (Queue_command[i])
    begin
      if (AssociativeArray_command.exists(Queue_command[i]))
        begin
        AssociativeArray_command[Queue_command[i]]++;
        end
      else
        begin
        AssociativeArray_command[Queue_command[i]]=1;
        end

    end

    // TO DO: Print out the count for each command type used
    foreach (AssociativeArray_command[i])
      $display ("%p = %p",AssociativeArray_command[i],i);
      //$display ("test");

    $finish;
  end : stimulus


  // TO DO: Fix the names used in the task below to match the names you used above
  //        Note that the actual argument could be an array or a queue (nice!)

  task execute(command_t a[]);
    $display("\nExecuting %0d commands", a.size);
    foreach (a[i])
      case (a[i])
        TOGGLE_COUNT_ENABLE   : CounterTB.toggle_count_enable();
        TOGGLE_COUNT_DIR      : CounterTB.toggle_count_dir();
        DO_RESET              : CounterTB.do_reset();
        GEN_RANDOM_LOAD_VALUE : CounterTB.gen_random_load_value();
        CYCLES                : CounterTB.cycles(1);
      endcase
    $display;
  endtask

endmodule : CounterTester
