`timescale 1ns / 1ps

// 背景选择控制：只在开始界面响应切换，游戏开始后锁定当前背景。
module background_control #(
    parameter integer BACKGROUND_COUNT = 4
)(
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] game_state,
    input  wire       background_next_level,
    output reg  [1:0] background_id
);
    localparam [1:0] IDLE = 2'b00;
    localparam [1:0] BACKGROUND_COUNT_VALUE = BACKGROUND_COUNT;

    reg background_next_d;
    wire background_next_pulse = background_next_level & ~background_next_d;
    wire [1:0] next_background = background_id + 2'd1;

    always @(posedge clk or posedge rst) begin
        if (rst)
            background_next_d <= 1'b0;
        else
            background_next_d <= background_next_level;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            background_id <= 2'd0;
        end else if (game_state == IDLE && background_next_pulse) begin
            if (BACKGROUND_COUNT_VALUE <= 2'd1 || next_background >= BACKGROUND_COUNT_VALUE)
                background_id <= 2'd0;
            else
                background_id <= next_background;
        end
    end
endmodule
