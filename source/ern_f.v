`timescale 1ns / 1ps

module ern_f(
    input [4:0] ern0, 
    input ejal, 
    output [4:0] ern
    );

    parameter return_address_register = 5'd31;
    assign ern = (ejal == 1'b1) ? return_address_register : ern0;

endmodule