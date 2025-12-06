// countertester.sv

// ANSWER: Use a dynamic array, a queue, and an associative array

module CounterTester;

  timeunit 1ns;
  timeprecision 1ps;

  // ANSWER: Declare an enum type to represent the command type 
  
  typedef enum { TOGGLE_COUNT_ENABLE, TOGGLE_COUNT_DIR, DO_RESET,
                 GEN_RANDOM_LOAD_VALUE, CYCLES } command_t;
  
  // ANSWER: Declare a dynamic array of commands, a queue of commands,
  //         and an associative array indexed by command
  command_t command_a[];
  command_t command_q[$];
  int command_counts[command_t];
  
  command_t command;
  int count;

  initial
  begin : stimulus
    bit ok;
    CounterTB.initialise();
    CounterTB.count_enable(1);    


    // ANSWER: Generate a random value in the range 10-20 to represent the number of commands
    //count = $urandom_range(10, 20);
    ok = std::randomize(count) with { count > 10; count < 20; };   

    // ANSWER: Once you know the number of commands, allocate a dynamic array to store the commands
    command_a = new[count];

    // ANSWER: Generate each command at random and store all the commands in the dynamic array
    for (int i = 0; i < count; i++)
    begin
      ok = std::randomize(command);
      assert (ok);
      command_a[i] = command;
    end

    // ANSWER: Execute all the commands from the dynamic array
    execute(command_a);
    
    
    // ANSWER: This time put the generated commands into a queue 
    //         and stop generation only when you get two consecutive DO_RESET commands
    forever
    begin
      ok = std::randomize(command);
      assert (ok);
      command_q.push_back(command);

      if (command_q[$] == DO_RESET && command_q[$-1] == DO_RESET)
        break;
    end
    
    // ANSWER: Remove all the DO_RESET commands from the queue
    //         Don't use foreach when you are going to remove elements!
    for (int i = 0; i < command_q.size; i++)
      if (command_q[i] == DO_RESET)
        command_q.delete(i--);

    $display("\nDO_RESET commands removed");
    execute(command_q);

    
    // ANSWER: Increment a count for each command type using an associative array
    foreach (command_q[i])
    begin
      command = command_q[i];
      command_counts[command]++;
      /*
      // Alternative fussy version that does not rely upon the default value
      if (command_counts.exists(command))
        command_counts[command]++;
      else
        command_counts[command] = 0;
      */
    end
     
    // ANSWER: Print out the count for each command type used
    foreach (command_counts[i])
      $display("Number of %s = %0d", i.name, command_counts[i]);
     
    $finish;
  end : stimulus


  // Note that the actual argument could be an array or a queue (nice!)
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
