`timescale 1ns / 1ps

module control_unit(
    input [5:0] op,
    input [5:0] func,
    input [4:0] rs,
    input [4:0] rt,
    output reg wreg,
    output reg m2reg,
    output reg wmem,
    output reg [3:0]aluc,
    output reg aluimm,
    output reg regrt,

    //forwarding and pipeline stall
    input [4:0] mrn,
    input mm2reg,
    input mwreg,
    input [4:0] ern,
    input em2reg, 
    input ewreg,
    output wpcir,
    output reg [1:0]fwda,
    output reg [1:0]fwdb,

    output reg[1:0] pcsrc,
    output reg jal,
    output reg shift,
    input rsrtequ,
    output reg sext
    );

    initial 
        pcsrc = 2'b00;

    wire i_sll, i_srl, i_sra, i_jr, i_add, i_sub, i_and, i_or, i_xor;
    wire i_beq, i_bne, i_addi, i_andi, i_ori, i_xori, i_lw, i_sw;

    wire i_rs, i_rt;

    /* MIPS Opcode Definition */
    parameter OPCODE_R_TYPE = 6'b000000; //0  

    parameter OPCODE_J = 6'b000010; //2
    parameter OPCODE_JAL = 6'b000011; //3
    parameter OPCODE_BEQ = 6'b000100; //4
    parameter OPCODE_BNE = 6'b000101; //5
    parameter OPCODE_ADDI = 6'b001000; //8
    parameter OPCODE_ANDI = 6'b001100; //12
    parameter OPCODE_ORI = 6'b001101; //13
    parameter OPCODE_XORI = 6'b001110; //14
    parameter OPCODE_LUI = 6'b001111; //15
    
    parameter OPCODE_LW = 6'b100011; //35
    parameter OPCODE_SW = 6'b101011; //43
    
    /* MIPS Function Definition */
    parameter FUNCT_SLL = 6'b000000; //0
    parameter FUNCT_SRL = 6'b000010; //2
    parameter FUNCT_SRA = 6'b000011; //3
    parameter FUNCT_JR = 6'b001000; //8
    parameter FUNCT_ADD = 6'b100000; //32
    parameter FUNCT_SUB = 6'b100010; //34
    parameter FUNCT_AND = 6'b100100; //36
    parameter FUNCT_OR = 6'b100101;  //37
    parameter FUNCT_XOR = 6'b100110; //38

    /* ALU Control Definitions */
    parameter ALU_AND = 4'b0000;
    parameter ALU_OR = 4'b0001;    
    parameter ALU_ADD = 4'b0010;
    parameter ALU_SUB = 4'b0110;
    parameter ALU_SLT = 4'b0111;
    parameter ALU_NOR = 4'b1000;
    parameter ALU_XOR = 4'b1001;
    
    parameter ALU_SLL = 4'b1010;
    parameter ALU_SRL = 4'b1011;
    parameter ALU_SRA = 4'b1100;
  

    assign i_sll = ((op == OPCODE_R_TYPE) && (func == FUNCT_SLL));
    assign i_srl = ((op == OPCODE_R_TYPE) && (func == FUNCT_SRL));
    assign i_sra = ((op == OPCODE_R_TYPE) && (func == FUNCT_SRA));
    assign i_jr = ((op == OPCODE_R_TYPE) && (func == FUNCT_JR));
    assign i_add = ((op == OPCODE_R_TYPE) && (func == FUNCT_ADD));
    assign i_sub = ((op == OPCODE_R_TYPE) && (func == FUNCT_SUB));
    assign i_and = ((op == OPCODE_R_TYPE) && (func == FUNCT_AND));
    assign i_or = ((op == OPCODE_R_TYPE) && (func == FUNCT_OR));
    assign i_xor = ((op == OPCODE_R_TYPE) && (func == FUNCT_XOR));

    assign i_beq = (op == OPCODE_BEQ);
    assign i_bne = (op == OPCODE_BNE);
    assign i_addi = (op == OPCODE_ADDI);
    assign i_andi = (op == OPCODE_ANDI);
    assign i_ori = (op == OPCODE_ORI);
    assign i_xori = (op == OPCODE_XORI);
    assign i_lw = (op == OPCODE_LW);
    assign i_sw = (op == OPCODE_SW);

    assign i_rs = (i_jr | i_add | i_sub | i_and | i_or | i_xor | i_beq | i_bne | i_addi | i_andi | i_ori | i_xori | i_lw | i_sw);
    assign i_rt = (i_sll | i_srl | i_sra | i_add | i_sub | i_and | i_or | i_xor | i_beq | i_bne | i_sw);
    
    //stall
    assign wpcir = ewreg & em2reg & (ern != 0) & (i_rs & (ern == rs) | i_rt & (ern == rt));

    always @ (ewreg or mwreg or ern or mrn or em2reg or mm2reg or rs or rt)
    begin
    
        /*
        EX/MEM.RegisterRd == ID/EX.RegisterRs
        EX/MEM.RegisterRd == ID/EX.RegisterRt
        MEM/WB.RegisterRd == ID/EX.RegisterRs
        MEM/WB.RegisterRd == ID/EX.RegisterRt
        */
        
        fwda = 2'b00;
        fwdb = 2'b00;

        if (ewreg & ~em2reg & (ern != 0) & (ern == rs))
            fwda = 2'b01;
        else if (mwreg & ~mm2reg & (mrn != 0) & (mrn == rs))
            fwda = 2'b10;
        else if (mwreg & mm2reg & (mrn != 0) & (mrn == rs))
            fwda = 2'b11;
        
        if (ewreg & ~em2reg & (ern != 0) & (ern == rt))
            fwdb = 2'b01;
        else if (mwreg & ~mm2reg & (mrn != 0) & (mrn == rt))
            fwdb = 2'b10;
        else if (mwreg & mm2reg & (mrn != 0) & (mrn == rt))
            fwdb = 2'b11;
    end

    always @(*) begin

        pcsrc = 2'b00;

        wreg = 0;
		m2reg = 0; //memory to reg (lw)
        wmem = 0; //memory write (sw)
        aluc = 4'b0000; 
		aluimm = 0; 
		regrt = 0; 

        jal = 0; 
        shift = 0;
        sext = 0;

        if (op == OPCODE_R_TYPE) begin
            if (func == FUNCT_SLL) begin
                wreg = 1;
                aluc = ALU_SLL;
                shift = 1;
            end
            if (func == FUNCT_SRL) begin
                wreg = 1;
                aluc = ALU_SRL;
                shift = 1;
            end
            if (func == FUNCT_SRA) begin
                wreg = 1;
                aluc = ALU_SRA;
                shift = 1;
            end
            if (func == FUNCT_JR) begin
                pcsrc = 2'b10;
            end
            if (func == FUNCT_ADD) begin
                wreg = 1;
                aluc = ALU_ADD;
                aluimm = 0;
		        regrt = 0;
            end
            if (func == FUNCT_AND) begin
                wreg = 1;
                aluc = ALU_AND;
                aluimm = 0;
		        regrt = 0;
            end
            if (func == FUNCT_SUB) begin
                wreg = 1;
                aluc = ALU_SUB;
                aluimm = 0;
		        regrt = 0;
            end
            if (func == FUNCT_OR) begin
                wreg = 1;
                aluc = ALU_OR;
                aluimm = 0;
		        regrt = 0;
            end
            if (func == FUNCT_XOR) begin
                wreg = 1;
                aluc = ALU_XOR;
                aluimm = 0;
		        regrt = 0;
            end
        end

        if (op == OPCODE_J) begin
            pcsrc = 2'b11;
        end
        if (op == OPCODE_JAL) begin
            pcsrc = 2'b11;
            wreg = 1;
            jal = 1;
            
        end
        if (op == OPCODE_BEQ) begin
            aluc = ALU_SUB;
            sext = 1;

            if (rsrtequ)
                pcsrc = 2'b01;

        end
        if (op == OPCODE_BNE) begin
            aluc = ALU_SUB;
            sext = 1;

            if (~rsrtequ)
                pcsrc = 2'b01;

        end
        if (op == OPCODE_ADDI) begin
            wreg = 1;
            aluc = ALU_ADD; 
            aluimm = 1;
            regrt = 1;
            sext = 1;
        end
        if (op == OPCODE_ANDI) begin
            wreg = 1;
            aluc = ALU_AND;
            aluimm = 1;
            regrt = 1;
        end
        if (op == OPCODE_ORI) begin
            wreg = 1;
            aluc = ALU_OR;
            aluimm = 1;
            regrt = 1;
        end
        if (op == OPCODE_XORI) begin
            wreg = 1;
            aluc = ALU_XOR;
            aluimm = 1; 
            regrt = 1;
        end
        if (op == OPCODE_LUI) begin
            wreg = 1;
            aluimm = 1;
            regrt = 1;
        end

        if (op == OPCODE_LW) begin
            wreg = 1;           
            m2reg = 1;          
            wmem = 0;          
            aluc = ALU_ADD;     
            aluimm = 1; 
            regrt = 1;
            sext = 1;
        end

        if (op == OPCODE_SW) begin 
            wreg = 0; 
            m2reg = 0;
            wmem = 1; 
            aluc = ALU_ADD;
            aluimm = 1;
            regrt = 1;
            sext = 1;
        end
        
        if (wpcir == 1) begin
            wreg = 0;
            wmem = 0;
        end
        
    end
endmodule