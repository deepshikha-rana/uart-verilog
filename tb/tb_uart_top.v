`timescale 1ns/1ps

module testbench;
    parameter CLK_FREQ  = 50_000_000;
    parameter BAUD_RATE = 9600;
    parameter CLK_PERIOD = 20;

    reg clk = 0;
    reg rst_n = 0;
    reg tx_start = 0;
    reg [7:0] tx_data = 0;
    wire tx, tx_busy;
    wire [7:0] rx_data;
    wire rx_done;

    uart_top #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) dut (
        .clk(clk), .rst_n(rst_n),
        .tx_start(tx_start), .tx_data(tx_data),
        .tx(tx), .tx_busy(tx_busy),
        .rx(tx),
        .rx_data(rx_data), .rx_done(rx_done)
    );

    always #(CLK_PERIOD/2) clk = ~clk;
    integer errors = 0;

    task send_byte(input [7:0] data);
        begin
            wait (tx_busy == 1'b0);
            @(posedge clk);
            tx_data  = data;
            tx_start = 1;
            @(posedge clk);
            tx_start = 0;
            wait (rx_done == 1'b1);
            if (rx_data !== data) begin
                $display("FAIL: sent 0x%0h, received 0x%0h", data, rx_data);
                errors = errors + 1;
            end else begin
                $display("PASS: sent 0x%0h, received 0x%0h", data, rx_data);
            end
            @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);
        rst_n = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;
        send_byte(8'hA5);
        send_byte(8'h3C);
        send_byte(8'h00);
        send_byte(8'hFF);
        send_byte(8'h55);
        if (errors == 0) $display("ALL TESTS PASSED");
        else $display("%0d TEST(S) FAILED", errors);
        $finish;
    end
endmodule

