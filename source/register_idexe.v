`timescale 1ns / 1ps

module register_idexe(
    input clk,

    input wreg, 
    input m2reg, 
    input wmem, 
    input [3:0] aluc, 
    input aluimm, 
    input [4:0] rn, 
    input [31:0] qa, 
    input [31:0] qb,
    input [31:0] imm,
    input jal,
    input shift,
    input [31:0] dpc4,

    output reg ewreg, 
    output reg em2reg, 
    output reg ewmem, 
    output reg [3:0] ealuc, 
    output reg ealuimm,
    output reg [4:0] ern,
    output reg [31:0] eqa,
    output reg [31:0] eqb,
    output reg [31:0] eimm,
    output reg ejal,
    output reg eshift,
    output reg [31:0] epc4
    );

    always @ (negedge clk) begin
        ewreg <= wreg;
        em2reg <= m2reg;
        ewmem <= wmem;
        ealuc <= aluc;
        ealuimm <= aluimm;
        ern <= rn;
        eqa <= qa;
        eqb <= qb;
        eimm <= imm;
        ejal <= jal;
        eshift <= shift;
        epc4 <= dpc4;
    end

endmodule