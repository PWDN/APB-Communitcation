module controller_wrapper #(
  parameter SEL_WIDTH = 1,
  parameter ADDR_WIDTH = 16,
  parameter DATA_WIDTH = 16
  )(
    i_PCLK,
    o_PREADY, // not necessary needed, but rather for debug
    o_PRDATA,
    o_PSLVERR
  );

  input logic i_PCLK;
  output logic o_PREADY;
  output logic [DATA_WIDTH-1:0] o_PRDATA;
  output logic o_PSLVERR;

  logic s_PRESETn;
  logic s_PSEL1;
  logic s_PSEL2;
  logic s_PREADY1;
  logic s_PREADY2;
  logic [DATA_WIDTH-1:0] s_PRDATA1;
  logic [DATA_WIDTH-1:0] s_PRDATA2;
  logic s_PWRITE;
  logic [ADDR_WIDTH-1:0] s_PADDR;
  logic s_PENABLE;


  logic m_en;
  logic m_wr; // 1 - write to memory, 0 - read
  logic m_addr; // memory adress
  logic m_data_w;
  logic m_data_r;
  logic m_dump;

  Memory_model #(
    ADDR_WIDTH,
    DATA_WIDTH,
    "./DATA/mem.data"
  ) memory (
    .i_clk(i_PCLK),
    .i_en(m_en),
    .i_wr(m_wr),
    .i_addr(m_addr),
    .i_data_w(m_data_w),
    .o_data_r(m_data_r),
    .i_dump(m_dump)
  );

  APB_slave_arbiter #(
    DATA_WIDTH,
    ADDR_WIDTH,
    SEL_WIDTH
  ) arbiter (
    .i_PSEL({s_PSEL1,s_PSEL2}), // from master
    .i_PREADY({s_PREADY1, s_PREADY2}), // from master
    .i_PWRITE(s_PWRITE), // from master
    .i_PRDATA({s_PDATA1, s_PDATA2}), // from master
    .o_PREADY(o_PREADY),
    .o_PRDATA(o_PRDATA),
    .o_PSLVERR(o_PSLVERR)
  );

  


  logic [SEL_WIDTH-1:0] mas_psel;
  logic [DATA_WIDTH-1:0] mas_pwdata;

  APB_master #(
    SEL_WIDTH,
    ADDR_WIDTH,
    DATA_WIDTH
  ) master (
    .i_PCLK(i_PCLK),
    .i_PRESETn(s_RESETn),
    .o_PADDR(s_ADDR), // to slaves
    .o_PSEL(mas_psel), // to be splitted to PSEL1 and PSEL2
    .o_PENABLE(s_PENABLE), // to slaves
    .o_PWRITE(s_PWRITE), // to arbiter and slaves
    .o_PWDATA(mas_pwdata), // to be splitted to PDATA1 and PDATA2
    .i_PREADY(o_READY), // from arbiter
    .i_PRDATA(o_PRDATA), // from arbiter
    .i_PSLVERR(o_PSLVERR),

    .i_enable(), // from controller
    .i_wr(), // from controller
    .i_slave_idx(), // from controller
    .i_addr(), // from controller
    .o_data_r(), // to controller
    .o_data_valid(), // to controller
    .o_busy() // to controller
  );

  APB_slave_exe_w47 #(
    DATA_WIDTH,
    ADDR_WIDTH
  ) (
    .i_PCLK(i_PCLK),
		.i_PRESETn(s_RESETn),
		.i_PADDR(s_PADDR), // from master
		.i_PSEL(s_PSEL1), // from master
		.i_PENABLE(s_PENABLE), // from master
		.i_PWRITE(s_PWRITE), // from master
		.i_PWDATA(s_PWDATA), // from master
		.o_READY(s_PREADY1), // to arbiter
		.o_PRDATA(s_PRDATA1), // to arbiter
		.o_PSLVERR() // to arbiter
  );




endmodule
