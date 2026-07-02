`timescale 1ns / 1ps

// 简单事件音效发生器：跳跃和得分事件触发短促方波音。
module audio_effects #(
    parameter integer CLK_HZ = 100000000,
    parameter integer JUMP_HALF_PERIOD = 56818,   // 约 880Hz
    parameter integer SCORE_HALF_PERIOD = 37879,  // 约 1320Hz
    parameter integer JUMP_DURATION = 12000000,   // 约 120ms
    parameter integer SCORE_DURATION = 16000000   // 约 160ms
)(
    input  wire clk,
    input  wire rst,
    input  wire jump_event,
    input  wire score_event,
    output reg  beep
);
    localparam [1:0] SOUND_NONE  = 2'd0;
    localparam [1:0] SOUND_JUMP  = 2'd1;
    localparam [1:0] SOUND_SCORE = 2'd2;

    reg jump_d;
    reg score_d;
    wire jump_start = jump_event & ~jump_d;
    wire score_start = score_event & ~score_d;

    reg [1:0] sound_sel;
    reg [31:0] duration_cnt;
    reg [31:0] tone_cnt;
    reg [31:0] tone_half_period;

    always @(*) begin
        case (sound_sel)
            SOUND_SCORE: tone_half_period = SCORE_HALF_PERIOD;
            SOUND_JUMP:  tone_half_period = JUMP_HALF_PERIOD;
            default:     tone_half_period = JUMP_HALF_PERIOD;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            jump_d <= 1'b0;
            score_d <= 1'b0;
            sound_sel <= SOUND_NONE;
            duration_cnt <= 32'd0;
            tone_cnt <= 32'd0;
            beep <= 1'b0;
        end else begin
            jump_d <= jump_event;
            score_d <= score_event;

            // 得分音效优先级更高，避免和跳跃音同时触发时被盖掉。
            if (score_start) begin
                sound_sel <= SOUND_SCORE;
                duration_cnt <= SCORE_DURATION;
                tone_cnt <= 32'd0;
                beep <= 1'b0;
            end else if (jump_start) begin
                sound_sel <= SOUND_JUMP;
                duration_cnt <= JUMP_DURATION;
                tone_cnt <= 32'd0;
                beep <= 1'b0;
            end else if (duration_cnt != 32'd0) begin
                duration_cnt <= duration_cnt - 1'b1;
                if (tone_cnt >= tone_half_period - 1) begin
                    tone_cnt <= 32'd0;
                    beep <= ~beep;
                end else begin
                    tone_cnt <= tone_cnt + 1'b1;
                end
            end else begin
                sound_sel <= SOUND_NONE;
                tone_cnt <= 32'd0;
                beep <= 1'b0;
            end
        end
    end
endmodule
