`timescale 1ns / 1ps

// register file module 
module register_file(
    input [4:0] rs,
    input [4:0] rt,
    output reg [31:0] qa,
    output reg [31:0] qb,

    // write-back
    input clk,
    input we,
    input [4:0] wn,
    input [31:0] d
    );

    /*
    $zero	    0	Constant 0
    $at	        1	Reserved for assembler
    $v0, $v1	2, 3	Function return values
    $a0 - $a3	4 - 7	Function argument values
    $t0 - $t7	8 - 15	Temporary (caller saved)
    $s0 - $s7	16 - 23	Temporary (callee saved)
    $t8, $t9	24, 25	Temporary (caller saved)
    $k0, $k1	26, 27	Reserved for OS Kernel
    $gp	        28	Pointer to Global Area
    $sp	        29	Stack Pointer
    $fp	        30	Frame Pointer
    $ra	        31	Return Address
    */

    // reserve for general purpose registers
    reg [31:0] register[0:31];

    integer i;
    initial begin 
        for (i = 0; i < 32; i = i + 1)
          register[i] = 0;
        /*
        register[32'd00] = 32'h00000000; //0
        register[32'd01] = 32'hA00000AA; //1
        register[32'd02] = 32'h10000011; //2
        register[32'd03] = 32'h20000022; //3
        register[32'd04] = 32'h30000033; //4
        register[32'd05] = 32'h40000044; //5
        register[32'd06] = 32'h50000055; //6
        register[32'd06] = 32'h60000066; //7
        register[32'd08] = 32'h70000077; //8
        register[32'd09] = 32'h80000088; //9
        register[32'd10] = 32'h90000099; //10 
        */ 
    end 

    always @(*) begin
        qa = register[rs];
        qb = register[rt];
    end
    
    //writeback
    always @ (posedge clk) begin
        if (we == 1'b1) begin
            register[wn] <= d;
            //$display("Regfile write-back: $%d=%h", wn, d);
        end
    end

endmodule