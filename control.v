module Control(
    opcode,
    funct,
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
    Jr
);

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
output [1:0] ALUOp;

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
assign RegDst   = ~(opcode[5] | opcode[3]);
assign Jump     = ~opcode[5] &  opcode[1];
assign Branch   =  opcode[2];
assign NEqual   =  opcode[0];
assign MemRead  =  opcode[5] & ~opcode[3];
assign MemtoReg =  opcode[5] & ~opcode[3];
assign MemWrite =  opcode[5] &  opcode[3];
assign ALUSrc   =  opcode[3] |  opcode[1];
assign RegWrite = (opcode[5] ^  opcode[3]) | ( isRtype & (funct[5] | ~funct[3]) ) | Jal;
assign Jal      = ~opcode[5] &  opcode[1] & opcode[0];
// assign Jr       = ~funct [5] &  funct [3] & ~opcode[3] & RegDst;
assign Jr       =  isRtype & ~funct [5] & funct [3];
assign ALUOp    = (opcode[5] | opcode[3] )? 2'b00 :
                   opcode[2]? 2'b01 : 2'b10;

endmodule
