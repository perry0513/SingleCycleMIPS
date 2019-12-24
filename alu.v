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

// wire [31:0] neg_in1 = ~in1 + 32'b1;
// wire [31:0] add_or_sub = in0 + (ALUCtrl[2]? neg_in1 : in1);
wire [31:0] add_or_sub = ALUCtrl[2] ? in0 - in1 : in0 + in1;
assign ALUResult = ALUCtrl[2:1] == 2'b00 ? ( ALUCtrl[0]? in0 | in1 : in0 & in1 ) :
                   ALUCtrl[2:1] == 2'b10 ? ( ALUCtrl[0]? in1 >> shamt : in1 << shamt ) :
                   ALUCtrl[1:0] == 2'b10 ? add_or_sub :
                   ALUCtrl[1:0] == 2'b11 ? { 31'b0, (in0[31] ^ in1[31])? in0[31] : add_or_sub[31] } :
                   32'b0;

assign Zero = ( ALUResult == 32'b0 );

endmodule
