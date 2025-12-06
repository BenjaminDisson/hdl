package APB_pkg;

  typedef enum bit {dir_Rd, dir_Wr} T_dir;
  typedef logic [15:0] T_data;
  typedef logic [15:0] T_addr;
  typedef class APB_Trans;
  typedef class APB_Stream;

  class APB_Trans;
    rand T_addr addr;
    rand T_data data;
    rand T_dir dir;
    const int ID;
    static int next_ID;

    function new();
      next_ID++;
      ID = next_ID;
    endfunction : new

    function APB_Trans copy();
      copy = new this;
    endfunction : copy

   function bit compare(APB_Trans other);
      return (other.addr == this.addr && other.data == this.data && other.dir == this.dir) ? 1'b1 : 1'b0;
    endfunction : compare

   function string psprint();
     $sformat(psprint,"ID = %h, addr = %h, data = %h, dir = %b",ID,addr,data,dir);
   endfunction : psprint

  endclass : APB_Trans

  //---------------------------------------------------------------------------------------------------------

  class APB_Stream;
    string name;
    APB_Trans my_queue_of_APB_Trans[$];
    APB_Trans my_APB_Trans_obj;

    function APB_Trans get_trans(bit print = 1'b0);
      my_APB_Trans_obj = new;
      assert(my_APB_Trans_obj.randomize());

      if (print == 1'b1)
        $display("%s",my_APB_Trans_obj.psprint());

      return my_APB_Trans_obj;
    endfunction : get_trans


    function new(string name = "<anon>");
      this.name = name;
    endfunction : new

  endclass : APB_Stream

endpackage : APB_pkg

//----------------------------------------------

//
module APB_top;

  import APB_pkg::*;
  APB_Stream my_queue_of_APB_Trans[$];
  APB_Stream current;

  initial
  begin
    repeat (10)
    begin
      current = new("Stream n°");
      my_queue_of_APB_Trans.push_back(current);
    end

    $display("HISTORY------------------");
    for (int i=0 ;i<10;i++)
      $display("%p",my_queue_of_APB_Trans[i].get_trans(1'b1));


      $display("%d",my_queue_of_APB_Trans.size);

    // TO DO: If You Have Time:  Test the copy and compare methods
    //
    //...
  end
endmodule : APB_top
