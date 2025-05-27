`timescale 1ns/1ps
`include "defines.v"
`include "alu_top.v"

module alu_top_tb;

    	reg                     clk, rst, ce, mode, cin;
    	reg [1:0]               inp_valid;
    	reg [`CMD_WIDTH-1:0]    cmd;
    	reg [`OP_WIDTH-1:0]     opa, opb;

    	`ifdef MUL_OP
        	wire [(2*`OP_WIDTH)-1:0] res;
    	`else
        	wire [`OP_WIDTH:0] res;
    	`endif
    		wire cout, oflow, g, l, e, err;

    	alu_top dut (
        	.clk(clk), .rst(rst), .ce(ce), .inp_valid(inp_valid), .mode(mode),
        	.cmd(cmd), .cin(cin), .opa(opa), .opb(opb),
        	.res(res), .cout(cout), .oflow(oflow), .g(g), .l(l), .e(e), .err(err)
    	);

    	always #5 clk = ~clk;
     
    	function is_two_op;
        	input [`CMD_WIDTH-1:0] c;
        	input m;
        	begin //{
            		if (m == 1)
                		is_two_op = (c == `ADD || c == `SUB || c == `ADD_CIN || c == `SUB_CIN || c == `CMP || c == `INC_MUL || c == `SHL_MUL || c == `ADD_SIGN || c == `SUB_SIGN);
            		else
                		is_two_op = (c == `AND || c == `NAND || c == `OR || c == `NOR || c == `XOR || c == `XNOR || c == `ROL || c == `ROR);
        	end //}
    	endfunction

    	function integer get_delay_cycles;
    		input [`CMD_WIDTH-1:0] cmd;
    		input       mode;
    		begin //{
        	if (mode && (cmd == `INC_MUL || cmd == `SHL_MUL))
            		get_delay_cycles = 4;
        	else
            		get_delay_cycles = 3;
    		end
    	endfunction //}

	// Sequencer
    	task auto_test_vec;
    		input [127:0] testname;
    		input         rst_v, ce_v;
    		input [1:0]   inp_valid_v;
    		input         mode_v;
    		input [`CMD_WIDTH-1:0] cmd_v;
    		input [`OP_WIDTH-1:0]  opa_v, opb_v;
    		input         cin_v;
    		integer delay;
    		begin //{
        		delay = get_delay_cycles(cmd_v, mode_v);
        		test_vec(testname, rst_v, ce_v, inp_valid_v, mode_v, cmd_v, opa_v, opb_v, cin_v, delay);
    		end //}
    	endtask

    	// Reference Model 
    	task ref_model;
        	input [1:0]   t_inp_valid;
        	input         t_mode;
        	input [`CMD_WIDTH-1:0] t_cmd;
        	input [`OP_WIDTH-1:0]  t_opa, t_opb;
        	input         t_cin;
        	output t_res;
        	`ifdef MUL_OP
        		reg [(2*`OP_WIDTH)-1:0] t_res;
    		`else
        		reg [`OP_WIDTH:0] t_res;
    		`endif
        	output reg    t_cout, t_oflow, t_g, t_l, t_e, t_err;
		integer rot_amt;
		reg opb_err_bits;
        	begin //{
            		t_res = 0; t_cout = 0; t_oflow = 0; t_g = 0; t_l = 0; t_e = 0; t_err = 0;

            		// Error checking
            		if      ((t_mode && (t_cmd > `SUB_SIGN)) || (!t_mode && (t_cmd > `ROR))) 
                		t_err = 1;
            		else if (t_mode && ((t_cmd == `INC_A || t_cmd == `DEC_A) && !t_inp_valid[0] ))
                		t_err = 1;
            		else if (t_mode && ((t_cmd == `INC_B || t_cmd == `DEC_B) && !t_inp_valid[1] ))
                		t_err = 1;
            		else if (t_mode && (t_cmd <= `SHL_MUL) && is_two_op(t_cmd, t_mode) && (t_inp_valid != 2'b11))
                		t_err = 1;
            		else if (!t_mode && ((t_cmd == `NOT_A || t_cmd == `SHL1_A || t_cmd == `SHR1_A) && !t_inp_valid[0]))
                		t_err = 1;
            		else if (!t_mode && ((t_cmd == `NOT_B || t_cmd == `SHL1_B || t_cmd == `SHR1_B) && !t_inp_valid[1]))
                		t_err = 1;
            		else if (!t_mode && is_two_op(t_cmd, t_mode) && (t_inp_valid != 2'b11))
                		t_err = 1;

            		if (t_err) begin //{
    				t_res = 0; t_cout = 0; t_oflow = 0; t_g = 0; t_l = 0; t_e = 0;
	    		end //}
			else if (t_mode) begin //{
  	    			case (t_cmd)
    					`ADD      : begin t_res[`OP_WIDTH:0] = t_opa + t_opb; t_cout = t_res[`OP_WIDTH]; end
    					`SUB      : begin t_res[`OP_WIDTH:0] = t_opa - t_opb; t_oflow = (t_opa < t_opb); end
    					`ADD_CIN  : begin t_res[`OP_WIDTH:0] = t_opa + t_opb + t_cin; t_cout = t_res[`OP_WIDTH]; end
    					`SUB_CIN  : begin t_res[`OP_WIDTH:0] = t_opa - t_opb - t_cin; t_oflow = (t_opa < t_opb || (t_opa==t_opb && t_cin==1)); end
    					`CMP      : begin t_g = (t_opa > t_opb); t_l = (t_opa < t_opb); t_e = (t_opa == t_opb); t_res = 0; end
    					`INC_A    : begin t_res[`OP_WIDTH:0] = t_opa + 1; t_cout = t_res[`OP_WIDTH]; end
    					`DEC_A    : begin t_res[`OP_WIDTH:0] = t_opa - 1; t_oflow = (t_opa == 0); end
    					`INC_B    : begin t_res[`OP_WIDTH:0] = t_opb + 1; t_cout = t_res[`OP_WIDTH]; end
    					`DEC_B    : begin t_res[`OP_WIDTH:0] = t_opb - 1; t_oflow = (t_opb == 0); end
    					`INC_MUL  : begin t_res = (t_opa + 1) * (t_opb + 1); end
    					`SHL_MUL  : begin t_res = (t_opa << 1) * t_opb; end
    					`ADD_SIGN : begin 
        					t_res[`OP_WIDTH:0] = $signed(t_opa) + $signed(t_opb);
        					t_oflow = (($signed(t_opa)>0 && $signed(t_opb)>0 && $signed(t_res[`OP_WIDTH-1:0])<0) || ($signed(t_opa)<0 && $signed(t_opb)<0 && $signed(t_res[`OP_WIDTH-1:0])>=0));
        					t_g = ($signed(t_opa) > $signed(t_opb));
        					t_l = ($signed(t_opa) < $signed(t_opb));
        					t_e = ($signed(t_opa) == $signed(t_opb));
    				        end
   
				       	`SUB_SIGN : begin
        					t_res[`OP_WIDTH:0] = $signed(t_opa) - $signed(t_opb);
       	 					t_oflow = (($signed(t_opa)>0 && $signed(t_opb)<0 && $signed(t_res[`OP_WIDTH-1:0])<0) || ($signed(t_opa)<0 && $signed(t_opb)>0 && $signed(t_res[`OP_WIDTH-1:0])>=0));
        					t_g = ($signed(t_opa) > $signed(t_opb));
        					t_l = ($signed(t_opa) < $signed(t_opb));
       						t_e = ($signed(t_opa) == $signed(t_opb));
    					end 
    				endcase
			end //}
		       	else begin //{
    				rot_amt = t_opb[$clog2(`OP_WIDTH)-1:0];
    				opb_err_bits = |t_opb[`OP_WIDTH-1:$clog2(`OP_WIDTH)];
    				case (t_cmd)
    					`AND   : t_res[`OP_WIDTH-1:0] = t_opa & t_opb;
    					`NAND  : t_res[`OP_WIDTH-1:0] = ~(t_opa & t_opb);
    					`OR    : t_res[`OP_WIDTH-1:0] = t_opa | t_opb;
   					`NOR   : t_res[`OP_WIDTH-1:0] = ~(t_opa | t_opb);
    					`XOR   : t_res[`OP_WIDTH-1:0] = t_opa ^ t_opb;
    					`XNOR  : t_res[`OP_WIDTH-1:0] = ~(t_opa ^ t_opb);
    					`ROL: begin
        					if (opb_err_bits)
            						t_err = 1;
        					t_res[`OP_WIDTH-1:0] = (t_opa << rot_amt) | (t_opa >> (`OP_WIDTH - rot_amt));
    					end
    
					`ROR: begin
        					if (opb_err_bits)
            						t_err = 1;
        					t_res[`OP_WIDTH-1:0] = (t_opa >> rot_amt) | (t_opa << (`OP_WIDTH - rot_amt));
    					end
    					`NOT_A : t_res[`OP_WIDTH-1:0] = ~t_opa;
    					`NOT_B : t_res[`OP_WIDTH-1:0] = ~t_opb;
    					`SHR1_A: t_res[`OP_WIDTH-1:0] = t_opa >> 1;
    					`SHL1_A: t_res[`OP_WIDTH-1:0] = t_opa << 1;
    					`SHR1_B: t_res[`OP_WIDTH-1:0] = t_opb >> 1;
    					`SHL1_B: t_res[`OP_WIDTH-1:0] = t_opb << 1;
    				endcase
            		end //}
        	end //}
    	endtask

    	integer pass, fail, testnum;

	task test_vec;
    		input [127:0] testname;
    		input reg rst_v, ce_v;
    		input [1:0] inp_valid_v;
    		input mode_v;
   	 	input [`CMD_WIDTH-1:0] cmd_v;
    		input [`OP_WIDTH-1:0] opa_v, opb_v;
    		input cin_v;
    		input [2:0] delay_cycles;
    		`ifdef MUL_OP
        		reg [(2*`OP_WIDTH)-1:0] exp_res,exp_res_last;
    		`else
        		reg [`OP_WIDTH:0] exp_res,exp_res_last;
    		`endif
    		reg exp_cout, exp_oflow, exp_g, exp_l, exp_e, exp_err;
    		reg exp_cout_last, exp_oflow_last, exp_g_last, exp_l_last, exp_e_last, exp_err_last;
    		integer k;
		begin //{
    			// Driver
    			rst = rst_v; ce = ce_v; inp_valid = inp_valid_v; mode = mode_v; cmd = cmd_v; opa = opa_v; opb = opb_v; cin = cin_v;
    			for (k = 0; k < delay_cycles; k = k + 1) @(posedge clk); //Wait for DUT op-Monitor

    			if (rst_v) begin //{
        			exp_res    = 0;
        			exp_cout   = 0;
        			exp_oflow  = 0;
        			exp_g      = 0;
        			exp_l      = 0;
        			exp_e      = 0;
        			exp_err    = 0;
    			end //}
		       	else if (!ce_v) begin //{
        		// Hold
       	 			exp_res    = exp_res_last;
        			exp_cout   = exp_cout_last;
        			exp_oflow  = exp_oflow_last;
        			exp_g      = exp_g_last;
        			exp_l      = exp_l_last;
        			exp_e      = exp_e_last;
       			 	exp_err    = exp_err_last;
    			end //}
		       	else begin //{
        			ref_model(inp_valid_v, mode_v, cmd_v, opa_v, opb_v, cin_v, exp_res, exp_cout, exp_oflow, exp_g, exp_l, exp_e, exp_err);
    			end //}

    			// Checker
    			if ((res === exp_res) && (cout === exp_cout) && (oflow === exp_oflow) && (g === exp_g) && (l === exp_l) && (e === exp_e) && (err === exp_err)) begin
        			$display("[PASS] %s", testname);
        			pass = pass + 1;
    			end else begin
        			$display("[FAIL] %s  Got: res=%h cout=%b oflow=%b g=%b l=%b e=%b err=%b  Exp: res=%h cout=%b oflow=%b g=%b l=%b e=%b err=%b",testname, res, cout, oflow, g, l, e, err, exp_res, exp_cout, exp_oflow, exp_g, exp_l, exp_e, exp_err);
        			fail = fail + 1;
    			end 
    			testnum = testnum + 1;

    			// Save last outputs for !CE check
    			exp_res_last   = exp_res;
   	 		exp_cout_last  = exp_cout;
    			exp_oflow_last = exp_oflow;
    			exp_g_last     = exp_g;
    			exp_l_last     = exp_l;
    			exp_e_last     = exp_e;
    			exp_err_last   = exp_err;
		end //}
	endtask 

    	//Sequences
	initial begin //{
    		clk = 0; rst = 1; ce = 0; inp_valid = 0; mode = 0; cmd = 0; opa = 0; opb = 0; cin = 0;
    		pass = 0; fail = 0; testnum = 1;
    		#10; rst = 0;
    		//testname,rst_v, ce_v,inp_valid_v,mode_v,cmd_v,opa_v, opb_v, cin_v;
   	 	auto_test_vec("ADD",       	0, 1, 2'b11, 1, `ADD,      8'd10, 8'd20, 0);
    		//$display("[%0t]",$time);
    		auto_test_vec("SUB",       	0, 1, 2'b11, 1, `SUB,      8'd25, 8'd10, 0);
    		auto_test_vec("ADD_CIN",   	0, 1, 2'b11, 1, `ADD_CIN,  8'd5,  8'd7,  1);
    		auto_test_vec("SUB_CIN",   	0, 1, 2'b11, 1, `SUB_CIN,  8'd20, 8'd4,  1);
    		auto_test_vec("CMP_EQ",    	0, 1, 2'b11, 1, `CMP,      8'd10, 8'd10, 0);
    		auto_test_vec("CMP_GT",    	0, 1, 2'b11, 1, `CMP,      8'd15, 8'd10, 0);
    		auto_test_vec("CMP_LT",    	0, 1, 2'b11, 1, `CMP,      8'd7,  8'd20, 0);
    		auto_test_vec("INC_A",     	0, 1, 2'b01, 1, `INC_A,    8'd8,  0,     0);
    		auto_test_vec("DEC_A",     	0, 1, 2'b01, 1, `DEC_A,    8'd8,  0,     0);
    		auto_test_vec("INC_B",     	0, 1, 2'b10, 1, `INC_B,    0,     8'd4,  0);
    		auto_test_vec("DEC_B",     	0, 1, 2'b10, 1, `DEC_B,    0,     8'd9,  0);
    		auto_test_vec("NOT_A",     	0, 1, 2'b01, 0, `NOT_A,    8'hAA, 0,     0);
    		auto_test_vec("SHL1_A",    	0, 1, 2'b01, 0, `SHL1_A,   8'h05, 0,     0);
    		auto_test_vec("SHR1_A",    	0, 1, 2'b01, 0, `SHR1_A,   8'h08, 0,     0);
    		auto_test_vec("AND",       	0, 1, 2'b11, 0, `AND,      8'hF0, 8'h0F, 0);
    		auto_test_vec("OR",        	0, 1, 2'b11, 0, `OR,       8'hF0, 8'h0F, 0);
    		auto_test_vec("XOR",       	0, 1, 2'b11, 0, `XOR,      8'hF0, 8'h0F, 0);
    		auto_test_vec("INC_MUL",   	0, 1, 2'b11, 1, `INC_MUL,  8'd8,  8'd2,  0);
    		auto_test_vec("SHL_MUL",  	0, 1, 2'b11, 1, `SHL_MUL,  8'd3,  8'd2,  0);
    		auto_test_vec("ROL",       	0, 1, 2'b11, 0, `ROL,      8'h81, 8'd1,  0);
    		auto_test_vec("ROR",      	0, 1, 2'b11, 0, `ROR,      8'h03, 8'd1,  0);
    		auto_test_vec("ADD_SIGN1", 	0, 1, 2'b11, 1, `ADD_SIGN, 8'd50, -8'd10,0);
   		auto_test_vec("SUB_SIGN1", 	0, 1, 2'b11, 1, `SUB_SIGN, 8'd70, 8'd20, 0);
    		auto_test_vec("SUB_SIGN2", 	0, 1, 2'b11, 1, `SUB_SIGN, -8'd10,8'd20, 0);
    		auto_test_vec("NAND",      	0, 1, 2'b11, 0, `NAND,     8'hAA, 8'h0F, 0);
    		auto_test_vec("NOR",       	0, 1, 2'b11, 0, `NOR,      8'hAA, 8'h0F, 0);
   		auto_test_vec("XNOR",      	0, 1, 2'b11, 0, `XNOR,     8'hF0, 8'h0F, 0);
    		auto_test_vec("NOT_B",     	0, 1, 2'b10, 0, `NOT_B,    0,     8'h3C, 0);
   	 	auto_test_vec("SHR1_B",    	0, 1, 2'b10, 0, `SHR1_B,   0,     8'b10110010, 0);
    		auto_test_vec("SHL1_B",    	0, 1, 2'b10, 0, `SHL1_B,   0,     8'b01010101, 0);
    		auto_test_vec("ADD_OVF",   	0, 1, 2'b11, 1, `ADD,      8'hFF, 8'd1,  0);
    		auto_test_vec("SUB_UFLOW", 	0, 1, 2'b11, 1, `SUB,      8'd1,  8'd2,  0);
    		auto_test_vec("ADD_MAX_INPUT", 	0, 1, 2'b11, 1, `ADD,      8'hFF, 8'hFF, 0);
    		auto_test_vec("SIGNED_OVF",	0, 1, 2'b11, 1, `ADD_SIGN, 8'd127,8'd10, 0);
    		auto_test_vec("SIGNED_UFLOW",	0, 1, 2'b11, 1, `SUB_SIGN,-128,   8'd5,  0);
    		auto_test_vec("ERR_CMD",   	0, 1, 2'b11, 1,	4'b1111,   8'd5,  8'd5,  0);
    		auto_test_vec("ERR_INP_VALID",	0, 1, 2'b10, 1,	`ADD,      8'd10, 8'd10, 0);
    		auto_test_vec("ERR_INP_VALIDA",	0, 1, 2'b10, 1,	`INC_A,    8'd15, 0,     0);
    		auto_test_vec("ERR_INP_VALIDB",	0, 1, 2'b01, 1,	`INC_B,    0,     8'd5,  0);
    		auto_test_vec("CE_LOW",	0, 0, 2'b11, 1,	`ADD,      8'd1,  8'd2,  0);
    		auto_test_vec("ERR_MIXED", 	0, 1, 2'b10, 1,	`AND,      8'd2,  8'd2,  0);
    		auto_test_vec("ERR_INP_ZERO",   0, 1, 2'b00, 1, `INC_A,    8'hFF, 0,     0); 
    		auto_test_vec("DEC_A_OVF", 0, 1, 2'b01, 1, `DEC_A,    0,     0,     0); 
    		auto_test_vec("DEC_B_OVF", 0, 1, 2'b10, 1, `DEC_B,    0,     0,     0); 
    		auto_test_vec("INC_A_COUT",      0, 1, 2'b01, 1, `INC_A,    8'hFF, 0,     0); 
    		auto_test_vec("INC_B_COUT",      0, 1, 2'b10, 1, `INC_B,    0,     8'hFF, 0); 
    		auto_test_vec("ROL_ERR",    0, 1, 2'b11, 0, `ROL,      8'h81, 8'hF1, 0);
    		auto_test_vec("ROR_ERR",    0, 1, 2'b11, 0, `ROR,      8'h03, 8'hF1, 0);
    		auto_test_vec("SUB_CIN_EQ1",    0, 1, 2'b11, 1, `SUB_CIN,  8'd20, 8'd20, 1);
    		auto_test_vec("SUB_CIN_EQ0",    0, 1, 2'b11, 1, `SUB_CIN,  8'd20, 8'd20, 0);
    		auto_test_vec("SUB_CIN_UNDER",  0, 1, 2'b11, 1, `SUB_CIN,  8'd10, 8'd20, 0);
    		auto_test_vec("ADD_SIGN_NEG",   0, 1, 2'b11, 1, `ADD_SIGN, -8'd10,8'd20, 0);
    		auto_test_vec("ADD_SIGN_EQ",    0, 1, 2'b11, 1, `ADD_SIGN, 8'd20, 8'd20, 0);
    		auto_test_vec("SUB_SIGN_EQ",    0, 1, 2'b11, 1, `SUB_SIGN, 8'd20, 8'd20, 0);
    		auto_test_vec("INC_MUL_MAXA",   0, 1, 2'b11, 1, `INC_MUL,  8'd119,8'd1,  0);
    		auto_test_vec("INC_MUL_MAXB",   0, 1, 2'b11, 1, `INC_MUL,  8'd1,  8'd127,0);
    		auto_test_vec("INC_MUL_BIG",    0, 1, 2'b11, 1, `INC_MUL,  8'd254,8'd254,0);
		auto_test_vec("ERR_RST",   	1, 0, 2'b00, 0,	4'b0000,   0,     0,     0);
    		//auto_test_vec("RANDOM",  0, 1, 2'b11,1,`ADD,        $random, $random, 0);

    		$display("Total: %0d   Passed: %0d   Failed: %0d", testnum-1, pass, fail);
    		$finish;
	end //}

endmodule
