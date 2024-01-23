module controller_core();
  parameter DATA_WIDTH = 32;
  parameter ADDR_WIDTH = 4;
  logic [0:0] o_PCLK;
  logic [0:0] o_PRESETn;
  logic [0:0] o_PREADY;
  logic [0:0] o_mem_en;
  logic [0:0] o_mem_wr;
  logic [0:0] i_o_mem_addr;
  logic [DATA_WIDTH-1:0] o_mem_data_w;
  logic [DATA_WIDTH-1:0] i_mem_dada_r;
  logic [0:0] o_mem_dump;


endmodule
