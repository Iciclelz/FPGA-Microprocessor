`timescale 1ns / 1ps

module data_memory(
    input [31:0] a,
    input [31:0] di,
    input we,
    output reg [31:0] do
    );

    reg [31:0] ram[127:0];
    
    integer i;
    initial begin 
        for (i = 0; i < 128; i = i + 1)
            ram[i] = 0;

        ram[32'h50] = 32'h000000a3;
        ram[32'h54] = 32'h00000027;
        ram[32'h58] = 32'h00000079;
        ram[32'h5c] = 32'h00000115;
        //ram[0x60] should be 0x00000258
    end 
  
    always @(*) begin
	    do = ram[a];
        if (we)
            ram[a] = di;
    end    
    
endmodule