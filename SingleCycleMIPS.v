`include "register.v"
`include "control.v"
`include "alu_control.v"
`include "alu.v"

module SingleCycleMIPS( 
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
/*
reg  CEN, next_CEN;
reg  WEN, next_WEN;
reg  OEN, next_OEN;
reg  [6:0]  A, next_A;
reg  [31:0] Data2Mem, next_Data2Mem;
*/

reg  [31:0] pc;
wire [31:0] next_pc;

/* decode instructions */
wire [5:0] opcode = IR[31:26];
wire [4:0] rs     = IR[25:21];
wire [4:0] rt     = double? IR[20:16] + 5'd1 : IR[20:16];
wire [4:0] rd     = IR[15:11];
wire [4:0] shamt  = IR[10: 6];
wire [5:0] funct  = IR[ 5: 0];

wire [15:0] imm    = double? IR[15:0] + 5'd4 : IR[15:0];
wire [31:0] extimm = { {16{imm[15]}}, imm };
wire [25:0] addr   = IR[25: 0];

/* interconnections between modules */
wire RegDst, Branch, NEqual, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Jump, Jal, Jr;
reg  double;
wire Fp, next_double, Load_store_fp, Bclt, FpCond;
wire [1:0] ALUOp;
wire [3:0] ALUCtrl;

wire        Zero;
wire [31:0] reg_data_1_1;
wire [31:0] reg_data_2_1;
wire [31:0] reg_data_1_2;
wire [31:0] reg_data_2_2;
wire [31:0] ALU_result;
wire [31:0] ALU_fp_result_1;
wire [31:0] ALU_fp_result_2;
wire [31:0] real_ALU_result = Fp & ~Load_store_fp? ALU_fp_result_1 : ALU_result;


/* Jump */
wire [31:0] added_addr  = pc + 32'd4;
wire [31:0] branch_addr = added_addr + (extimm << 2);
wire [31:0] jump_addr   = { added_addr[31:28], IR[25:0], 2'b00 };

/* muxes */
wire [ 4:0] write_reg = Jal? 5'd31: (RegDst? rd : rt);
wire [31:0] ALUInput  = ALUSrc? extimm : reg_data_2;
wire [31:0] DatatoReg = Jal? added_addr : (MemtoReg? ReadDataMem : real_ALU_result);
wire        isBranch  = (Fp & ~rs[4] & FpCond) | (Branch & (NEqual ^ Zero));
wire [31:0] branched  = isBranch? branch_addr : added_addr;
wire [31:0] jumped    = Jump? jump_addr : branched;


/* output wires */
assign CEN = WEN & OEN;
assign WEN = ~MemWrite;
assign OEN = ~MemRead;
assign A   = ALU_result[8:2];
assign Data2Mem = reg_data_2;
assign next_pc  = Jr? reg_data_1 : jumped;
assign IR_addr  = pc;


assign next_double = (Fp & rs[0])? ~double : double;

always@(posedge clk) begin
    if (~rst_n) begin
        pc <= 32'b0;
        double <= 1'b0;
    end
    else begin
        pc <= (Fp & rs[0] & ~double)? pc : next_pc;
        double <= next_double;
    end
end
	

//==== wire connection to submodule ======================
Register mips_reg(
   .clk(clk),
   .rst_n(rst_n),
   .read_reg_1(rs),
   .read_reg_2(rt),
   .write_reg(write_reg),
   .write_data_1(DatatoReg),
   .write_data_2(ALU_fp_result_2),
   .RegWrite(RegWrite),
   .Fp(Fp),
   .double(double),
   .Load_store_fp(Load_store_fp),
   .read_data_1_1(reg_data_1_1),
   .read_data_2_1(reg_data_2_1),
   .read_data_1_2(reg_data_1_2),
   .read_data_2_2(reg_data_2_2)
);

Control ctrl(
    .opcode(opcode),
    .funct(funct),
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
    .Bclt(Bclt)
);

ALU_control alu_ctrl(
    .funct(funct),
    .ALUOp(ALUOp),
    .ALUCtrl(ALUCtrl)
);

ALU alu(
    .in0(reg_data_1),
    .in1(ALUInput),
    .ALUCtrl(ALUCtrl),
    .shamt(shamt),
    .Zero(Zero),
    .ALUResult(ALU_result)
);

ALU_fp alu_fp(
    .FpCond(FpCond),
    .ALUResult_1(ALU_fp_result_1),
    .ALUResult_2(ALU_fp_result_2)
);

//==== combinational part =================================
/*
always@(*)begin

end

//==== sequential part ====================================
always@(posedge clk)begin
    if (rst_n) begin
        CEN      <= 1'b1;
        WEN      <= 1'b1;
        OEN      <= 1'b1;
        A        <= 7'b0;
        Data2Mem <= 32'b0;
        IR_addr  <= 32'b0;
    end
    else begin
        CEN      <= ~(MemRead & MemWrite);
        WEN      <= ~MemWrite;
        OEN      <= ~MemRead;
        A        <= ALU_result;
        Data2Mem <= reg_data_2;
        IR_addr  <= Jump? jump_addr : branched;
    end

end
*/
endmodule


