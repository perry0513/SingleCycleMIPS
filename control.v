module Control(
    ins,
    RegDst,
    Jump,
    Branch,
    MemRead,
    MemtoReg,
    ALUOp,
    MemWrite,
    ALUSrc,
    RegWrite
);

input  [5:0] ins;

output RegDst;
output Jump;
output Branch;
output MemRead;
output MemtoReg;
output MemWrite;
output ALUSrc;
output RegWrite;
output [1:0] ALUop;



endmodule
