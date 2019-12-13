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

assign ALUResult = ALUCtrl[2:1] == 2'b00 ? ( ALUCtrl[0] == 1'b0 ? in0 & in1 : in0 | in1 ) :
                   ALUCtrl[2:1] == 2'b10 ? ( ALUCtrl[0] == 1'b0 ? in1 << shamt : in1 >> shamt ) :
                   ALUCtrl[1:0] == 2'b10 ? ( ALUCtrl[2] == 1'b0 ? in0 + in1 : in0 - in1 ) :
                   ALUCtrl[1:0] == 2'b11 ? { 31'b0, (in0 < in1) } :
                   32'b0;

assign Zero = ( ALUResult == 32'b0 );

endmodule
