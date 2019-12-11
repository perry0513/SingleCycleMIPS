module ALU_control(
    funct,
    ALUOp,
    ALUCtrl
);

input  [5:0] funct;
input  [1:0] ALUOp;
output [3:0] ALUCtrl;

/*
* sll 000000
* srl 000010
* add 100000
* sub 100010
* and 100100
* or  100101
* slt 101010
* jr  001000
*/

endmodule
