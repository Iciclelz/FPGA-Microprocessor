`timescale 1ns / 1ps

module register_exemem(
    input clk,

    input ewreg, 
    input em2reg, 
    input ewmem, 
    input [4:0] ern,
    input [31:0] r,
    input [31:0] eqb,

    output reg mwreg, 
    output reg mm2reg, 
    output reg mwmem, 
    output reg [4:0] mrn,
    output reg [31:0] mr,
    output reg [31:0] mqb
    );

    always @ (negedge clk) begin
        mwreg <= ewreg;
        mm2reg <= em2reg;
        mwmem <= ewmem;
        mrn <= ern;
        mr <= r;
        mqb <= eqb; 
    end

endmodule