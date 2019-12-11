module ALU_control(
    funct,
    ALUOp,
    ALUCtrl
);

input  [5:0] funct;
input  [1:0] ALUOp;
output [3:0] ALUCtrl;

assign ALUCtrl[3] = 1'b0;
assign ALUCtrl[2] = ( ~ALUOp[1] & ALUOP[0] ) | ( ALUOp[1] & ~ALUOP[0] & ( ~funct[5] | funct[1] ) );
assign ALUCtrl[1] = ~ALUOp[1] | ( funct[5] & ~funct[2] );
assign ALUCtrl[0] = ALUOp[1] & ( ( funct[3] & funct[1] ) | ( funct[2] & funct[0] ) | ( ~funct[5] & funct[1] ) );

/* assign Jr = ~funct[5] & funct[3]; */

endmodule
