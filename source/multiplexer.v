`timescale 1ns / 1ps

module multiplexer_1_4(
    input [4:0] in_1, 
    input [4:0] in_2, 
    input select,
    output reg [4:0] out
    );
    
    always @(*)
        out = (select == 1'b0) ? in_1 : in_2;

endmodule

module multiplexer_1_32(
    input [31:0] in_1, 
    input [31:0] in_2, 
    input select,
    output reg [31:0] out
    );
    
    always @(*)
        out = (select == 1'b0) ? in_1 : in_2;

endmodule

module multiplexer_2_32(
	input [31:0] in_1,
	input [31:0] in_2,
	input [31:0] in_3,
	input [31:0] in_4,
	input [1:0] select,
	output reg [31:0] out
    );

    always @(*) begin
        if (select == 2'b00)
            out = in_1;
        else if (select == 2'b01)
            out = in_2;
        else if (select == 2'b10)
            out = in_3;
        else if (select == 2'b11)
            out = in_4;
    end
endmodule