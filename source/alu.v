`timescale 1ns / 1ps

module alu(
    input [31:0] a,
    input [31:0] b,
    input [3:0] ealuc,
    output reg [31:0] r
    );
    
    /* ALU Control Definitions */
    parameter ALU_AND = 4'b0000;
    parameter ALU_OR = 4'b0001;    
    parameter ALU_ADD = 4'b0010;
    parameter ALU_SUB = 4'b0110;
    parameter ALU_SLT = 4'b0111;
    parameter ALU_NOR = 4'b1000;
    parameter ALU_XOR = 4'b1001;
    
    parameter ALU_SLL = 4'b1010;
    parameter ALU_SRL = 4'b1011;
    parameter ALU_SRA = 4'b1100;
  
    always @(*) begin

        if (ealuc == ALU_AND)
            r <= a & b;
        else if (ealuc == ALU_OR)
            r <= a | b;
        else if (ealuc == ALU_ADD)
            r <= a + b;
        else if (ealuc == ALU_SUB)
            r <= a - b;
        else if (ealuc == ALU_SLT)
            r <= a < b ? 32'b1 : 32'b0;
        else if (ealuc == ALU_NOR)
            r <= ~(a | b);
        else if (ealuc == ALU_XOR)
            r <= a ^ b;
        else if (ealuc == ALU_SLL) //shift left (logical) by constant
            r <= b << a[10:6]; //sa is 5 bits
        else if (ealuc == ALU_SRL) //shift right (logical) by constant
            r <= b >> a[10:6]; //sa is 5 bits
        else if (ealuc == ALU_SRA) //shift right (arithmitic) , sign extend
            r <= $signed(b) >>> a[10:6];
        
        //$display("Alu Control (%b): %h <= %h %h(%d)", ealuc, r, b, a, a[10:6]);
        //$display("Alu Control (%b): %h <= %h %h", ealuc, r, a, b);
    end
    
endmodule