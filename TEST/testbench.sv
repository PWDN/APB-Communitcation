`timescale 1ns/1ps
`include "./DEFS/parameters.vh"

module testbench;
  parameter DATA_WIDTH = `DATA_WIDTH;
  parameter ADDR_WIDTH = `ADDR_WIDTH;
  parameter SEL_WIDTH  = `SEL_WIDTH;

  logic s_clk;
  // Memory_model #(
  //   ADDR_WIDTH,
  //   DATA_WIDTH,
  //   "./DATA/mem.data"
  // ) memory (
  //   .i_clk(s_clk),
  //   .i_en(s_en),
  //   .i_wr(s_wr),
  //   .i_addr(s_addr),
  //   .i_data_w(s_data_w),
  //   .o_data_r(s_data_r),
  //   .i_dump(s_dump)
  // );

  controller_wrapper #(
    2,
    ADDR_WIDTH,
    DATA_WIDTH
  ) wrap (
    .i_PCLK(s_clk)
  );

  always #1 s_clk <= ~s_clk;

  initial 
  begin
      $dumpfile("signals.vcd");  
      $dumpvars(0,testbench);
      s_clk = 0;

      #50; 
      $finish; 
  end  

endmodule
