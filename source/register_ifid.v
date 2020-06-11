`timescale 1ns / 1ps

module register_ifid(
    input clk, 
    input wpcir,
    input [31:0] do, 
    input [31:0] pc4,
    output reg [31:0] instruction,
    output reg [31:0] dpc4
    );


    always @ (negedge clk) begin
        if (wpcir == 1'b1) begin
            instruction <= instruction;
            dpc4 <= dpc4;
        end
        else begin
            instruction <= do;
            dpc4 <= pc4;
        end
    end

endmodule