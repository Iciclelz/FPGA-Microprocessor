`timescale 1ns / 1ps

module testbench();
    reg clk;

    // wires for if stage
    wire [31:0] pc;
    wire [31:0] npc;
    wire [31:0] pc4;
    wire [31:0] do;

    // wires for id stage

    wire [31:0] instruction;

    wire wreg;
    wire m2reg;
    wire wmem;
    wire [3:0] aluc;
    wire aluimm;
    wire regrt;
    wire [4:0] rn;
    wire [31:0] qa;
    wire [31:0] qb;
    wire [31:0] imm;

    wire jal;
    wire shift;
    wire rsrtequ;
    wire sext;

    wire [31:0] bpc;
    wire [31:0] jpc;

    wire [31:0] dpc4;

    // wires for exe stage
    wire ewreg;
    wire em2reg;
    wire ewmem;
    wire [3:0] ealuc;
    wire ealuimm;
    wire [4:0] ern;
    wire [4:0] ern0;
    wire [31:0] eqa;
    wire [31:0] eqb;
    wire [31:0] eimm;

    wire [31:0] ealua;
    wire [31:0] ealub;
    wire [31:0] ealur;
    wire [31:0] r;

    wire ejal;
    wire eshift;

    wire [31:0] epc4;
    wire [31:0] epc8;

    //wires for mem stage
    wire mwreg; 
    wire mm2reg; 
    wire mwmem;
    wire [4:0] mrn;
    wire [31:0] mr;
    wire [31:0] mqb;
    
    wire [31:0] mdo;

    //wires for wb stage
    wire wwreg;
    wire wm2reg;
    wire [4:0] wrn;
    wire [31:0] wr;
    wire [31:0] wdo;

    wire [31:0] wd;

    //wires for forwarding and pipeline stall
    wire [1:0] pcsrc;
    wire wpcir; //stall
    wire [1:0] fwda;
    wire [1:0] fwdb;
    wire [31:0] dqa;
    wire [31:0] dqb;

    // if stage
    register_pc m_register_pc(clk, wpcir, npc, pc);
    adder m_pc_adder(pc, 32'd4, pc4);
    instruction_memory m_instruction_memory(pc, do);
    multiplexer_2_32 m_npc_multiplexer_2_32(pc4, bpc, dqa, jpc, pcsrc, npc);
    
    // id stage
    register_ifid m_register_ifid(clk, wpcir, do, pc4, instruction, dpc4);
    control_unit m_control_unit(instruction[31:26], instruction[5:0], instruction[25:21], instruction[20:16], wreg, m2reg, wmem, aluc, aluimm, regrt
        /*forwarding and pipeline stall*/, mrn, mm2reg, mwreg, ern, em2reg, ewreg, wpcir, fwda, fwdb
        /**/ , pcsrc, jal, shift, rsrtequ, sext);
    multiplexer_1_4 m_multiplexer_1_4(instruction[15:11], instruction[20:16], regrt, rn);

    register_file m_register_file(instruction[25:21], instruction[20:16], qa, qb /*write-back stage*/, clk, wwreg, wrn, wd);
    multiplexer_2_32 m_fwda_multiplexer_2_32(qa, r, mr, mdo, fwda, dqa);
    multiplexer_2_32 m_fwdb_multiplexer_2_32(qb, r, mr, mdo, fwdb, dqb);

    jpc_assembler m_jpc_assembler(dpc4[31:28], instruction[25:0], jpc);
    bpc_assembler m_bpc_assembler(dpc4, instruction[15:0], bpc);

    sign_extend m_sign_extend(sext, instruction[15:0], imm);

    is_equal m_is_rsrtequ(dqa, dqb, rsrtequ);

    // exe stage
    register_idexe m_register_idexe(clk, 
        // inputs
        wreg, m2reg, wmem, aluc, aluimm, 
        rn, 
        dqa, dqb,
        imm,
        jal,
        shift,
        dpc4,
        // outputs
        ewreg, em2reg, ewmem, ealuc, ealuimm,
        ern0,
        eqa, eqb,
        eimm,
        ejal,
        eshift,
        epc4
        );

    adder m_epc_adder(epc4, 32'd4, epc8);
    
    multiplexer_1_32 m_alu_a_multiplexer_1_32(eqa, eimm, eshift, ealua);
    multiplexer_1_32 m_alu_b_multiplexer_1_32(eqb, eimm, ealuimm, ealub);
    alu m_alu(ealua, ealub, ealuc, ealur);

    multiplexer_1_32 m_alu_jal_multiplexer_1_32(ealur, epc8, ejal, r);
    ern_f m_ern_f(ern0, ejal, ern);

    //mem stage
    register_exemem m_register_exemem(clk,
        ewreg, em2reg, ewmem, ern, r, eqb,
        mwreg, mm2reg, mwmem, mrn, mr, mqb);

    data_memory m_data_memory(mr, mqb, mwmem, mdo);

    //wb stage
    register_memwb m_register_memwb(clk,
        mwreg, mm2reg, mrn, mr, mdo,
        wwreg, wm2reg, wrn, wr, wdo);

    multiplexer_1_32 m_wbmultiplexer_1_32(wr, wdo, wm2reg, wd);
     
    initial begin
        clk = 0;
    end 
 
    always begin
        #1;
        clk = ~clk;
    end


endmodule