// apb_mon.sv

// Monitor and coverage components

//
//____________________________________________ class APB_Monitor ___
//
//
class APB_Monitor extends Component;

  // Virtual interface variable to hold a reference
  // to the test access interface that exists in our test
  // harness module
  //
  APB_mon_hook hook;

  APB_Channel sink;

  function new(string _name, Component _parent,
    APB_mon_hook _hook);
    super.new( _name, _parent );
    hook = _hook;
    //connect sink to "dummy" internal channel
    // (allows monitor to be used without connection to external channel)
    sink = new(1);
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

          $cast (tr_cpy,current.copy());
          ok = sink.try_put(tr_cpy);
          assert (ok) else
            $info( "%s.sink blocked, lost data =\n    %s",
              this.get_hier_name(),           current.psprint() );

        end : if_PENABLE

      end : if_PSEL

    end : body_loop

  endtask : body

endclass : APB_Monitor


//____________________________________________ class APB_Cov_Collector ___
//
//
class APB_Cov_Collector extends Component;

  APB_Channel source;
  APB_Trans   tr;

  // TO DO - add a covergroup with bins for the following transaction fields:
  // dir, addr, data, idle_cycles
  // IF YOU HAVE TIME - add cross coverage for addr and dir (no bin should be
  // created for the case where the direction is write and the addr corresponds
  // to ROM)

  rand T_data v;
  rand int num;

  covergroup cg (int at_least = 1);
    option.at_least = at_least;
    cp_a : coverpoint tr.dir {
      bins read = {dir_Rd};
      bins write = {dir_Wr};
    }

    cp_b : coverpoint tr.addr {
      bins ROM = {['h0000:'h5FFF]};
      bins RAM = {['h8000:'hDFFF]};
      bins IO = {['hFF80:'hFFFF]};
    }

    cp_c: coverpoint tr.data;

    cp_d: coverpoint tr.idle_cycles;

  endgroup





  // TO DO - constructor should create a transaction object and the covergroup
  function new (string _name, Component _parent,int at_least=1);
    super.new( _name, _parent );
    cg = new (at_least);
  endfunction : new

  // TO DO - body task should get transactions from the monitor and then call sample
  // for the covergroup
  task body();

    //$cast(tr, source.get());
    //assert (ok);
    forever
    begin
      source.get(tr);
      cg.sample();
    end

  endtask : body

endclass : APB_Cov_Collector
