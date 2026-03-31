// # mean parameterized module
module fifo_top #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 16,
    parameter int ADDR_W = $clog2(DEPTH)
)(
    // input signal declaration
    input  logic clk,
    input  logic rst_n,

    input  logic wr_en,
    input  logic rd_en,

    input  logic [WIDTH-1:0] wr_data,
    
    // output signal declaration
    output logic [WIDTH-1:0] rd_data,

    output logic full,
    output logic empty,
    output logic almost_full,
    output logic almost_empty,

    output logic overflow,
    output logic underflow
);
    
    // write_address declaration
    logic [ADDR_W-1:0] wr_addr;
    
    // read_address declaration
    logic [ADDR_W-1:0] rd_addr;

    // calling fifo_ctrl module 
    fifo_ctrl #(
        .DEPTH(DEPTH)
    ) u_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .wr_addr(wr_addr),
        .rd_addr(rd_addr),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .overflow(overflow),
        .underflow(underflow)
    );
    
    // calling fifo_mem module
    fifo_mem #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) u_mem (
        .clk(clk),
        .wr_en(wr_en && !full),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .rd_en(rd_en && !empty),
        .rd_addr(rd_addr),
        .rd_data(rd_data)
    );

    // Assertions
    // overflow checking
    assert property (@(posedge clk) !(wr_en && full))
        else $error("FIFO Overflow");

    // underflow checking
    assert property (@(posedge clk) !(rd_en && empty))
        else $error("FIFO Underflow");

endmodule