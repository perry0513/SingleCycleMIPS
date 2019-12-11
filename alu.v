module ALU(
    in0,
    in1,
    ALUCtrl,
    shamt,
    Zero,
    ALUResult
);

input  [31:0] in0;
input  [31:0] in1;
input  [3:0]  ALUCtrl;
input  [4:0]  shamt;

output Zero;
output [31:0] ALUResult;

endmodule
