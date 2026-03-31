module fifo_mem #(
    // parameter declaration
    parameter int WIDTH  = 8,
    parameter int DEPTH  = 16,
    parameter int ADDR_W = $clog2(DEPTH)
)(
    // input signal declaration
    input  logic              clk,
    input  logic              wr_en,
    input  logic [ADDR_W-1:0] wr_addr,
    input  logic [WIDTH-1:0]  wr_data,

    input  logic              rd_en,
    input  logic [ADDR_W-1:0] rd_addr,
    
    // output signal declaration
    output logic [WIDTH-1:0]  rd_data
);

    logic [WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @(posedge clk) begin
        if (wr_en)
            mem[wr_addr] <= wr_data;
    end

    // Registered read
    always_ff @(posedge clk) begin
        if (rd_en)
            rd_data <= mem[rd_addr];
    end

endmodule