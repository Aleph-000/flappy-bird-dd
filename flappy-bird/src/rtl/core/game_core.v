`timescale 1ns / 1ps

// 游戏核心包装层：连接 bird、pipe、collision，并生成低速游戏时钟和分数。
module game_core #(
    parameter integer CLK_HZ = 100000000,
    parameter integer GAME_HZ = 60
)(
    input  wire clk,
    input  wire rst,
    input  wire jump_level,
    input  wire pause_level,
    input  wire restart_level,
    input  wire immortal,
    input  wire [1:0] speed_sel,
    output wire signed [15:0] bird_x,
    output wire signed [15:0] bird_y,
    output wire [1:0] game_state,
    output wire collision_hit,
    output reg  [15:0] score,
    output wire signed [15:0] gap_left0,
    output wire signed [15:0] gap_right0,
    output wire signed [15:0] gap_top0,
    output wire signed [15:0] gap_bottom0,
    output wire signed [15:0] gap_left1,
    output wire signed [15:0] gap_right1,
    output wire signed [15:0] gap_top1,
    output wire signed [15:0] gap_bottom1,
    output wire signed [15:0] gap_left2,
    output wire signed [15:0] gap_right2,
    output wire signed [15:0] gap_top2,
    output wire signed [15:0] gap_bottom2,
    output wire signed [15:0] gap_left3,
    output wire signed [15:0] gap_right3,
    output wire signed [15:0] gap_top3,
    output wire signed [15:0] gap_bottom3,
    output wire signed [15:0] gap_left4,
    output wire signed [15:0] gap_right4,
    output wire signed [15:0] gap_top4,
    output wire signed [15:0] gap_bottom4
);
    localparam signed [15:0] BIRD_HALF_WIDTH = 16'sd32;

    reg [31:0] game_cnt;
    reg        game_clk;
    reg [31:0] half_period;

    // SW[5:4] 控制游戏速度，默认 60Hz。
    always @(*) begin
        case (speed_sel)
            2'b01: half_period = CLK_HZ / (75 * 2);
            2'b10: half_period = CLK_HZ / (90 * 2);
            2'b11: half_period = CLK_HZ / (120 * 2);
            default: half_period = CLK_HZ / (GAME_HZ * 2);
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            game_cnt <= 32'd0;
            game_clk <= 1'b0;
        end else if (game_cnt >= half_period - 1) begin
            game_cnt <= 32'd0;
            game_clk <= ~game_clk;
        end else begin
            game_cnt <= game_cnt + 1'b1;
        end
    end

    reg jump_d;
    reg pause_d;
    reg restart_d;
    // 控制信号在游戏时钟域内做边沿检测，避免长按时每帧重复触发。
    always @(posedge game_clk or posedge rst) begin
        if (rst) begin
            jump_d <= 1'b0;
            pause_d <= 1'b0;
            restart_d <= 1'b0;
        end else begin
            jump_d <= jump_level;
            pause_d <= pause_level;
            restart_d <= restart_level;
        end
    end

    wire jump_pulse = jump_level & ~jump_d;
    wire pause_pulse = pause_level & ~pause_d;
    wire restart_pulse = restart_level & ~restart_d;
    wire bird_rst = rst | restart_pulse;
    wire collision_to_bird;

    bird u_bird (
        .clk(game_clk),
        .rst(bird_rst),
        .jump_ctrl(jump_pulse),
        .pause_ctrl(pause_pulse),
        .collision(collision_to_bird),
        .bird_x(bird_x),
        .bird_y(bird_y),
        .game_state(game_state)
    );

    pipe u_pipe (
        .clk(game_clk),
        .score(score),
        .game_state(game_state),
        .gap_left0(gap_left0),
        .gap_right0(gap_right0),
        .gap_top0(gap_top0),
        .gap_bottom0(gap_bottom0),
        .gap_left1(gap_left1),
        .gap_right1(gap_right1),
        .gap_top1(gap_top1),
        .gap_bottom1(gap_bottom1),
        .gap_left2(gap_left2),
        .gap_right2(gap_right2),
        .gap_top2(gap_top2),
        .gap_bottom2(gap_bottom2),
        .gap_left3(gap_left3),
        .gap_right3(gap_right3),
        .gap_top3(gap_top3),
        .gap_bottom3(gap_bottom3),
        .gap_left4(gap_left4),
        .gap_right4(gap_right4),
        .gap_top4(gap_top4),
        .gap_bottom4(gap_bottom4)
    );

    collision u_collision (
        .clk(game_clk),
        .score(score),
        .game_state(game_state),
        .bird_x(bird_x),
        .bird_y(bird_y),
        .gap_left0(gap_left0),
        .gap_right0(gap_right0),
        .gap_top0(gap_top0),
        .gap_bottom0(gap_bottom0),
        .gap_left1(gap_left1),
        .gap_right1(gap_right1),
        .gap_top1(gap_top1),
        .gap_bottom1(gap_bottom1),
        .gap_left2(gap_left2),
        .gap_right2(gap_right2),
        .gap_top2(gap_top2),
        .gap_bottom2(gap_bottom2),
        .gap_left3(gap_left3),
        .gap_right3(gap_right3),
        .gap_top3(gap_top3),
        .gap_bottom3(gap_bottom3),
        .gap_left4(gap_left4),
        .gap_right4(gap_right4),
        .gap_top4(gap_top4),
        .gap_bottom4(gap_bottom4),
        .collision(collision_hit)
    );

    // 无敌模式只屏蔽送入 bird 状态机的碰撞，不影响 LED 调试显示。
    assign collision_to_bird = immortal ? 1'b0 : collision_hit;

    reg signed [15:0] prev_right0;
    reg signed [15:0] prev_right1;
    reg signed [15:0] prev_right2;
    reg signed [15:0] prev_right3;
    reg signed [15:0] prev_right4;
    wire signed [15:0] score_line = bird_x - BIRD_HALF_WIDTH;

    // 管道右边界越过小鸟左边界时加分。
    always @(posedge game_clk or posedge rst) begin
        if (rst | restart_pulse) begin
            score <= 16'd0;
            prev_right0 <= 16'sd0;
            prev_right1 <= 16'sd0;
            prev_right2 <= 16'sd0;
            prev_right3 <= 16'sd0;
            prev_right4 <= 16'sd0;
        end else begin
            prev_right0 <= gap_right0;
            prev_right1 <= gap_right1;
            prev_right2 <= gap_right2;
            prev_right3 <= gap_right3;
            prev_right4 <= gap_right4;
            if (game_state == 2'b01) begin
                score <= score
                    + ((prev_right0 >= score_line) && (gap_right0 < score_line))
                    + ((prev_right1 >= score_line) && (gap_right1 < score_line))
                    + ((prev_right2 >= score_line) && (gap_right2 < score_line))
                    + ((prev_right3 >= score_line) && (gap_right3 < score_line))
                    + ((prev_right4 >= score_line) && (gap_right4 < score_line));
            end
        end
    end
endmodule
