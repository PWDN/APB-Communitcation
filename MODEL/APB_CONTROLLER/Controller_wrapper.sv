module controller_wrapper #(
  parameter SEL_WIDTH = 2,
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
  logic m_wr_mem; // 1 - write to memory, 0 - read
  logic [ADDR_WIDTH-1:0] m_addr_mem; // memory adress
  logic [DATA_WIDTH-1:0] m_data_w;
  logic [DATA_WIDTH-1:0] m_data_r;
  logic m_dump;

  Memory_model #(
    ADDR_WIDTH,
    DATA_WIDTH,
    "./DATA/mem.data"
  ) memory (
    .i_clk(i_PCLK),
    .i_en(m_en),
    .i_wr(m_wr_mem),
    .i_addr(m_addr_mem),
    .i_data_w(m_data_w), // from controller
    .o_data_r(m_data_r), // to controller
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
    .i_PRDATA({s_PRDATA1, s_PRDATA2}), // from master
    .o_PREADY(o_PREADY),
    .o_PRDATA(o_PRDATA),
    .o_PSLVERR(o_PSLVERR)
  );

  


  logic core_wr;
  logic [DATA_WIDTH-1:0] core_data_w;

  logic [SEL_WIDTH-1:0] mas_psel;
  logic [DATA_WIDTH-1:0] mas_pwdata;
  logic [DATA_WIDTH-1:0] mas_data_r;
  logic [ADDR_WIDTH-1:0] mas_addr;
  logic mas_busy;

  APB_master #(
    SEL_WIDTH,
    ADDR_WIDTH,
    DATA_WIDTH
  ) master (
    .i_PCLK(i_PCLK),
    .i_PRESETn(s_PRESETn),
    .o_PADDR(s_PADDR), // to slaves
    .o_PSEL(), // to be splitted to PSEL1 and PSEL2
    .o_PENABLE(s_PENABLE), // to slaves
    .o_PWRITE(s_PWRITE), // to arbiter and slaves
    .o_PWDATA(mas_pwdata), // to be splitted to PDATA1 and PDATA2
    .i_PREADY(o_PREADY), // from arbiter
    .i_PRDATA(o_PRDATA), // from arbiter
    .i_PSLVERR(o_PSLVERR),

    .i_enable(m_en), // from controller
    .i_wr(core_wr), // from controller
    .i_slave_idx(mas_psel), // from controller
    .i_addr(mas_addr), // from controller
    .i_data_w(core_data_w), // from controller
    .o_data_r(mas_data_r), // to controller
    .o_data_valid(), // to controller
    .o_busy() // to controller
  );

  apb_slave_exe_w47 #(
    DATA_WIDTH,
    ADDR_WIDTH
  ) exe_47 (
    .i_PCLK(i_PCLK),
		.i_PRESETn(s_PRESETn),
		.i_PADDR(s_PADDR), // from master
		.i_PSEL(s_PSEL1), // from master
		.i_PENABLE(s_PENABLE), // from master
		.i_PWRITE(s_PWRITE), // from master
		.i_PWDATA(mas_pwdata), // from master
		.o_PREADY(s_PREADY1), // to arbiter
		.o_PRDATA(s_PRDATA1), // to arbiter
		.o_PSLVERR() // to arbiter
  );

  apb_slave_exe_w48 #(
      DATA_WIDTH,
      ADDR_WIDTH
    ) exe_48 (
    .i_PCLK(i_PCLK),
		.i_PRESETn(s_PRESETn),
		.i_PADDR(s_PADDR), // from master
		.i_PSEL(s_PSEL2), // from master
		.i_PENABLE(s_PENABLE), // from master
		.i_PWRITE(s_PWRITE), // from master
		.i_PWDATA(mas_pwdata), // from master
		.o_PREADY(s_PREADY2), // to arbiter
		.o_PRDATA(s_PRDATA2), // to arbiter
		.o_PSLVERR() // to arbiter
  );

  always_ff @(posedge s_PSEL1 or posedge s_PSEL2)
  begin
    if (s_PSEL1)
      begin
        mas_psel = 'd0;
      end
    else
      begin
        mas_psel = 'd1;
      end
  end

    // .i_clk(i_PCLK),
    // .i_en(m_en),
    // .i_wr(m_wr),
    // .i_addr(m_addr),
    // .i_data_w(m_data_w), // from controller
    // .o_data_r(m_data_r), // to controller
    // .i_dump(m_dump)


  controller_core #(
    DATA_WIDTH,
    ADDR_WIDTH,
    SEL_WIDTH
  ) core (
    .i_clk(i_PCLK),
    .i_rsn(s_PRESETn),
    .i_data_r(mas_data_r),
    .i_data_r_mem(m_data_r),
    .o_halt(),

    .o_addr(mas_addr),
    .o_addr_mem(m_addr_mem),
    .o_slave_sel1(s_PSEL1),
    .o_slave_sel2(s_PSEL2),
    .o_en(),
    .o_wr(core_wr),
    .o_wr_mem(m_wr_mem),
    .o_data(core_data_w),
    .o_data_mem(m_data_w),
    .o_dump()
  );


endmodule
