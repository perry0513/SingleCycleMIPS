module Register(
    clk,
    read_reg_1,
    read_reg_2,
    write_reg,
    write_data,
    RegWrite,
    read_data_1,
    read_data_2
);

input  clk;
input  RegWrite;
input  [4:0] read_reg_1;
input  [4:0] read_reg_2;
input  [4:0] write_reg;
input  [31:0] write_data;

output [31:0] read_data_1;
output [31:0] read_data_2;

reg  [31:0]      reg_file [0:31];
reg  [31:0] next_reg_file [0:31];


assign read_data_1 = reg_file[read_reg_1];
assign read_data_2 = reg_file[read_reg_2];


integer k;

always@(*) begin
    for (k=0; k < 32; k=k+1)
        next_reg_file[k] = reg_file[k];

    if (RegWrite)
        next_reg_file[write_reg] = write_data;
end


always@(posedge clk) begin
    if (~rst_n) begin
        for (k=0; k < 32; k=k+1)
            reg_file[k] <= 32'b0;
    end
    else begin
        for (k=0; k < 32; k=k+1)
            reg_file[k] <= next_reg_file[k];
    end
end

endmodule
