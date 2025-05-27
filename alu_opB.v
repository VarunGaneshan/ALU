`include "defines.v"
module alu_opB (
    	enable, mode, cmd, opb, res, cout, oflow
);
    	input  wire                   enable;
    	input  wire                   mode;
    	input  wire [`CMD_WIDTH-1:0]  cmd;
    	input  wire [`OP_WIDTH-1:0]   opb;

    	output reg [`OP_WIDTH:0]      res;
    	output reg                    cout;
    	output reg                    oflow;

always @ (*) begin //{
	res = 0;
	cout = 0;
	oflow = 0;
	if (enable) begin //{	
		if (mode) begin //{
			case (cmd)
				`INC_B : begin //{
						res[`OP_WIDTH:0] = opb + 1;
						cout = res[`OP_WIDTH];
					 end //}

				default : begin //{
						res[`OP_WIDTH:0] = opb - 1;
						oflow = (opb == 0);
					 end //}
			endcase  
		end //}
		else begin //{
			case (cmd) 
				`NOT_B  : res[`OP_WIDTH-1:0] = ~opb;
				`SHR1_B : res[`OP_WIDTH-1:0] = opb >> 1;
		       		default : res[`OP_WIDTH-1:0] = opb <<1;	
			endcase 
		end //}
	end //}
	else begin //{
        	res = 0;
        	cout = 0;
        	oflow = 0;
	end //}
end //}
endmodule
