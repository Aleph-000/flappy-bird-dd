`timescale 1ns / 1ps

// 小鸟显示层：使用 21x21 sprite 绘制；碰撞高度仍在 collision.v 中按 21x16 计算。
module bird_layer(
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    input  wire signed [15:0] bird_x,
    input  wire signed [15:0] bird_y,
    input  wire [1:0] game_state,
    input  wire [2:0] skin_id,
    input  wire [2:0] frame_index,
    output wire       bird_on,
    output wire [11:0] bird_rgb
);
    localparam [1:0] IDLE = 2'b00;
    localparam signed [15:0] SPRITE_SIZE = 16'sd21;
    localparam signed [15:0] IDLE_PREVIEW_X = 16'sd320;
    localparam signed [15:0] IDLE_PREVIEW_Y = 16'sd185;

    wire signed [15:0] sx = {6'b0, pixel_x};
    wire signed [15:0] sy = {6'b0, pixel_y};

    // IDLE 界面显示居中的皮肤预览；游戏中按物理坐标绘制。
    wire signed [15:0] draw_x = (game_state == IDLE) ? IDLE_PREVIEW_X : bird_x;
    wire signed [15:0] draw_y = (game_state == IDLE) ? IDLE_PREVIEW_Y : bird_y;
    wire signed [15:0] sprite_left = draw_x - SPRITE_SIZE / 2;
    wire signed [15:0] sprite_top  = draw_y - SPRITE_SIZE / 2;
    wire signed [15:0] local_x_signed = sx - sprite_left;
    wire signed [15:0] local_y_signed = sy - sprite_top;

    wire in_sprite_box =
        (local_x_signed >= 16'sd0) && (local_x_signed < SPRITE_SIZE) &&
        (local_y_signed >= 16'sd0) && (local_y_signed < SPRITE_SIZE);

    wire [4:0] local_x = in_sprite_box ? local_x_signed[4:0] : 5'd0;
    wire [4:0] local_y = in_sprite_box ? local_y_signed[4:0] : 5'd0;
    wire sprite_alpha;
    wire [11:0] sprite_rgb;

    bird_sprite_rom u_sprite_rom (
        .skin_id(skin_id),
        .frame_index(frame_index),
        .sprite_x(local_x),
        .sprite_y(local_y),
        .alpha(sprite_alpha),
        .rgb(sprite_rgb)
    );

    assign bird_on = in_sprite_box && sprite_alpha;
    assign bird_rgb = sprite_rgb;
endmodule
