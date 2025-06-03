`include "defines.v"
module alu_two_op (
	enable, mode, cmd, opa, opb, cin, res, cout, oflow, err, g, l, e
);	
    	input  wire                 enable;
    	input  wire                 mode;
    	input  wire [`CMD_WIDTH-1:0] cmd;
    	input  wire [`OP_WIDTH-1:0]  opa;
    	input  wire [`OP_WIDTH-1:0]  opb;
    	input  wire                  cin;

	`ifdef MUL_OP
    		output reg [(2*`OP_WIDTH)-1:0] res;
	`else
    		output reg [`OP_WIDTH:0]       res;
	`endif
    	output reg                    cout;
   	    output reg                    oflow;
    	output reg                    err;
    	output reg                    g;
    	output reg                    l;
    	output reg                    e;
    	
reg [`OP_WIDTH-1:0] temp_sh;
localparam ROT_WIDTH = $clog2(`OP_WIDTH); //8 - 3
wire [ROT_WIDTH-1:0] rot_amt = opb[ROT_WIDTH-1:0]; //[2:0]
wire opb_err_bits = |opb[`OP_WIDTH-1:ROT_WIDTH+1]; //[7:4]
	
always @ (*) begin //{
	res = 0;
	cout = 0;
	oflow = 0;
	err = 0;
	g = 0;
	l = 0;
	e = 0;
	if (enable) begin //{	
		if (mode) begin //{
			case (cmd)
				`ADD : begin //{
						res[`OP_WIDTH:0] = opa + opb;
						cout = res[`OP_WIDTH];
				       end //}

				`SUB : begin //{
						res[`OP_WIDTH:0] = opa - opb;
						oflow = (opa < opb) ? 1 : 0;
				       end //}

                `ADD_CIN : begin //{
                        res[`OP_WIDTH:0] = opa + opb + cin;
                        cout = res[`OP_WIDTH];
                        end //}

                `SUB_CIN : begin //{
                        res[`OP_WIDTH:0] = opa - opb - cin;
                        oflow = (opa < opb || (opa==opb && cin==1)) ? 1 : 0;
                        end //}

				`CMP : begin //{
						g = opa > opb;
						l = opa < opb;
						e = opa == opb;
				        end //}

			 	`INC_MUL : begin //{
					    res = (opa + 1) * (opb + 1);
					    end //}

                `SHL_MUL : begin //{
                        temp_sh = opa << 1; //255 << 1 - 510 
                        res = temp_sh * opb;
                        end //}

                `ADD_SIGN : begin //{
                         res[`OP_WIDTH:0] = $signed(opa) + $signed(opb);
                         cout = res[`OP_WIDTH];
						 oflow = (opa[`OP_WIDTH-1] == opb[`OP_WIDTH-1]) && (res[`OP_WIDTH-1] != opa[`OP_WIDTH-1]);
						 g = ($signed(opa) > $signed(opb));
                         l = ($signed(opa) < $signed(opb));
                         e = ($signed(opa) == $signed(opb));
                         end //}

                default : begin //{
                           //`SUB_SIGN 
                           res[`OP_WIDTH:0] = $signed(opa) - $signed(opb);
                           oflow = (opa[`OP_WIDTH-1] != opb[`OP_WIDTH-1]) && (res[`OP_WIDTH-1] != opa[`OP_WIDTH-1]);
					       g = ($signed(opa) > $signed(opb));
                           l = ($signed(opa) < $signed(opb));
                           e = ($signed(opa) == $signed(opb));    
					       end //}
			endcase  
		end //}
		else begin //{
			case (cmd) 
                		`AND    : res[`OP_WIDTH-1:0] = opa & opb;
                		`NAND   : res[`OP_WIDTH-1:0] = ~(opa & opb);
                		`OR     : res[`OP_WIDTH-1:0] = opa | opb;
                		`NOR    : res[`OP_WIDTH-1:0] = ~(opa | opb);
                		`XOR    : res[`OP_WIDTH-1:0] = opa ^ opb;
                		`XNOR   : res[`OP_WIDTH-1:0] = ~(opa ^ opb);
				        `ROL    : begin //{
					  	          if(opb_err_bits) begin //{
							             err = 1;
						          end //}
						          res[`OP_WIDTH-1:0] = (opa << rot_amt) | (opa >> (`OP_WIDTH - rot_amt)); //similar to {opa[0],opa[7:1]}
					              end //}
                        //`ROR
                        default    : begin //{
                                           if(opb_err_bits) begin //{
                                                 err = 1;
                                           end //}
                                           res[`OP_WIDTH-1:0] = (opa >> rot_amt) | (opa << (`OP_WIDTH - rot_amt));
                                    end //}
			endcase 
		end //}
	end //}
	else begin //{
	        res = 0;
        	cout = 0;
        	oflow = 0;
        	err = 0;
        	g = 0;
        	l = 0;
        	e = 0;	
	end //}
end //}
endmodule
