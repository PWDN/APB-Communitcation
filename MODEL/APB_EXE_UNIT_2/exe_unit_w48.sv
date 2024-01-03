module exe_unit_w48 (
                     i_oper,
                     i_argA,
                     i_argB,
                     i_clk,
                     i_rsn,
                     o_result,
                     o_status);
  parameter WIDTH_ARG = 8;
  parameter WIDTH_OPER = 2;
  input logic [WIDTH_OPER-1:0] i_oper;
  input logic [WIDTH_ARG-1:0]  i_argA;
  input logic [WIDTH_ARG-1:0]  i_argB;
  input logic [0:0]            i_clk;
  input logic [0:0]            i_rsn;
  output logic [WIDTH_ARG-1:0] o_result;
  output logic [3:0]           o_status;

  logic [WIDTH_ARG-1:0]        next_result;
  logic [0:0]                  next_error;

  always @ (*)
  begin
    case (i_oper)
      2'b00 :
        begin
          next_result = i_argA + i_argB;
          next_error = 1'b0; // The result can't provide any error;
        end
      2'b01 :
        begin
          next_error = 1'b0; // The result can't provide any error;
          if (i_argB[WIDTH_ARG-1])
              next_result = 0;
          else if (i_argA[WIDTH_ARG-1] || i_argB >= i_argA)
              next_result = i_argB;
          else
              next_result = 0;
        end
      2'b10 :
        begin
          next_error = i_argB[WIDTH_ARG-1] || i_argB > WIDTH_ARG;
          next_result = (~i_argB[WIDTH_ARG-1]) & (i_argA | ((|i_argB) << (i_argB - 1))); 
        end
      2'b11 : 
        begin
          if (i_argA[WIDTH_ARG-1] == 0)
            begin
              next_result = i_argA;
              next_error = 1'b0;
            end
          else
            if (~|i_argA[WIDTH_ARG-2:0])
              begin
                next_result = 'bx;
                next_error = 1'b1;
              end
            else
              begin
                next_result = {1'b1, (~i_argA[WIDTH_ARG-2:0]) + {{WIDTH_ARG-1{1'b0}},  1'b1}};
                next_error = 1'b0;
              end
        end
    endcase
  end

  always_ff @ (posedge i_clk, negedge i_rsn)
  begin
    if (i_rsn == 0)
      begin
        o_result <= 0;
        o_status <= 0;
      end
    else
      begin
        o_result <= next_result;
        o_status <= {
          next_error,
          ~|next_result,
          next_result[WIDTH_ARG-1],
          ~^next_result && &next_result
        };
      end
  end
  
endmodule
