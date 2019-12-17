module Control(
    opcode,
    funct,
    fmt,
    RegDst,
    Jump,
    Branch,
    NEqual,
    MemRead,
    MemtoReg,
    ALUOp,
    MemWrite,
    ALUSrc,
    RegWrite,
    Jal,
    Jr,
    Fp,
    Load_store_fp,
    Bclt
);

input  fmt;
input  [5:0] opcode;
input  [5:0] funct;

output RegDst;
output Jump;
output Branch;
output NEqual;
output MemRead;
output MemtoReg;
output MemWrite;
output ALUSrc;
output RegWrite;
output Jal;
output Jr;
output Fp;
output Load_store_fp;
output [1:0] ALUOp;
output Bclt;

/* 
* R    000000
* addi 001000
* lw   100011
* sw   101011
* beq  000100
* bne  000101
* j    000010
* jal  000011
* jr   000000 001000
*/


// assign RegDst   = ~(opcode[2] | opcode[1] | opcode[0]);
wire   isRtype  = ~(opcode[3] | opcode[2] | opcode[1] | opcode[0]);
assign RegDst   = ~(opcode[5] | opcode[3]) | (Fp & ~opcode[5]);
assign Jump     = ~opcode[5] &  opcode[1];
assign Branch   =  opcode[2] & ~opcode[5];
assign NEqual   =  opcode[0];
assign MemRead  =  opcode[5] & ~opcode[3];
assign MemtoReg =  opcode[5] & ~opcode[3];
assign MemWrite =  opcode[5] &  opcode[3];
assign ALUSrc   =  opcode[5] |  opcode[3];
assign RegWrite = (opcode[5] ^  opcode[3]) | ( isRtype & (funct[5] | ~funct[3]) ) | Jal | (Fp & fmt & ~funct[5]);
assign Jal      = ~opcode[5] &  opcode[1] & opcode[0];
// assign Jr       = ~funct [5] &  funct [3] & ~opcode[3] & RegDst;
assign Jr       =  isRtype & ~funct [5] & funct [3];
assign ALUOp    = (opcode[5] | opcode[3] )? 2'b00 :
                   opcode[2]? 2'b01 : 2'b10;

assign Fp       = opcode[4];
assign Load_store_fp = opcode[5] & opcode[4];
assign Bclt     = ~opcode[5] & opcode[4] & ~fmt;
/*
always@(*) begin
    RegDst   = 1'b0;
    Jump     = 1'b0;
    Branch   = 1'b0;
    ALUSrc   = 1'b1;
    MemRead  = 1'b0;
    MemWrite = 1'b0;
    MemtoReg = 1'b0;
    ALUOp    = 2'b00;

    case(opcode)
        // R format
        6'h00 : begin
            RegDst   = 1'b1;
            ALUOp    = 2'b10;
            ALUSrc   = 1'b0;
            RegWrite = 1'b1;
        end

        // addi 
        6'h08 : begin
            RegWrite = 1'b1;
        end

        // lw 
        6'h23 : begin
            RegWrite = 1'b1;
            MemRead  = 1'b1;
            MemtoReg = 1'b1;
        end

        // sw
        6'h2B : begin
            RegWrite = 1'b0;
            MemRead  = 1'b1;
            MemtoReg = 1'b1;
        end

        // beq
        6'h04 : begin
            ALUOp    = 2'b01;
            RegWrite = 1'b0;
            Branch   = 1'b1;
            Equal    = 1'b1;
        end

        // bne 
        6'h05 : begin
            ALUOp    = 2'b01;
            RegWrite = 1'b0;
            Branch   = 1'b1;
            Equal    = 1'b0;
        end

        // j 
        6'h02 : begin
            Jump     = 1'b1;
            RegWrite = 1'b0;
        end

        // jal
        6'h03 : begin
            Jump     = 1'b1;
            RegWrite = 1'b0;
        end


    endcase
end
*/

endmodule
