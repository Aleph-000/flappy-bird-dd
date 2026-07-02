`timescale 1ns / 1ps

// 事件音效发生器：支持跳跃音、得分音、4 档音量和“仅得分”模式。
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
    input  wire [1:0] volume_sel,
    input  wire score_only_mode,
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
    reg tone_wave;

    reg [7:0] volume_pwm_cnt;
    reg [7:0] volume_threshold;
    reg volume_on;

    always @(*) begin
        case (sound_sel)
            SOUND_SCORE: tone_half_period = SCORE_HALF_PERIOD;
            SOUND_JUMP:  tone_half_period = JUMP_HALF_PERIOD;
            default:     tone_half_period = JUMP_HALF_PERIOD;
        endcase
    end

    // SW[11:10] 音量 4 档：低、中低、中高、满音量。
    always @(*) begin
        case (volume_sel)
            2'b00: volume_threshold = 8'd64;
            2'b01: volume_threshold = 8'd128;
            2'b10: volume_threshold = 8'd192;
            default: volume_threshold = 8'd255;
        endcase

        volume_on = (volume_sel == 2'b11) || (volume_pwm_cnt < volume_threshold);
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            jump_d <= 1'b0;
            score_d <= 1'b0;
            sound_sel <= SOUND_NONE;
            duration_cnt <= 32'd0;
            tone_cnt <= 32'd0;
            tone_wave <= 1'b0;
            volume_pwm_cnt <= 8'd0;
            beep <= 1'b0;
        end else begin
            jump_d <= jump_event;
            score_d <= score_event;
            volume_pwm_cnt <= volume_pwm_cnt + 1'b1;

            // 得分音优先；SW[12]=1 时忽略跳跃音，只保留得分音。
            if (score_start) begin
                sound_sel <= SOUND_SCORE;
                duration_cnt <= SCORE_DURATION;
                tone_cnt <= 32'd0;
                tone_wave <= 1'b0;
                beep <= 1'b0;
            end else if (jump_start && !score_only_mode) begin
                sound_sel <= SOUND_JUMP;
                duration_cnt <= JUMP_DURATION;
                tone_cnt <= 32'd0;
                tone_wave <= 1'b0;
                beep <= 1'b0;
            end else if (duration_cnt != 32'd0) begin
                duration_cnt <= duration_cnt - 1'b1;
                if (tone_cnt >= tone_half_period - 1) begin
                    tone_cnt <= 32'd0;
                    tone_wave <= ~tone_wave;
                end else begin
                    tone_cnt <= tone_cnt + 1'b1;
                end
                beep <= tone_wave & volume_on;
            end else begin
                sound_sel <= SOUND_NONE;
                tone_cnt <= 32'd0;
                tone_wave <= 1'b0;
                beep <= 1'b0;
            end
        end
    end
endmodule
