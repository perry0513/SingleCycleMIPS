module Register(
    clk,
	rst_n,
    read_reg_1,
    read_reg_2,
    write_reg,
    write_data_1,
    write_data_2,
    RegWrite,
    Fp,
    double,
    Load_store_fp,
    read_data_1_1,
    read_data_2_1,
    read_data_1_2,
    read_data_2_2
);

input  clk;
input  rst_n;
input  RegWrite;
input  Fp;
input  double;
input  Load_store_fp;
input  [4:0] read_reg_1;
input  [4:0] read_reg_2;
input  [4:0] write_reg;
input  [31:0] write_data_1;
input  [31:0] write_data_2;

output [31:0] read_data_1_1;
output [31:0] read_data_2_1;
output [31:0] read_data_1_2;
output [31:0] read_data_2_2;

reg  [31:0]         reg_file [0:31];
reg  [31:0]    next_reg_file [0:31];
reg  [31:0]      fp_reg_file [0:31];
reg  [31:0] next_fp_reg_file [0:31];

assign read_data_1_1 = Load_store_fp? reg_file[read_reg_1] : 
                       (Fp? fp_reg_file[read_reg_1] : reg_file[read_reg_1]);
assign read_data_2_1 = Load_store_fp? fp_reg_file[read_reg_2] :
                       (Fp? fp_reg_file[read_reg_2] : reg_file[read_reg_2]);
assign read_data_1_2 = fp_reg_file[read_reg_1 + 5'b1];
assign read_data_2_2 = fp_reg_file[read_reg_2 + 5'b1];

integer k;

always@(*) begin
    for (k=0; k < 32; k=k+1) begin
        next_reg_file[k] = reg_file[k];
        next_fp_reg_file[k] = fp_reg_file[k];
    end

    if (RegWrite) begin
        if (Fp) begin
            next_fp_reg_file[write_reg] = write_data_1;
            if (double) begin
                next_fp_reg_file[write_reg + 5'b1] = write_data_2;
            end
        end
        else begin
            next_reg_file[write_reg] = write_data_1;
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
