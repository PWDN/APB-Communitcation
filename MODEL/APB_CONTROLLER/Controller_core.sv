module controller_core #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 16,
    parameter SEL_WIDTH = 2
  )(
    i_clk,
    i_rsn,
    i_data_r,
    o_halt,

    // FOR APB
    i_PREADY,
    i_PRDATA,
    i_PSLVERR,
    o_addr,
    o_slave_sel1,
    o_slave_sel2,
    o_PENABLE,
    o_PWRITE,
    o_PWDATA,
  );
  input logic i_clk;
  input logic i_rsn;
  input logic [DATA_WIDTH-1:0] i_data_r;
  input logic i_PREADY;
  input logic [DATA_WIDTH-1:0] i_PRDATA;
  output logic [ADDR_WIDTH-1:0] o_addr;
  output o_slave_sel1;
  output o_slave_sel2;
  output logic o_PENABLE;
  output logic o_PWRITE;
  output logic [DATA_WIDTH-1:0] o_PWDATA;

  // istructions
  localparam INS_NOOP = 'h0000; // NO OPeration
  localparam INS_LOAD = 'h0001; // Load FROM TO SOMETHING
  localparam INS_DUMP = 'h0002; // Dump to memory
  localparam INS_HALT = 'hffff; // Halt the CPU

  logic [DATA_WIDTH-1:0] current_ins = 0;
  logic [ADDR_WIDTH-1:0] current_ins_addr = 0;
  logic [3:0] hold_state = 0; // the amount of cycles the instruction should be kept;
  // for any instruction it's one, with the exception of load, which takes 3 cycles

  logic [DATA_WIDTH-1:0] register_a = 0;
  logic [DATA_WIDTH-1:0] register_b = 0;
  logic [DATA_WIDTH-1:0] register_c = 0;
  logic write_to_mem;

  always_ff
  begin
    if (current_ins == INS_LOAD)
      begin
        if(register_a >= 'hFF00)
          write_to_mem = 0;
      end
    else
      begin
        write_to_mem = 1;
      end
  end

  always_ff @(posedge i_clk or negedge i_rsn)
  begin
    if (!i_rsn)
      begin
        o_PADDR <= 0;
        o_PSEL <= 0;
        o_PENABLE <= 0;
        o_PWRITE <= 0;
        o_PWDATA <= 0;
      end
    else
      begin
        if (!o_halt)
          begin
            if (hold_state == 0)
              begin
                current_ins <= i_data_r;
              end
            case (current_ins)
              INS_NOOP:
                begin
                  current_ins_addr <= o_PADDR + 1;
                  o_PADDR <= current_ins_addr;
                  hold_state <= 0; // we don't need to hold on that instruction for any longer;
                end;
              INS_LOAD:
                begin
                  case (hold_state)
                    'd4:
                      begin
                        o_PADDR <= o_PADDR + 1;
                        hold_state <= 3;
                        register_a <= current_ins;
                      end
                    'd3:
                      begin
                        o_PADDR <= o_PADDR + 1;
                        hold_state <= 2;
                        register_b <= current_ins;
                      end
                    'd2:
                      begin
                        o_PADDR <= o_PADDR + 1;
                        hold_state <= 1;
                        register_c <= current_ins;
                      end
                    'd1:
                      begin
                        o_PADDR <= o_PADDR +1;
                        hold_state <= 0;
                        o_PENABLe <= 1;
                        if (write_to_mem)
                          begin
                            o_PWRITE <= 0;
                            
                          end
                        else
                          begin
                            o_PWRITE <= 1;
                          end
                      end
                  endcase
                end
              endcase
          end
      end
  end


endmodule
