module ALU_fp(
    clk,
    rst_n,
    in0_0,
    in0_1,
    in1_0,
    in1_1,
    ALUCtrl,
    isDouble,
    ALUResult_0,
    ALUResult_1,
    FPcond
);

input  [31:0] in0_0;
input  [31:0] in0_1;
input  [31:0] in1_0;
input  [31:0] in1_1;
input  [3:0]  ALUCtrl;

output [31:0] ALUResult_0;
output [31:0] ALUResult_1;

reg c;
wire next_c;

wire   [31:0] result_s;
wire   [7:0]  status_s;
wire   [63:0] result_d;
wire   [7:0]  status_d;
wire   [31:0] result_mult;
wire   [7:0]  status_mult;
wire   [31:0] result_div;
wire   [7:0]  status_div;

wire          aeqb, altb, agtb, unordered;
wire   [31:0] z0, z1;
wire   [7:0]  status0, status1;

assign ALUResult_0 = ( ~ALUCtrl[3] & ~ALUCtrl[0] ) ? ( isDouble ? result_d[63:32] : result_s ) :
                     ALUCtrl[1] ? result_div : result_mult;
assign ALUResult_1 = result_d[31:0];

assign next_c = ~ALUCtrl[3] ? c :
                 ALUCtrl[1] ? aeqb :
                ~ALUCtrl[2] ? altb : ( ~agtb );



assign FPcond = c;

always@(posedge clk) begin
    if (~rst_n) begin
        c <= 1'b0;
    end
    else begin
        c <= next_c;
    end
end

DW_fp_addsub addsub_s(
   a(in0_0),
   b(in1_0),
   rnd(3'b0),
   op(ALUCtrl[2]),
   z(result_s),
   status(status_s)
);

DW_fp_addsub #(.sig_width(52), exp_width(11)) addsub_d(
   a( {in0_0, in0_1} ),
   b( {in1_0, in1_1} ),
   rnd(3'b0),
   op(ALUCtrl[2]),
   z(result_d),
   status(status_d)
);

DW_fp_mult mult(
    a(in0_0),
    b(in1_0),
    rnd(3'b0),
    z(result_mult),
    status(status_mult)
);

DW_fp_div div(
    a(in0_0),
    b(in1_0),
    rnd(3'b0),
    z(result_div),
    status(status_div)
);

DW_fp_cmp cmp(
    a(in0_0),
    b(in1_0),
    zctr(1'b0),
    aeqb(aeqb),
    altb(altb),
    agtb(agtb),
    unordered(unordered),
    z0(z0),
    z1(z1),
    status0(status0),
    status1(status1)
);

endmodule
