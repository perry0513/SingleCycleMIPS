module Register(
    clk,
	rst_n,
    read_reg_0,
    read_reg_1,
    write_reg,
    write_data_0,
    write_data_1,
    RegWrite,
    Fp,
    double,
    Load_store_fp,
    fmt0,
    read_data_0_0,
    read_data_0_1,
    read_data_1_0,
    read_data_1_1
);

input  clk;
input  rst_n;
input  RegWrite;
input  Fp;
input  double;
input  Load_store_fp;
input  fmt0;
input  [4:0] read_reg_0;
input  [4:0] read_reg_1;
input  [4:0] write_reg;
input  [31:0] write_data_0;
input  [31:0] write_data_1;

output [31:0] read_data_0_0;
output [31:0] read_data_1_0;
output [31:0] read_data_0_1;
output [31:0] read_data_1_1;

reg  [31:0]         reg_file [0:31];
reg  [31:0]    next_reg_file [0:31];
reg  [31:0]      fp_reg_file [0:31];
reg  [31:0] next_fp_reg_file [0:31];

assign read_data_0_0 = Load_store_fp? reg_file[read_reg_0] : 
                       (Fp? fp_reg_file[read_reg_0] : reg_file[read_reg_0]);
assign read_data_1_0 = Load_store_fp? fp_reg_file[read_reg_1] :
                       (Fp? fp_reg_file[read_reg_1] : reg_file[read_reg_1]);
assign read_data_0_1 = fp_reg_file[read_reg_0 + 5'b1];
assign read_data_1_1 = fp_reg_file[read_reg_1 + 5'b1];

integer k;

always@(*) begin
    for (k=0; k < 32; k=k+1) begin
        next_reg_file[k] = reg_file[k];
        next_fp_reg_file[k] = fp_reg_file[k];
    end

    if (RegWrite) begin
        if (Fp) begin
            next_fp_reg_file[write_reg] = write_data_0;
            if (double | fmt0) begin
                next_fp_reg_file[write_reg + 5'b1] = write_data_1;
            end
        end
        else begin
            next_reg_file[write_reg] = write_data_0;
        end
    end
end


always@(posedge clk) begin
    if (~rst_n) begin
        for (k=0; k < 32; k=k+1) begin
            reg_file[k]    <= 32'b0;
            fp_reg_file[k] <= 32'b0;
        end
    end
    else begin
        for (k=0; k < 32; k=k+1) begin
            reg_file[k]    <= next_reg_file[k];
            fp_reg_file[k] <= next_fp_reg_file[k];
        end
    end
end

endmodule
