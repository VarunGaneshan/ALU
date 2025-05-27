`include "defines.v"
module alu_opA (
    	enable, mode, cmd, opa, res, cout, oflow
);
    	input  wire                  enable;
    	input  wire                  mode;
    	input  wire [`CMD_WIDTH-1:0] cmd;
    	input  wire [`OP_WIDTH-1:0]  opa;

        output reg [`OP_WIDTH:0]     res;
    	output reg                   cout;
    	output reg                   oflow;

always @ (*) begin //{
	res = 0;
	cout = 0;
	oflow = 0;
	if (enable) begin //{	
		if (mode) begin //{
			case (cmd)
				`INC_A : begin //{
						res[`OP_WIDTH:0] = opa + 1;
						cout = res[`OP_WIDTH];
					 end //}

				default : begin //{
						res[`OP_WIDTH:0] = opa - 1;
						oflow = (opa == 0);
					 end //}
			endcase  
		end //}
		else begin //{
			case (cmd) 
				`NOT_A  : res[`OP_WIDTH-1:0] = ~opa; //-1 in range
				`SHR1_A : res[`OP_WIDTH-1:0] = opa >> 1;
		       		default : res[`OP_WIDTH-1:0] = opa <<1;	
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
