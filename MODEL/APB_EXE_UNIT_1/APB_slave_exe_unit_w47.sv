module apb_slave_exe_w47 #(
	parameter DATA_WIDTH = 3,
	parameter ADDR_WIDTH = 16)(
			i_PCLK,
			i_PRESETn,
			i_PADDR,
			i_PSEL,
			i_PENABLE,
			i_PWRITE,
			i_PWDATA,
			o_READY,
			o_PRDATA,
			o_PSLVERR);

	input logic i_PCLK;
	input logic i_PRESETn;
	input logic [ADDR_WIDTH-1:0] i_PADDR;
	input logic i_PSEL;
	input logic i_PENABLE;
	input logic i_PWRITE;
	input logic [DATA_WIDTH-1:0] i_PWDATA;
  output logic o_PREADY;
  output logic [DATA_WIDTH-1:0] o_PRDATA;
  output logic o_PSLVERR;

	logic [DATA_WIDTH-1:0] s_in_oper;
	logic [DATA_WIDTH-1:0] s_in_argA;
	logic [DATA_WIDTH-1:0] s_in_argB;
	logic [DATA_WIDTH-1:0] s_model_outs;
	logic [3:0] s_model_status;

  exe_unit_w47  #(.MBIT(DATA_WIDTH), 
                  .NBIT(DATA_WIDTH))    exe_unit_w48_model (.i_oper(s_in_oper), 
                                                       .i_argA(s_in_argA),
                                                       .i_argB(s_in_argB),
                                                       .i_clk(s_in_clk),
                                                       .i_rsn(s_in_rsn),
                                                       .o_result(s_model_outs),
                                                       .o_status(s_model_status));

	always_ff @ (posedge i_PCLK or negedge i_PRESETn)
	begin
		if (~i_PRESETn)
			begin
				o_READY <= 0;
				o_PRDATA <= 0;
				o_PSLVERR <= 0;
			end
		else
			begin
				if (i_PENABLE && i_PSEL)
					begin
						if (i_PWRITE) // Write
							begin
								case (i_PADDR)
									0: s_in_oper <= i_PWDATA;
									1: s_in_argA <= i_PWDATA;
									2: s_in_argA <= i_PWDATA;
								endcase
								o_READY <= 1;
								o_PRDATA <= 0;
								o_PSLVERR <= 0;
							end
						else // Read
							begin
								case (i_PADDR)
									0: o_PRDATA <= s_model_outs;
									1: o_PRDATA <= { {(DATA_WIDTH-4){1'b0}}, s_model_status[3:0] };
									default: o_PRDATA <= 0;
								endcase
								o_READY <= 1;
								o_PSLVERR <= 0;
							end
					end
				else
					begin
						o_READY <= 0;
						o_PRDATA <= 0;
						o_PSLVERR <= 0;
					end
			end
	end
endmodule
