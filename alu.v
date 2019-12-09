module ALU(
    in0,
    in1,
    shamt,
    ALUCtrl,
    Zero,
    ALUResult
);

input  [31:0] in0;
input  [31:0] in1;
input  [4:0]  shamt;
input  [3:0]  ALUCtrl;

output Zero;
output [31:0] ALUResult;

endmodule
