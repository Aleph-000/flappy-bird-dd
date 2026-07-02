`timescale 1ns / 1ps

// 小鸟状态机和纵向物理模型。
module bird #(
    parameter SCREEN_WIDTH = 16'd640,
    parameter SCREEN_HEIGHT = 16'd480,
    parameter BIRD_WIDTH = 16'd21,
    parameter BIRD_HEIGHT = 16'd16,

    parameter IDLE = 2'b00,
    parameter PLAY = 2'b01,
    parameter GAMEOVER = 2'b10,
    parameter PAUSE = 2'b11,

    parameter signed [15:0] JUMP_V = -9,
    parameter signed [15:0] GRAVITY = 1,
    parameter integer FRAC_BITS = 4
)(
    input  wire clk,
    input  wire rst,
    input  wire jump_ctrl,
    input  wire pause_ctrl,
    input  wire collision,
    input  wire [1:0] gravity_sel,
    input  wire [1:0] jump_sel,
    output wire signed [15:0] bird_x,
    output wire signed [15:0] bird_y,
    output reg  [1:0] game_state
);
    assign bird_x = 16'd250;

    reg signed [23:0] bird_y_fixed;
    reg signed [23:0] bird_v_fixed;
    reg signed [23:0] gravity_fixed;
    reg signed [23:0] jump_v_fixed;

    assign bird_y = bird_y_fixed >>> FRAC_BITS;

    // SW[7:6] 选择重力档位，使用 4 位小数定点数表示小于 1 像素/帧^2 的加速度。
    always @(*) begin
        case (gravity_sel)
            2'b01: gravity_fixed = 24'sd6;   // 0.375 像素/帧^2
            2'b10: gravity_fixed = 24'sd8;   // 0.500 像素/帧^2
            2'b11: gravity_fixed = 24'sd12;  // 0.750 像素/帧^2
            default: gravity_fixed = 24'sd4;  // 0.250 像素/帧^2
        endcase
    end

    // SW[9:8] 选择跳跃初速度，00 为原始速度的一半，11 接近原始速度。
    always @(*) begin
        case (jump_sel)
            2'b01: jump_v_fixed = -24'sd96;   // -6.0 像素/帧
            2'b10: jump_v_fixed = -24'sd120;  // -7.5 像素/帧
            2'b11: jump_v_fixed = -24'sd144;  // -9.0 像素/帧
            default: jump_v_fixed = -24'sd72; // -4.5 像素/帧，原始速度的一半
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            game_state <= IDLE;
            bird_y_fixed <= (SCREEN_HEIGHT / 2) <<< FRAC_BITS;
            bird_v_fixed <= 24'sd0;
        end else begin
            case (game_state)
                IDLE: begin
                    bird_y_fixed <= (SCREEN_HEIGHT / 2) <<< FRAC_BITS;
                    bird_v_fixed <= 24'sd0;
                    if (jump_ctrl)
                        game_state <= PLAY;
                end

                PLAY: begin
                    if (collision) begin
                        game_state <= GAMEOVER;
                    end else if (pause_ctrl) begin
                        game_state <= PAUSE;
                    end else if (jump_ctrl) begin
                        bird_v_fixed <= jump_v_fixed + gravity_fixed;
                        bird_y_fixed <= bird_y_fixed + jump_v_fixed + gravity_fixed;
                    end else begin
                        bird_v_fixed <= bird_v_fixed + gravity_fixed;
                        bird_y_fixed <= bird_y_fixed + bird_v_fixed + gravity_fixed;
                    end
                end

                GAMEOVER: begin
                    // 等待 restart_level 触发外部复位。
                end

                PAUSE: begin
                    if (jump_ctrl || pause_ctrl)
                        game_state <= PLAY;
                end

                default: begin
                    game_state <= IDLE;
                end
            endcase
        end
    end
endmodule
