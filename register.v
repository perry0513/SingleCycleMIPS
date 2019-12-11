module Register(
    clk,
    read_reg_1,
    read_reg_2,
    write_reg,
    write_data,
    RegWrite,
    Jal,
    pc_4,
    read_data_1,
    read_data_2
);

input  clk;
input  RegWrite;
input  Jal;
input  [4:0] read_reg_1;
input  [4:0] read_reg_2;
input  [4:0] write_reg;
input  [31:0] write_data;
input  [31:0] pc_4;

output [31:0] read_data_1;
output [31:0] read_data_2;

endmodule
