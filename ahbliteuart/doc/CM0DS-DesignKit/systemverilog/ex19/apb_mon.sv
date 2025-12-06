// apb_mon.sv

// Monitor and checker components


//____________________________________________ class APB_Monitor ___
//
//
class APB_Monitor extends Component;

  // Virtual interface variable to hold a reference
  // to the test access interface that exists in our test
  // harness module
  //
  APB_mon_hook hook;

  // TO DO: Declare a variable for the channel
  APB_Channel chan;


  function new(string _name, Component _parent,
    APB_mon_hook _hook);
    super.new( _name, _parent );
    hook = _hook;
  endfunction : new

  task body();
    APB_Trans current, tr_cpy;
    int idle_clocks;
    bit busy;

    $display("%s body begin", get_hier_name());
    current = new(this);
    busy = 0;
    idle_clocks = 0;

    forever @(hook.mon_cb)
    begin : body_loop

      if (hook.mon_cb.PSEL !== 1'b1)
      begin
        // The bus is idle (PSEL negated)
        idle_clocks++;
        if (busy)
        begin
          busy = 0;
        end

      end
      else
      begin : if_PSEL
        // The bus is active (PSEL asserted)
        if (!busy)
        begin
          busy = 1;
        end

        if (hook.mon_cb.PENABLE === 1'b1)
        begin : if_PENABLE
          bit ok;
          // This is the last clock of a bus cycle - detect a transaction.
          // This simple approach will not work correctly in the
          // presence of bus protocol errors, but we assume that
          // an appropriate set of assertions is provided in the
          // bus interface so we do not need to consider errors here.
          current.idle_cycles = idle_clocks;
          idle_clocks = 0;
          current.addr = hook.mon_cb.PADDR;
          if (hook.mon_cb.PWRITE)
          begin
            current.dir = dir_Wr;
            current.data = hook.mon_cb.PWDATA;
          end
          else
          begin
            current.dir = dir_Rd;
            current.data = hook.mon_cb.PRDATA;
          end

          // TO DO: Send the transaction out of this component using the channel declared above
          //assert(chan.try_put(current.copy()));

      ok = $cast(tr_cpy, current.copy());
      assert (ok);
      ok = chan.try_put(tr_cpy);
      assert (ok);
/*
assert($cast(current, chan.try_put(current.copy())));

      ok = $cast(tr, template.copy());
      assert (ok) else
      $error("APB_Stim template is not derived from APB_Trans\n");
    */

        end : if_PENABLE

      end : if_PSEL

    end : body_loop

  endtask : body

endclass : APB_Monitor


//____________________________________________ class APB_Checker ___
//
//
class APB_Checker extends Component;

  // TO DO: Declare a variable for the channel
  //        and get a transaction from the channel at the appropriate point below
  APB_Channel chan;

  APB_Trans   tr, tr_cpy;
  T_data      previous_addr = 0;

  function new(string _name, Component _parent);
    super.new( _name, _parent );
  endfunction : new

  task body();
    forever
    begin
      chan.get(tr);
     // $cast(tr_cpy,chan.get(tr));
      if (tr.dir == dir_Wr && tr.addr inside {['h8000:'hDFFF]}) // Write to RAM
      begin
        assert( tr.addr > previous_addr )  // Addresses should be ascending
            $display("APB_Checker passed");
          else $fatal(1, $sformatf("tr.addr = %0h, previous = %0h", tr.addr, previous_addr));
        previous_addr = tr.addr;

      end
    end
  endtask : body

endclass : APB_Checker



/*
ok = $cast(tr_cpy, tr.copy());
      assert (ok);
      ok = chan.try_put(tr_cpy);
      assert (ok);
*/