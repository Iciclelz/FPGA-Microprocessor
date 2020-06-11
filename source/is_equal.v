`timescale 1ns / 1ps

module is_equal(
    input [31:0] a,
    input [31:0] b,
    output reg result
);

    always @(*)
        result = ~|(a ^ b); //a == b

endmodule