`timescale 1ns/1ps
// ========== fifo_if.sv ==========

interface fifo_if(input logic clk);

    logic rst_n;
    logic wr_en;
    logic rd_en;
    logic [7:0] wr_data;
    logic [7:0] rd_data;

    logic full;
    logic empty;
    logic almost_full;
    logic almost_empty;
    logic overflow;
    logic underflow;

endinterface


// ========== fifo_txn.sv ==========
 
class fifo_txn;

    rand bit wr_en;
    rand bit rd_en;
    rand bit [7:0] wr_data;

    bit [7:0] rd_data;

    constraint valid_c {
        !(wr_en && rd_en);   // avoid simultaneous rd+wr initially
    }

    function void display();
        $display("wr_en=%0d rd_en=%0d wr_data=%0h rd_data=%0h",
             wr_en, rd_en, wr_data, rd_data);
    endfunction

endclass

// ========== fifo_driver.sv ==========

class driver;

    virtual fifo_if vif;
    mailbox gen2drv;

    function new(virtual fifo_if vif, mailbox gen2drv);
        this.vif = vif;
        this.gen2drv = gen2drv;
    endfunction
    
    task run();
        fifo_txn tr;

        forever begin
            gen2drv.get(tr);

            @(posedge vif.clk);
            vif.wr_en   = tr.wr_en;
            vif.rd_en   = tr.rd_en;
            vif.wr_data = tr.wr_data;

            @(posedge vif.clk);
            vif.wr_en   = 0;
            vif.rd_en   = 0;
        end
    endtask

endclass

// ========== fifo_scoreboard.sv ==========

class scoreboard;

    bit [7:0] ref_q[$];

    task write(bit [7:0] data);
        ref_q.push_back(data);
    endtask

    task read(bit [7:0] actual);
        bit [7:0] expected;

        if(ref_q.size() > 0) begin
            expected = ref_q.pop_front();

            if(expected == actual)
                $display("PASS expected=%0h actual=%0h", expected, actual);
            else
                $display("FAIL expected=%0h actual=%0h", expected, actual);
        end
    endtask

endclass

// ========== fifo_monitor.sv ==========

class monitor;

    virtual fifo_if vif;
    scoreboard scb;   // ✅ add scoreboard handle

    function new(virtual fifo_if vif, scoreboard scb);
        this.vif = vif;
        this.scb = scb;
    endfunction

    task run();
        forever begin
            @(posedge vif.clk);
            #1;

            // WRITE operation
            if (vif.wr_en && !vif.full) begin
                scb.write(vif.wr_data);
            end

            // READ operation
            if (vif.rd_en && !vif.empty) begin
                scb.read(vif.rd_data);
            end

            $display("MONITOR wr=%0d rd=%0d wr_data=%0h rd_data=%0h full=%0d empty=%0d",
                 vif.wr_en,
                 vif.rd_en,
                 vif.wr_data,
                 vif.rd_data,
                 vif.full,
                 vif.empty);
        end
    endtask

endclass

// ========== fifo_generator.sv ==========

class generator;

    mailbox gen2drv;

    function new(mailbox gen2drv);
        this.gen2drv = gen2drv;
    endfunction

    task run();
        fifo_txn tr;

        repeat(100) begin
            tr = new();
            assert(tr.randomize());
            gen2drv.put(tr);
            tr.display();
        end
    endtask

endclass

// ========== fifo_tb_top.sv ==========

module fifo_tb;

    logic clk;

    fifo_if vif(clk);

    fifo_top dut(
        .clk(clk),
        .rst_n(vif.rst_n),
        .wr_en(vif.wr_en),
        .rd_en(vif.rd_en),
        .wr_data(vif.wr_data),
        .rd_data(vif.rd_data),
        .full(vif.full),
        .empty(vif.empty),
        .almost_full(vif.almost_full),
        .almost_empty(vif.almost_empty),
        .overflow(vif.overflow),
        .underflow(vif.underflow)
    );

    driver drv;
    monitor mon;
    generator gen;
    scoreboard scb;   // ✅ add scoreboard

    mailbox gen2drv;

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin

        gen2drv = new();
        scb = new();              // ✅ create scoreboard

        gen = new(gen2drv);
        drv = new(vif, gen2drv);
        mon = new(vif, scb);      // ✅ pass scoreboard

        // reset
        vif.rst_n = 0;
        vif.wr_en = 0;
        vif.rd_en = 0;
        vif.wr_data = 0;

        #20;
        vif.rst_n = 1;

        fork
            gen.run();
            drv.run();
            mon.run();
        join_none

        #500;
        $finish;

    end

endmodule