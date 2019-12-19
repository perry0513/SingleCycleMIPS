`include "register.v"
`include "control.v"
`include "alu_control.v"
`include "alu.v"
`include "alu_fp.v"

module SingleCycleMIPS_FPU( 
    clk,
    rst_n,
    IR_addr,
    IR,
    ReadDataMem,
    CEN,
    WEN,
    A,
    Data2Mem,
    OEN
);

//==== in/out declaration =================================
//-------- processor ----------------------------------
input         clk, rst_n;
input  [31:0] IR;
output [31:0] IR_addr;

//-------- data memory --------------------------------
input  [31:0] ReadDataMem;  
output        CEN;  
output        WEN;  
output [6:0]  A;  
output [31:0] Data2Mem;  
output        OEN;  

//==== reg/wire declaration ===============================
/* output registers */

reg  [31:0] pc;
wire [31:0] next_pc;
reg  double;


wire Fp;
/* decode instructions */
wire [5:0] opcode = IR[31:26];
wire [4:0] rs     = (~opcode[5] & opcode[4])? IR[15:11] : IR[25:21];
wire [4:0] rt     = double? IR[20:16] + 5'd1 : IR[20:16];
wire [4:0] rd     = (~opcode[5] & opcode[4])? IR[10: 6] : IR[15:11];
wire [4:0] shamt  = IR[10: 6];
wire [5:0] funct  = IR[ 5: 0];

wire [15:0] imm    = double? IR[15:0] + 5'd4 : IR[15:0];
wire [31:0] extimm = { {16{imm[15]}}, imm };
// wire [25:0] addr   = IR[25: 0];

/* interconnections between modules */
wire RegDst, Branch, NEqual, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Jump, Jal, Jr;
wire next_double, Load_store_fp, Bclt, FpCond, FpCondWrite;
wire [1:0] ALUOp;
wire [3:0] ALUCtrl;

wire        Zero;
wire [31:0] reg_data_0_0;
wire [31:0] reg_data_0_1;
wire [31:0] reg_data_1_0;
wire [31:0] reg_data_1_1;
wire [31:0] ALU_result;
wire [31:0] ALU_fp_result_0;
wire [31:0] ALU_fp_result_1;
wire [31:0] real_ALU_result = (Fp & ~Load_store_fp)? ALU_fp_result_0 : ALU_result;


/* Jump */
wire [31:0] added_addr  = pc + 32'd4;
wire [31:0] branch_addr = added_addr + (extimm << 2);
wire [31:0] jump_addr   = { added_addr[31:28], IR[25:0], 2'b00 };

/* muxes */
wire [ 4:0] write_reg = Jal? 5'd31: (RegDst? rd : rt);
wire [31:0] ALUInput  = ALUSrc? extimm : reg_data_1_0;
wire [31:0] DatatoReg = Jal? added_addr : (MemtoReg? ReadDataMem : real_ALU_result);
wire        isBranch  = (Bclt & FpCond) | (Branch & (NEqual ^ Zero));
wire [31:0] branched  = isBranch? branch_addr : added_addr;
wire [31:0] jumped    = Jump? jump_addr : branched;


/* output wires */
assign CEN = WEN & OEN;
assign WEN = ~MemWrite;
assign OEN = ~MemRead;
assign A   = ALU_result[8:2];
assign Data2Mem = reg_data_1_0;
assign next_pc  = Jr? reg_data_0_0 : jumped;
assign IR_addr  = pc;


assign next_double = (Load_store_fp & opcode[2])? ~double : double;

always@(posedge clk) begin
    if (~rst_n) begin
        pc     <= 32'b0;
        double <= 1'b0;
    end
    else begin
        pc     <= (Load_store_fp & opcode[2] & ~double)? pc : next_pc;
        double <= next_double;
    end
end
	

//==== wire connection to submodule ======================
Register mips_reg(
   .clk(clk),
   .rst_n(rst_n),
   .read_reg_0(rs),
   .read_reg_1(rt),
   .write_reg(write_reg),
   .write_data_0(DatatoReg),
   .write_data_1(ALU_fp_result_1),
   .RegWrite(RegWrite),
   .Fp(Fp),
   .double(double),
   .fmt0(IR[21]),
   .Load_store_fp(Load_store_fp),
   .read_data_0_0(reg_data_0_0),
   .read_data_0_1(reg_data_0_1),
   .read_data_1_0(reg_data_1_0),
   .read_data_1_1(reg_data_1_1)
);

Control ctrl(
    .opcode(opcode),
    .funct(funct),
    .fmt4(IR[25]),
    .RegDst(RegDst),
    .Jump(Jump),
    .Branch(Branch),
    .NEqual(NEqual),
    .MemRead(MemRead),
    .MemtoReg(MemtoReg),
    .ALUOp(ALUOp),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite),
    .Jal(Jal),
    .Jr(Jr),
    .Fp(Fp),
    .Load_store_fp(Load_store_fp),
    .Bclt(Bclt),
    .FpCondWrite(FpCondWrite)
);

ALU_control alu_ctrl(
    .funct(funct),
    .ALUOp(ALUOp),
    .ALUCtrl(ALUCtrl)
);

ALU alu(
    .in0(reg_data_0_0),
    .in1(ALUInput),
    .ALUCtrl(ALUCtrl),
    .shamt(shamt),
    .Zero(Zero),
    .ALUResult(ALU_result)
);

ALU_fp alu_fp(
    .clk(clk),
    .rst_n(rst_n),
    .in0_0(reg_data_0_0),
    .in0_1(reg_data_0_1),
    .in1_0(reg_data_1_0),
    .in1_1(reg_data_1_1),
    .ALUCtrl(ALUCtrl),
    .isDouble(IR[21]),
    .ALUResult_0(ALU_fp_result_0),
    .ALUResult_1(ALU_fp_result_1),
    .FpCond(FpCond),
    .FpCondWrite(FpCondWrite)
);

endmodule


