`timescale 1ns / 1ps

module Memory_model #(
   parameter   ADDR_WIDTH        = 16,             // memory address size – memory depth = 2^ADDR_WIDTH
   parameter   DATA_WIDTH        = 16,             // memory data width
   parameter   MEMORY_FILE       = "mem.data",     // file containing dump of instruction and data memory
   parameter   MEMORY_DUMP_FILE  = "mem_dump.data" // file containing dump of instruction and data memory
)(
   input  wire                   i_clk,            // clock signal
   input  wire                   i_en,             // enable
   input  wire                   i_wr,             // '1' - write, '0' - read

   input  wire[ADDR_WIDTH-1:0]   i_addr,           // address bus
   input  wire[DATA_WIDTH-1:0]   i_data_w,         // write data bus
   output reg [DATA_WIDTH-1:0]   o_data_r,         // read data bus
   
   input  wire                   i_dump            // '1' to dump memory contents to MEMORY_DUMP_FILE
);

reg [DATA_WIDTH-1:0] memory [0:(1<<ADDR_WIDTH)-1];

initial begin
   $readmemh(MEMORY_FILE, memory);
end

always @(posedge i_clk) begin
   if (i_en & !i_wr) 
   begin
      if (!i_wr)
         o_data_r         <= memory[i_addr];
      else
         memory[i_addr]   <= i_data_w;
   end 
   if (i_dump)
      $writememh(MEMORY_DUMP_FILE, memory);
end 

endmodule
