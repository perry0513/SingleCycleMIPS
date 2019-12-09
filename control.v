module Control(
    ins,
    RegDst,
    Jump,
    Branch,
    Equal,
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
output Equal;
output MemRead;
output MemtoReg;
output MemWrite;
output ALUSrc;
output RegWrite;
output [1:0] ALUop;

always@(*) begin
    RegDst   = 1'b0;
    Jump     = 1'b0;
    Branch   = 1'b0;
    ALUSrc   = 1'b1;
    MemRead  = 1'b0;
    MemWrite = 1'b0;
    MemtoReg = 1'b0;
    ALUOp    = 2'b00;

    case(ins)
        /* R format */
        6'h00 : begin
            RegDst   = 1'b1;
            ALUOp    = 2'b10;
            ALUSrc   = 1'b0;
            RegWrite = 1'b1;
        end

        /* addi */
        6'h08 : begin
            RegWrite = 1'b1;
        end

        /* lw */
        6'h23 : begin
            RegWrite = 1'b1;
            MemRead  = 1'b1;
            MemtoReg = 1'b1;
        end

        /* sw */
        6'h2B : begin
            RegWrite = 1'b0;
            MemRead  = 1'b1;
            MemtoReg = 1'b1;
        end

        /* beq */
        6'h04 : begin
            ALUOp    = 2'b01;
            RegWrite = 1'b0;
            Branch   = 1'b1;
            Equal    = 1'b1;
        end

        /* bne */
        6'h05 : begin
            ALUOp    = 2'b01;
            RegWrite = 1'b0;
            Branch   = 1'b1;
            Equal    = 1'b0;
        end

        /* j */
        6'h05 : begin
            Jump     = 1'b1;
            RegWrite = 1'b0;
        end

        /* jal */
        6'h05 : begin
            Jump     = 1'b1;
            RegWrite = 1'b0;
        end


    endcase
end


endmodule
