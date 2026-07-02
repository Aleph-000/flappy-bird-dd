`timescale 1ns / 1ps

// 皮肤与动画控制：支持最多 8 个皮肤，每个皮肤 1..8 帧。
module skin_control #(
    parameter integer CLK_HZ = 100000000,
    parameter integer ANIM_HZ = 10
)(
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] game_state,
    input  wire       skin_next_level,
    output reg  [2:0] skin_id,
    output reg  [2:0] frame_index
);
    localparam [1:0] IDLE = 2'b00;
    localparam integer ANIM_PERIOD = CLK_HZ / ANIM_HZ;

    reg [31:0] anim_cnt;
    reg        skin_next_d;
    wire       skin_next_pulse = skin_next_level & ~skin_next_d;
    wire [2:0] next_skin = skin_id + 3'd1;

    wire [3:0] frame_count;
    wire [3:0] next_frame_count;
    wire [2:0] last_frame = (frame_count <= 4'd1) ? 3'd0 : frame_count[2:0] - 3'd1;

    skin_info u_current_skin_info (
        .skin_id(skin_id),
        .frame_count(frame_count)
    );

    skin_info u_next_skin_info (
        .skin_id(next_skin),
        .frame_count(next_frame_count)
    );

    always @(posedge clk or posedge rst) begin
        if (rst)
            skin_next_d <= 1'b0;
        else
            skin_next_d <= skin_next_level;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            skin_id <= 3'd0;
            frame_index <= 3'd0;
        end else if (game_state == IDLE && skin_next_pulse) begin
            // 只在开始界面响应 BTN2；遇到无效皮肤编号就回到 0。
            if (next_frame_count != 4'd0)
                skin_id <= next_skin;
            else
                skin_id <= 3'd0;
            frame_index <= 3'd0;
        end else if (anim_cnt >= ANIM_PERIOD - 1) begin
            if (frame_index >= last_frame)
                frame_index <= 3'd0;
            else
                frame_index <= frame_index + 3'd1;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            anim_cnt <= 32'd0;
        end else if (anim_cnt >= ANIM_PERIOD - 1) begin
            anim_cnt <= 32'd0;
        end else begin
            anim_cnt <= anim_cnt + 1'b1;
        end
    end
endmodule
