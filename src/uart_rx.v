`timescale 1ns/1ps

module uart_rx #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 9600
)(
    input  wire clk,
    input  wire rst_n,
    input  wire rx,
    output reg  [7:0] rx_data,
    output reg  rx_done
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;

    reg [1:0] state = IDLE;
    reg [15:0] clk_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] data_reg = 0;
    reg rx_d1 = 1, rx_d2 = 1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin rx_d1 <= 1'b1; rx_d2 <= 1'b1; end
        else begin rx_d1 <= rx; rx_d2 <= rx_d1; end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; rx_done <= 1'b0;
            clk_count <= 0; bit_index <= 0; rx_data <= 0;
        end else begin
            case (state)
                IDLE: begin
                    rx_done <= 1'b0; clk_count <= 0; bit_index <= 0;
                    if (rx_d2 == 1'b0) state <= START;
                end
                START: begin
                    if (clk_count == (CLKS_PER_BIT - 1) / 2) begin
                        if (rx_d2 == 1'b0) begin clk_count <= 0; state <= DATA; end
                        else state <= IDLE;
                    end else clk_count <= clk_count + 1;
                end
                DATA: begin
                    if (clk_count < CLKS_PER_BIT - 1) clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        data_reg[bit_index] <= rx_d2;
                        if (bit_index < 7) bit_index <= bit_index + 1;
                        else begin bit_index <= 0; state <= STOP; end
                    end
                end
                STOP: begin
                    if (clk_count < CLKS_PER_BIT - 1) clk_count <= clk_count + 1;
                    else begin
                        rx_data <= data_reg; rx_done <= 1'b1;
                        clk_count <= 0; state <= IDLE;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule

