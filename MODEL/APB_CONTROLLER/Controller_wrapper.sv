module controller_wrapper #(
  parameter SEL_WIDTH = 2,
  parameter ADDR_WIDTH = 16,
  parameter DATA_WIDTH = 16
  )(
    i_PCLK,
  );

  input logic i_PCLK;
  
  logic con_wr_mem;
  logic [ADDR_WIDTH-1:0] con_addr_mem;
  logic [DATA_WIDTH-1:0] con_data_w_mem;
  logic con_dump;

  logic [DATA_WIDTH-1:0] mem_data_r;
  logic con_en = 1;

  Memory_model #(
    ADDR_WIDTH,
    DATA_WIDTH,
    "./DATA/mem.data"
  ) memory (
    .i_clk(i_PCLK),
    .i_en(con_en),
    .i_wr(con_wr_mem),
    .i_addr(con_addr_mem),
    .i_data_w(con_data_w_mem), // from controller
    .o_data_r(mem_data_r), // to controller
    .i_dump(con_dump)
  );

  logic mas_PSEL1;
  logic mas_PSEL2;
  logic mas_PWRITE;
  
  logic sl1_PREADY;
  logic sl2_PREADY;
  logic [DATA_WIDTH-1:0] sl1_PRDATA;
  logic [DATA_WIDTH-1:0] sl2_PRDATA;

  logic arb_PREADY;
  logic [DATA_WIDTH-1:0] arb_PRDATA;
  logic arb_PSLVERR;

  APB_slave_arbiter #(
    DATA_WIDTH,
    ADDR_WIDTH,
    SEL_WIDTH
  ) arbiter (
    .i_PSEL({mas_PSEL1, mas_PSEL2}), // from master
    .i_PREADY({sl1_PREADY, sl2_PREADY}), // from slaves
    .i_PWRITE(mas_PWRITE), // from master
    .i_PRDATA({sl1_PRDATA, sl2_PRDATA}), // from slaves
    .o_PREADY(arb_PREADY),
    .o_PRDATA(arb_PRDATA),
    .o_PSLVERR(arb_PSLVERR)
  );

  logic n_PRESETn = 0 ;

  logic [ADDR_WIDTH-1:0] mas_PADDR;
  logic [SEL_WIDTH-1:0] mas_PSEL;
  logic mas_PENABLE;
  logic [DATA_WIDTH-1:0] mas_PWDATA;

  logic con_wr_apb;
  logic [SEL_WIDTH-1:0] con_psel;
  logic [ADDR_WIDTH-1:0] con_addr_apb;
  logic [DATA_WIDTH-1:0] con_data_w_apb;

  logic [DATA_WIDTH-1:0] mas_data_r;
  logic mas_data_valid;
  logic mas_busy;

  APB_master #(
    SEL_WIDTH,
    ADDR_WIDTH,
    DATA_WIDTH
  ) master (
    .i_PCLK(i_PCLK),
    .i_PRESETn(n_PRESETn),
    .o_PADDR(mas_PADDR), // to slaves
    .o_PSEL(mas_PSEL), // to be splitted to PSEL1 and PSEL2
    .o_PENABLE(mas_PENABLE), // to slaves
    .o_PWRITE(mas_PWRITE), // to arbiter and slaves
    .o_PWDATA(mas_PWDATA), // to be splitted to PDATA1 and PDATA2
    .i_PREADY(arb_PREADY), // from arbiter
    .i_PRDATA(arb_PRDATA), // from arbiter
    .i_PSLVERR(arb_PSLVERR),

    .i_enable(con_en), // from controller
    .i_wr(con_wr_apb), // from controller
    .i_slave_idx(con_psel), // from controller
    .i_addr(con_addr_apb), // from controller
    .i_data_w(con_data_w_apb), // from controller
    .o_data_r(mas_data_r), // to controller
    .o_data_valid(mas_data_valid), // to controller
    .o_busy(mas_busy) // to controller
  );


  logic sl1_PSLVERR;

   apb_slave_exe_w47 #(
    DATA_WIDTH,
    ADDR_WIDTH
  ) exe_47 (
    .i_PCLK(i_PCLK),
		.i_PRESETn(n_PRESETn),
		.i_PADDR(mas_PADDR), // from master
		.i_PSEL(mas_PSEL[0]), // from master
		.i_PENABLE(mas_PENABLE), // from master
		.i_PWRITE(mas_PWRITE), // from master
		.i_PWDATA(mas_PWDATA), // from master
		.o_PREADY(sl1_PREADY), // to arbiter
		.o_PRDATA(sl1_PRDATA), // to arbiter
		.o_PSLVERR(sl1_PSLVERR) // to arbiter
  );

  logic sl2_PSLVERR;

  apb_slave_exe_w48 #(
      DATA_WIDTH,
      ADDR_WIDTH
    ) exe_48 (
    .i_PCLK(i_PCLK),
		.i_PRESETn(n_PRESETn),
		.i_PADDR(mas_PADDR), // from master
		.i_PSEL(mas_PSEL[1]), // from master
		.i_PENABLE(mas_PENABLE), // from master
		.i_PWRITE(mas_PWRITE), // from master
		.i_PWDATA(mas_PWDATA), // from master
		.o_PREADY(sl2_PREADY), // to arbiter
		.o_PRDATA(sl2_PRDATA), // to arbiter
		.o_PSLVERR(sl2_PSLVERR) // to arbiter
  );

  logic con_halt;

  controller_core #(
    DATA_WIDTH,
    ADDR_WIDTH,
    SEL_WIDTH
  ) core (
    .i_clk(i_PCLK),
    .i_rsn(n_PRESETn),
    .i_data_r(mas_data_r),
    .i_data_r_mem(mem_data_r),
    .o_halt(con_halt),

    .o_addr(con_addr_apb),
    .o_addr_mem(con_addr_mem),
    .o_slave_sel1(mas_PSEL1),
    .o_slave_sel2(mas_PSEL2),
    .o_en(con_en),
    .o_wr(con_wr_apb),
    .o_wr_mem(con_wr_mem),
    .o_data(con_data_w_apb),
    .o_data_mem(con_data_w_mem),
    .o_dump(con_dump)
  );


endmodule
