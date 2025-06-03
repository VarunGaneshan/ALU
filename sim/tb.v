`timescale 1ns/1ps
`include "defines.v"
`include "alu_top.v"
module alu_top_tb;
    	reg clk;
    	reg rst;
    	reg ce;
    	reg [1:0] inp_valid;
    	reg mode;
    	reg [`CMD_WIDTH-1:0] cmd;
    	reg cin;
    	reg [`OP_WIDTH-1:0] opa, opb;

   	`ifdef MUL_OP
        	wire [(2*`OP_WIDTH)-1:0] res;
   	`else
        	wire [`OP_WIDTH:0] res;
    	`endif

    	wire cout, oflow, g, l, e, err;

    	alu_top dut (
        	.clk(clk), .rst(rst), .ce(ce),
        	.inp_valid(inp_valid), .mode(mode),
        	.cmd(cmd), .cin(cin), .opa(opa), .opb(opb),
        	.res(res), .cout(cout), .oflow(oflow), .g(g), .l(l), .e(e), .err(err)
    	);

    	always #5 clk = ~clk;

initial begin //{
    clk = 0; rst = 1; ce = 0; inp_valid = 0; mode = 0; cmd = 0; cin = 0; opa = 0; opb = 0;
    #10; rst = 0; 
    #10; ce = 1; inp_valid = 2'b00; mode = 1; cmd = `INC_A; opa = 8'hFF; opb = 0; cin = 0;
    #10; ce = 1; inp_valid = 2'b01; mode = 1; cmd = `DEC_A; opa = 0; opb = 0; cin = 0;
    #10; ce = 1; inp_valid = 2'b10; mode = 1; cmd = `DEC_B; opa = 0; opb = 0; cin = 0;
    #10; ce = 1; inp_valid = 2'b01; mode = 1; cmd = `INC_A; opa = 8'hFF; opb = 0; cin = 0;
    #10; ce = 1; inp_valid = 2'b10; mode = 1; cmd = `INC_B; opa = 0; opb = 8'hFF; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 0; cmd = `ROL; opa = 8'h81; opb = 8'hF1; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 0; cmd = `ROR; opa = 8'h03; opb = 8'hF1; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `SUB_CIN; opa = 8'd20; opb = 8'd20; cin = 1;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `SUB_CIN; opa = 8'd20; opb = 8'd20; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `SUB_CIN; opa = 8'd10; opb = 8'd20; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `ADD_SIGN; opa = -8'd10; opb = 8'd20; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `ADD_SIGN; opa = 8'd20; opb = 8'd20; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `SUB_SIGN; opa = 8'd20; opb = 8'd20; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `INC_MUL; opa = 8'd119; opb = 8'd1; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `INC_MUL; opa = 8'd1; opb = 8'd127; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `INC_MUL; opa = 8'd254; opb = 8'd254; cin = 0;
    #20; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `ADD; opa = 8'd10; opb = 8'd20; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `SUB; opa = 8'd25; opb = 8'd10; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `ADD_CIN; opa = 8'd5; opb = 8'd7; cin = 1;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `SUB_CIN; opa = 8'd20; opb = 8'd4; cin = 1;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `CMP; opa = 8'd10; opb = 8'd10; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `CMP; opa = 8'd15; opb = 8'd10; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `CMP; opa = 8'd7; opb = 8'd20; cin = 0;
    #10; ce = 1; inp_valid = 2'b01; mode = 1; cmd = `INC_A; opa = 8'd8; opb = 0; cin = 0;
    #10; ce = 1; inp_valid = 2'b01; mode = 1; cmd = `DEC_A; opa = 8'd8; opb = 0; cin = 0;
    #10; ce = 1; inp_valid = 2'b10; mode = 1; cmd = `INC_B; opa = 0; opb = 8'd4; cin = 0;
    #10; ce = 1; inp_valid = 2'b10; mode = 1; cmd = `DEC_B; opa = 0; opb = 8'd9; cin = 0;
    #10; ce = 1; inp_valid = 2'b01; mode = 0; cmd = `NOT_A; opa = 8'hAA; opb = 0; cin = 0;
    #10; ce = 1; inp_valid = 2'b01; mode = 0; cmd = `SHL1_A; opa = 8'h05; opb = 0; cin = 0;
    #10; ce = 1; inp_valid = 2'b01; mode = 0; cmd = `SHR1_A; opa = 8'h08; opb = 0; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 0; cmd = `AND; opa = 8'hF0; opb = 8'h0F; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 0; cmd = `OR; opa = 8'hF0; opb = 8'h0F; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 0; cmd = `XOR; opa = 8'hF0; opb = 8'h0F; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `INC_MUL; opa = 8'd8; opb = 8'd2; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `SHL_MUL; opa = 8'd3; opb = 8'd2; cin = 0;
    #20; ce = 1; inp_valid = 2'b11; mode = 0; cmd = `ROL; opa = 8'h81; opb = 8'd1; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 0; cmd = `ROR; opa = 8'h03; opb = 8'd1; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `ADD_SIGN; opa = 8'd50; opb = 8'd20; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `ADD_SIGN; opa = 8'd50; opb = -8'd10; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `SUB_SIGN; opa = -8'd10; opb = 8'd20; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 0; cmd = `NAND; opa = 8'hAA; opb = 8'h0F; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 0; cmd = `NOR; opa = 8'hAA; opb = 8'h0F; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 0; cmd = `XNOR; opa = 8'hF0; opb = 8'h0F; cin = 0;
    #10; ce = 1; inp_valid = 2'b10; mode = 0; cmd = `NOT_B; opa = 0; opb = 8'h3C; cin = 0;
    #10; ce = 1; inp_valid = 2'b10; mode = 0; cmd = `SHR1_B; opa = 0; opb = 8'b10110010; cin = 0;
    #10; ce = 1; inp_valid = 2'b10; mode = 0; cmd = `SHL1_B; opa = 0; opb = 8'b01010101; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `ADD; opa = 8'hFF; opb = 8'd1; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `SUB; opa = 8'd1; opb = 8'd2; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `ADD; opa = 8'hFF; opb = 8'hFF; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `ADD_SIGN; opa = 8'd127; opb = 8'd10; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `SUB_SIGN; opa = -128; opb = 8'd5; cin = 0;
    #10; ce = 1; inp_valid = 2'b11; mode = 1; cmd = 4'b1111; opa = 8'd5; opb = 8'd5; cin = 0;
    #10; ce = 1; inp_valid = 2'b10; mode = 1; cmd = `ADD; opa = 8'd10; opb = 8'd10; cin = 0;
    #10; ce = 1; inp_valid = 2'b10; mode = 1; cmd = `INC_A; opa = 8'd15; opb = 0; cin = 0;
    #10; ce = 1; inp_valid = 2'b01; mode = 1; cmd = `INC_B; opa = 0; opb = 8'd5; cin = 0;
    #10; ce = 0; inp_valid = 2'b11; mode = 1; cmd = `ADD; opa = 8'd1; opb = 8'd2; cin = 0;
    #10; ce = 1; inp_valid = 2'b10; mode = 1; cmd = `AND; opa = 8'd2; opb = 8'd2; cin = 0;
    #10; rst = 1; ce = 0; inp_valid = 0; mode = 0; cmd = 0; opa = 0; opb = 0; cin = 0;
    #10; rst = 0; ce = 1; inp_valid = 2'b11; mode = 1; cmd = `ADD; opa = $random; opb = $random; cin = 0;

    #50; $finish;
end //}


endmodule
