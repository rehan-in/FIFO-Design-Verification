module fifo_ctrl #(
    // parameter declaration
    parameter int DEPTH  = 16,
    parameter int ADDR_W = $clog2(DEPTH)
)(
    // input signal declaration
    input  logic clk,
    input  logic rst_n,

    input  logic wr_en,
    input  logic rd_en,

    // output signal declaration
    output logic [ADDR_W-1:0] wr_addr,
    output logic [ADDR_W-1:0] rd_addr,

    output logic full,
    output logic empty,
    output logic almost_full,
    output logic almost_empty,

    output logic overflow,
    output logic underflow
);

    // read and write pointer declaration
    logic [ADDR_W:0] wr_ptr, rd_ptr;
    
    logic [ADDR_W:0] count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr    <= '0;
            rd_ptr    <= '0;
            count     <= '0;
            overflow  <= 1'b0;
            underflow <= 1'b0;
        end
        else begin
            overflow  <= 1'b0;
            underflow <= 1'b0;

            case ({wr_en && !full, rd_en && !empty})

                2'b10: begin
                    wr_ptr <= wr_ptr + 1'b1;
                    count  <= count + 1'b1;
                end

                2'b01: begin
                    rd_ptr <= rd_ptr + 1'b1;
                    count  <= count - 1'b1;
                end

                2'b11: begin
                    wr_ptr <= wr_ptr + 1'b1;
                    rd_ptr <= rd_ptr + 1'b1;
                end

                default: begin
                end

            endcase

            if (wr_en && full)
                overflow <= 1'b1;

            if (rd_en && empty)
                underflow <= 1'b1;
        end
    end

    assign wr_addr = wr_ptr[ADDR_W-1:0];
    assign rd_addr = rd_ptr[ADDR_W-1:0];

    assign full = (count == DEPTH);
    assign empty = (count == 0);
    assign almost_full = (count == DEPTH-1);
    assign almost_empty = (count == 1);

endmodule