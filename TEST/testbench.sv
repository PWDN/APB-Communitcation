`timescale 100ms/1ms
`include "../DEFS/parameters.vh"

module testbench(
 parameter DATA_WIDTH = `DATA_WIDTH,
 parameter ADDR_WIDTH = `ADDR_WIDTH,
 parameter SEL_WIDTH  = `SEL_WIDTH
);
  logic main_clk, main_rsn = '1;


  always #`CLK_STEP main_clk <= ~main_clk;

  initial 
  begin 


      $dumpfile("signals.vcd");  
      $dumpvars(0,testbench);     
      
                           
 
      $finish; 
  end  

endmodule
