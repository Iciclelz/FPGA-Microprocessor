`timescale 1ns / 1ps

module register_memwb(
    input clk,

    input mwreg, 
    input mm2reg, 
    input [4:0] mrn,
    input [31:0] mr,
    input [31:0] mdo,

    output reg wwreg, 
    output reg wm2reg, 
    output reg [4:0] wrn,
    output reg [31:0] wr,
    output reg [31:0] wdo
    );

    always @ (negedge clk) begin
        wwreg <= mwreg;
        wm2reg <= mm2reg;
        wrn <= mrn;
        wr <= mr;
        wdo <= mdo;
    end

endmodule