`timescale 1ns / 1ps

module register_pc(
    input clk, 
    input wpcir,
    input [31:0] in, 
    output reg[31:0] out
    );
    
    reg reset;
    
    initial
        reset = 1;
    
    always @ (negedge clk or negedge reset) begin
        if (reset) begin
            out = 32'h0;
            reset = 0;
        end
        else begin
            if (wpcir == 1'b1)
                out <= out;
            else
                out <= in;
        end
    end

endmodule