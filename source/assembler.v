`timescale 1ns / 1ps

module jpc_assembler(
    input [3:0] dpc4,
    input [25:0] addr,
    output reg [31:0] jpc
);

    always @ (*)
        jpc = { dpc4, addr, 2'b0 };

endmodule

module bpc_assembler(
    input [31:0] dpc4,
    input [15:0] imm,
    output reg [31:0] bpc
);
    always @(*)
        bpc = $signed(dpc4) + $signed(imm << 2);
        
endmodule