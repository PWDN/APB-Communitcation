module controller_core #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 16,
    parameter SEL_WIDTH = 2
  )(
    i_clk,
    i_rsn,
    i_data_r,
    i_data_r_mem,
    o_halt,

    o_addr,
    o_addr_mem,
    o_slave_sel1,
    o_slave_sel2,
    o_en,
    o_wr,
    o_wr_mem,
    o_data,
    o_data_mem,
    o_dump
  );
  input logic i_clk;
  input logic i_rsn;
  input logic [DATA_WIDTH-1:0] i_data_r;
  input logic [DATA_WIDTH-1:0] i_data_r_mem;
  output logic [ADDR_WIDTH-1:0] o_addr;
  output logic [ADDR_WIDTH-1:0] o_addr_mem;
  output logic o_slave_sel1;
  output logic o_slave_sel2;
  output logic o_en;
  output logic o_wr;
  output logic o_wr_mem;
  output logic [DATA_WIDTH-1:0] o_data;
  output logic [DATA_WIDTH-1:0] o_data_mem;
  output logic o_dump;
  output logic o_halt;
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
  logic write_to_slave;

  always_ff @ (*)
  begin
    if (current_ins == INS_LOAD)
      begin
        if(register_b >= 'hFF00)
          write_to_slave = 1;
      end
    else
      begin
        write_to_slave = 0;
      end
  end

  always_ff @(posedge i_clk or negedge i_rsn)
  begin
    if (!i_rsn)
      begin
        o_addr <= 0;
        o_addr_mem <= 0;
        o_slave_sel1 <= 0;
        o_slave_sel2 <= 0;
        o_en <= 0;
        o_wr <= 0;
        o_wr_mem <= 0;
        o_data <= 0;
        o_data_mem <= 0;
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
                  current_ins_addr <= o_addr_mem + 1;
                  o_addr_mem <= current_ins_addr;
                  hold_state <= 0; // we don't need to hold on that instruction for any longer;
                end
              INS_LOAD:
                begin
                  case (hold_state)
                    'd4:
                      begin
                        o_addr_mem <= o_addr_mem + 1;
                        hold_state <= 3;
                        register_a <= current_ins;
                        if (~write_to_slave)
                        begin
                          o_wr <= 0;
                          o_slave_sel1 <= current_ins[4];
                          o_slave_sel2 <= current_ins[5];
                          o_addr_mem <= current_ins[3:0];
                        end
                      end
                    'd3:
                      begin
                        o_addr_mem <= o_addr_mem + 1;
                        hold_state <= 2;
                        register_b <= current_ins;
                      end
                    'd2:
                      begin
                        o_addr_mem <= o_addr_mem + 1;
                        hold_state <= 1;
                        register_c <= current_ins;
                      end
                    'd1:
                      begin
                        o_addr_mem <= o_addr_mem + 1;
                        hold_state <= 0;
                        o_en <= 1;
                        if (write_to_slave)
                          begin
                            o_wr <= 1;
                            o_wr_mem <= 0;
                            o_addr <= register_b[3:0];
                            o_slave_sel1 <= register_b[4];
                            o_slave_sel2 <= register_b[5];
                            o_data <= register_c;
                          end
                        else
                          begin
                            o_wr <= 0;
                            o_wr_mem <= 1;
                            o_data <= register_c;    
                          end
                      end
                  endcase
                end
              INS_DUMP:
                begin
                  current_ins_addr <= o_addr_mem + 1;
                  o_addr_mem <= current_ins_addr;
                  hold_state <= 0;
                end
              INS_HALT: o_halt <= 1'b1;
              default: o_halt <= 1'b1;
              endcase
          end
      end
  end
endmodule
