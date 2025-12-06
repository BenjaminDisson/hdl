// apb_trans_pkg.sv

// YOU DO NOT NEED TO MODIFY THIS FILE

package APB_trans_pkg;

  timeunit 1ns;
  timeprecision 1ns;

  localparam APB_ADDR_WIDTH = 8;   // Width of address bus
  localparam APB_DATA_WIDTH = 16;  // Width of data bus

  typedef logic [APB_ADDR_WIDTH-1:0] APB_addr_t;
  typedef logic [APB_DATA_WIDTH-1:0] APB_data_t;

  typedef enum { idle, read, write, check, invalid } bus_op_t;

  typedef struct {
    bus_op_t bus_op;
    APB_addr_t addr;
    APB_data_t data;
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
          return '{bus_op, addr, data};
      end
    end
    return '{invalid, 0, 0};
  endfunction: get_APB_trans

endpackage: APB_trans_pkg


