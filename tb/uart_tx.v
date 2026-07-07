`timescale 1ns/1ps

module uart_tx #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 9600
)(
    input  wire clk,
    input  wire rst_n,
    input  wire tx_start,
    input  wire [7:0] tx_data,
    output reg  tx,
    output reg  tx_busy
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;

    reg [1:0] state = IDLE;
    reg [15:0] clk_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] data_reg = 0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; tx <= 1'b1; tx_busy <= 1'b0;
            clk_count <= 0; bit_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1; tx_busy <= 1'b0;
                    clk_count <= 0; bit_index <= 0;
                    if (tx_start) begin
                        data_reg <= tx_data; tx_busy <= 1'b1; state <= START;
                    end
                end
                START: begin
                    tx <= 1'b0;
                    if (clk_count < CLKS_PER_BIT - 1) clk_count <= clk_count + 1;
                    else begin clk_count <= 0; state <= DATA; end
                end
                DATA: begin
                    tx <= data_reg[bit_index];
                    if (clk_count < CLKS_PER_BIT - 1) clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        if (bit_index < 7) bit_index <= bit_index + 1;
                        else begin bit_index <= 0; state <= STOP; end
                    end
                end
                STOP: begin
                    tx <= 1'b1;
                    if (clk_count < CLKS_PER_BIT - 1) clk_count <= clk_count + 1;
                    else begin clk_count <= 0; tx_busy <= 1'b0; state <= IDLE; end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
