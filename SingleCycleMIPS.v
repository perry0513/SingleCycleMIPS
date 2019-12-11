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
reg  CEN, next_CEN;
reg  WEN, next_WEN;
reg  OEN, next_OEN;
reg  [6:0]  A, next_A;
reg  [31:0] Data2Mem, next_Data2Mem;


/* decode instructions */
wire [5:0] opcode = IR[31:26];
wire [4:0] rs     = IR[25:21];
wire [4:0] rt     = IR[20:16];
wire [4:0] rd     = IR[15:11];
wire [4:0] shamt  = IR[10: 6];
wire [5:0] funct  = IR[ 5: 0];

wire [31:0] extimm = { 16{IR[15]}, IR[15: 0]};
wire [26:0] addr   = IR[25: 0];

/* interconnections between modules */
wire RegDst, Branch, Equal, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Jal, Jr;
wire [1:0] ALUOp;
wire [3:0] ALUCtrl;

wire        Zero;
wire [31:0] reg_data_1;
wire [31:0] reg_data_2;
wire [31:0] ALU_result;
wire [31:0] mem_data;


/* Jump */
wire [31:0] added_addr  = IR_addr + 32'd4;
wire [31:0] branch_addr = added_addr + (extimm << 2);
wire [31:0] jump_addr   = { added_addr[31:28], IR[25:0], 2'b00 };

/* muxes */
wire        wr        = RegDst? rd : rs;
wire [31:0] ALUInput  = ALUSrc? extimm : reg_data_2;
wire [31:0] DatatoReg = MemtoReg? mem_data : ALU_result;
wire [31:0] branched  = (Branch & (Equal ^ Zero))? branch_addr : added_addr;
wire [31:0] jumped    = Jump? jump_addr : branched;


/* output wires */
assign CEN = ~(MemRead & MemWrite);
assign WEN = ~MemWrite;
assign OEN = ~MemRead;
assign A   = ALU_result;
assign Data2Mem = reg_data_2;
assign IR_addr  = Jr? reg_data_1 : jumped;

//==== wire connection to submodule ======================
Register mips_reg(
   .clk(clk),
   .read_reg_1(rs),
   .read_reg_2(rt),
   .write_reg(wt),
   .write_data(DatatoReg),
   .RegWrite(RegWrite),
   .Jal(Jal),
   .pc_4(added_addr),
   .read_data_1(reg_data_1),
   .read_data_2(reg_data_2)
);

Control ctrl(
    .opcode(opcode),
    .RegDst(RegDst),
    .Jump(Jump),
    .Branch(Branch),
    .Equal(Equal),
    .MemRead(MemRead),
    .MemtoReg(MemtoReg),
    .ALUOp(ALUOp),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite),
    .Jal(Jal)
);

ALU_control alu_ctrl(
    .ins(funct),
    .ALUOp(ALUOp),
    .Jr(Jr),
    .ALUCtrl(ALUCtrl)
);

ALU alu(
    .in0(reg_data_1),
    .in1(ALUInput),
    .ALUCtrl(ALUCtrl),
    .Zero(Zero),
    .ALUResult(ALU_result)
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


