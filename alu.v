module ALU(
    in0,
    in1,
    ALUCtrl,
    Zero,
    ALUResult
);

input  [31:0] in0;
input  [31:0] in1;
input  [3:0]  ALUCtrl;

output Zero;
output [31:0] ALUResult;

assign ALUResult = ALUCtrl[2:1] == 2'b10 ? ( ALUCtrl[0] == 1'b0 ? 

endmodule
