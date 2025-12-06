// apb_trans_pkg.sv

package APB_trans_pkg;
  timeunit 1ns;
  timeprecision 1ns;

  localparam APB_ADDR_WIDTH = 8;   // Width of address bus
  localparam APB_DATA_WIDTH = 16;  // Width of data bus

  typedef logic [APB_ADDR_WIDTH-1:0] APB_addr_t;
  typedef logic [APB_DATA_WIDTH-1:0] APB_data_t;

  // TO DO - declare enumerated type named bus_op_t
  // The enum values should be: idle=0, read, write, check, invalid
  typedef enum{idle,read,write,check,invalid} bus_op_t;


  // TO DO - declare APB_trans_t struct type with fields of type
  // bus_op_t, APB_addr_t and APB_data_t
  typedef struct {
    bus_op_t    my_bus;
    APB_addr_t  my_addr;
    APB_data_t  my_data;
  } APB_trans_t;

  function automatic APB_trans_t get_APB_trans(int fd);
    bus_op_t bus_op;
    APB_addr_t addr;
    APB_data_t data;
    logic [1:640] line;
    if (fd)
    begin
      if ($fgets(line, fd))
      begin
        int n_items;
        n_items = $sscanf(line, "%d %h %h", bus_op, addr, data);
        if (n_items == 3)
        // TO DO
        // return an APB_trans_t object whose fields match the values
        // of bus_op, addr and data

        /*get_APB_trans.my_bus = bus_op_t;
        get_APB_trans.my_addr = addr;
        get_APB_trans.my_data = data;
        */
        return '{bus_op,addr,data};
      end
    end

    // TO DO
    // if no transaction found in file, return an APB_trans_t object
    // with invalid bus_op_t member (set address and data to 0)
      /*get_APB_trans.my_bus = invalid;
      get_APB_trans.my_addr = 8'b0;
      get_APB_trans.my_data = 16'b0;
*/
      return '{invalid,8'b0,16'b0};


  endfunction: get_APB_trans

endpackage: APB_trans_pkg
