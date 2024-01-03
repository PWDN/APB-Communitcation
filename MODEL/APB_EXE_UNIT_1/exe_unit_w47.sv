module exe_unit_w47( i_argA, i_argB, i_oper, i_clk, i_rsn, o_result , o_status);

	parameter MBIT = 4;
	parameter NBIT = 2;

	input logic 		i_clk;
	input logic 		i_rsn;

	input logic [MBIT-1:0] i_argA;
	input logic [MBIT-1:0] i_argB;
	input logic [NBIT-1:0] i_oper;

	output logic [MBIT-1:0] o_result;
	output logic [3:0] 	o_status; 	

	
	logic [MBIT-1:0] s_result;
	logic 	ERROR;
	logic 	ODD;
	logic 	ZERO;
	logic 	NEG;

	int i;
	
	initial begin 
		o_status = '0;
		ERROR 	=	 0;
		ODD 	=	 0;
		ZERO 	=	 0;
		NEG 	=	 0;
		s_result 	= 'x;

	end

	always_comb 

	begin 
		s_result = 'x;		
		ODD = 0;	 
		ERROR = 0;

		case (i_oper)
			2'b00 :	begin 
					s_result = i_argB;			//operacja 1 odwracanie arg_A 
			      		s_result[MBIT-1] = ~i_argB[MBIT-1];
				end
			2'b01 : begin 						// operacja 2 porownanie liczb ZnMod
					if ((i_argA << 1) >= (i_argB << 1))	// A>=B po modulu
					begin
						if (i_argA[MBIT-1]==0)
						begin
							s_result = i_argA;
						end
						else if ((i_argB[MBIT-1]==0) & ((i_argA[MBIT-1])==1) | (i_argA[MBIT-1]==0))
						begin
							s_result = i_argB;
						end 
						else 
						begin
							s_result = '0;
						end
					end
					else if ((i_argA << 1) < (i_argB << 1))	// A<B po modulu
					begin 
						if ((i_argA[MBIT-1] == 0) & (i_argB[MBIT-1] == 0))
						begin
							s_result = i_argB;
						end
						else if ((i_argA[MBIT-1] == 0) & (i_argB[MBIT-1] == 1))
						begin
							s_result = i_argA; 
						end
						else 
						begin	
							s_result = '0;
						end
					end 
					else 
					begin
						s_result = '0;
					end
				end
			2'b10 : begin	
					s_result =  'x;			//operacja 3 ustawienie A_bitu
					
				if (i_argB[MBIT-1] == 1 )
				begin 			
				s_result = '0;
				ERROR = 1; 			//bland					
				end
				else if (i_argB[MBIT-1] == 0) 
				begin
					if (i_argB < MBIT)
						begin
						s_result = i_argA;
						s_result[i_argB] = 0;
						end
					else  if (i_argB >= MBIT)
						begin
						s_result = '0;
						ERROR = 1;			// balnd
						end 
					else 
						begin
						s_result = 'x;			// force else
						end
				end
				end		
			2'b11 : begin 			
						s_result = 'bx;			// operacja 4 ZnMod -> U2
					if (i_argA[MBIT-1] == 0)  
						begin		
						s_result = i_argA;
						end
					else if ((i_argA[MBIT-1] == 1) & ((i_argA << 1) == '0)) // zero minus filter
						begin
						s_result = 'bx;			// eerrorr
						ERROR = 1;			// blad
						end 
					else if (i_argA[MBIT-1] == 1)
						begin
						s_result = (i_argA - 'b1);
						s_result[MBIT-1] = ~i_argA[MBIT-1];
						s_result = ~s_result;
						end
					else 
						begin
						s_result = 'x;			// force else
						end
				end
		      default : s_result = 'x;  
		endcase

	if (s_result == '0 )
		begin 
		ZERO = 1'b1;
		end
	else if (s_result != '0)
		begin
		ZERO = 0;
		end
	else 
		begin
		ZERO = 0; 
		end	

	if (s_result[MBIT-1] == 1)
		begin
		NEG = 1'b1;
		end
	else if (s_result[MBIT-1] != 1)
		begin 
		NEG = 0;
		end
	else 
		begin 
		NEG = 0;
		end
	
	for (i = 0; i <MBIT; i = i+1 )
	begin
		if (s_result[i] == 1)
			begin
			ODD = ~ODD;	
			end
		else if (s_result[i] != 1)
			begin
			ODD = ODD;
			end
		else 
			begin 
			ODD = ODD;
			end
	end
	
	end

	always @(posedge i_clk,negedge i_rsn)
	begin 
		if (i_rsn == 0) 
		begin 
			o_status = '0;
			o_result = '0;
		end 
		else 
		begin 
			o_result <= s_result;
			o_status <= {ERROR, ODD, ZERO, NEG};
		end
	end


endmodule
