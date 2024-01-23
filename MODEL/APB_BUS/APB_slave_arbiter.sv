module APB_slave_arbiter #(
	parameter DATA_WIDTH = 3,
	parameter ADDR_WIDTH = 16,
  parameter SEL_WIDTH = 2)(
      i_PSEL,
      i_PREADY,
      i_PWRITE,
      i_PRDATA,
      o_PREADY,
      o_PRDATA,
      o_PSLVERR);
 
	input logic [SEL_WIDTH-1:0] i_PSEL;
	input logic [SEL_WIDTH-1:0] i_PREADY;
	input logic i_PWRITE;
	input logic [(DATA_WIDTH * SEL_WIDTH)-1:0] i_PRDATA;
  output logic o_PREADY;
  output logic [DATA_WIDTH-1:0] o_PRDATA;
  output logic o_PSLVERR;

  always @ (*)
  begin
    if (i_PWRITE)
      begin
        o_PREADY = i_PSEL == i_PREADY;
        o_PRDATA = 0;
        o_PSLVERR = 0;
      end
    else
      begin
        o_PSLVERR = 0;
        o_PREADY = 1;
        case (i_PSEL)
          'd1: o_PRDATA = i_PRDATA[DATA_WIDTH-1:0];
          'd2: o_PRDATA = i_PRDATA[(DATA_WIDTH*2)-1:DATA_WIDTH];
          default: 
            begin
              o_PRDATA = 0;
              o_PREADY = 0;
            end
        endcase
      end
  end
endmodule
