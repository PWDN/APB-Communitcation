`timescale 1ns/1ps
`include "./DEFS/parameters.vh"

module testbench;
  parameter DATA_WIDTH = `DATA_WIDTH;
  parameter ADDR_WIDTH = `ADDR_WIDTH;
  parameter SEL_WIDTH  = `SEL_WIDTH;

  logic s_clk;
  logic s_en;
  logic s_wr;
  logic [ADDR_WIDTH-1:0] s_addr;
  logic [DATA_WIDTH-1:0] s_data_w;
  logic [DATA_WIDTH-1:0] s_data_r;
  logic s_dump;

  Memory_model #(
    ADDR_WIDTH,
    DATA_WIDTH,
    "./DATA/mem.data"
  ) memory (
    .i_clk(s_clk),
    .i_en(s_en),
    .i_wr(s_wr),
    .i_addr(s_addr),
    .i_data_w(s_data_w),
    .o_data_r(s_data_r),
    .i_dump(s_dump)
  );

  always #1 s_clk <= ~s_clk;

  initial 
  begin
      $dumpfile("signals.vcd");  
      $dumpvars(0,testbench);
      s_clk = 0;
      s_en = 0;
      s_wr = 0;
      s_addr = 0;
      s_data_w = 0;
      s_dump = 0;
      #1;
      s_en = 1;

      #3;
      s_addr = 16'b01;

      #10;
 
      $finish; 
  end  

endmodule
