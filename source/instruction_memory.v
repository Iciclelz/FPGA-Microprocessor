`timescale 1ns / 1ps

// instruction memory module
module instruction_memory(
    input [31:0] a, 
    output reg [31:0] do
    );

    // instruction will be fetched based on pc
    // allocate more based on when we need more
    reg [31:0] rom[255:0];

    initial begin
        
        // rom[word_addr] = instruction // (pc) label instruction
        rom[32'h00] = 32'h3c010000; // (00) main: lui $1, 0
        rom[32'h04] = 32'h34240050; // (04) ori $4, $1, 80
        rom[32'h08] = 32'h0c00001b; // (08) call: jal sum
        rom[32'h0c] = 32'h20050004; // (0c) dslot1: addi $5, $0, 4
        rom[32'h10] = 32'hac820000; // (10) return: sw $2, 0($4)
        rom[32'h14] = 32'h8c890000; // (14) lw $9, 0($4)
        rom[32'h18] = 32'h01244022; // (18) sub $8, $9, $4
        rom[32'h1c] = 32'h20050003; // (1c) addi $5, $0, 3
        rom[32'h20] = 32'h20a5ffff; // (20) loop2: addi $5, $5, -1
        rom[32'h24] = 32'h34a8ffff; // (24) ori $8, $5, 0xffff
        rom[32'h28] = 32'h39085555; // (28) xori $8, $8, 0x5555
        rom[32'h2c] = 32'h2009ffff; // (2c) addi $9, $0, -1
        rom[32'h30] = 32'h312affff; // (30) andi $10,$9,0xffff
        rom[32'h34] = 32'h01493025; // (34) or $6, $10, $9
        rom[32'h38] = 32'h01494026; // (38) xor $8, $10, $9
        rom[32'h3c] = 32'h01463824; // (3c) and $7, $10, $6
        rom[32'h40] = 32'h10a00003; // (40) beq $5, $0, shift
        rom[32'h44] = 32'h00000000; // (44) dslot2: nop
        rom[32'h48] = 32'h08000008; // (48) j loop2
        rom[32'h4c] = 32'h00000000; // (4c) dslot3: nop
        rom[32'h50] = 32'h2005ffff; // (50) shift: addi $5, $0, -1
        rom[32'h54] = 32'h000543c0; // (54) sll $8, $5, 15
        rom[32'h58] = 32'h00084400; // (58) sll $8, $8, 16
        rom[32'h5c] = 32'h00084403; // (5c) sra $8, $8, 16
        rom[32'h60] = 32'h000843c2; // (60) srl $8, $8, 15
        rom[32'h64] = 32'h08000019; // (64) finish: j finish
        rom[32'h68] = 32'h00000000; // (68) dslot4: nop 
        rom[32'h6c] = 32'h00004020; // (6c) sum: add $8, $0, $0
        rom[32'h70] = 32'h8c890000; // (70) loop: lw $9, 0($4)
        rom[32'h74] = 32'h01094020; // (74) stall: add $8, $8, $9
        rom[32'h78] = 32'h20a5ffff; // (78) addi $5, $5, -1
        rom[32'h7c] = 32'h14a0fffc; // (7c) bne $5, $0, loop
        rom[32'h80] = 32'h20840004; // (80) dslot5: addi $4, $4, 4
        rom[32'h84] = 32'h03e00008; // (84) jr $31
        rom[32'h88] = 32'h00081000; // (88) dslot6: sll $2, $8, 0 
    end

     always @(*)
        do = rom[a];
    
endmodule