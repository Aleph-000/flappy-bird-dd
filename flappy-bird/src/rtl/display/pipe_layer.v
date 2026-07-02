`timescale 1ns / 1ps

// 管子显示层：根据 5 组 gap 坐标绘制上下管道。
// gap 表示可通过空隙，管子本体在 gap 上方和下方。
module pipe_layer(
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    input  wire [2:0] background_id,

    input  wire signed [15:0] gap_left0,
    input  wire signed [15:0] gap_right0,
    input  wire signed [15:0] gap_top0,
    input  wire signed [15:0] gap_bottom0,
    input  wire signed [15:0] gap_left1,
    input  wire signed [15:0] gap_right1,
    input  wire signed [15:0] gap_top1,
    input  wire signed [15:0] gap_bottom1,
    input  wire signed [15:0] gap_left2,
    input  wire signed [15:0] gap_right2,
    input  wire signed [15:0] gap_top2,
    input  wire signed [15:0] gap_bottom2,
    input  wire signed [15:0] gap_left3,
    input  wire signed [15:0] gap_right3,
    input  wire signed [15:0] gap_top3,
    input  wire signed [15:0] gap_bottom3,
    input  wire signed [15:0] gap_left4,
    input  wire signed [15:0] gap_right4,
    input  wire signed [15:0] gap_top4,
    input  wire signed [15:0] gap_bottom4,

    output wire        pipe_on,
    output wire [11:0] pipe_rgb
);
    localparam signed [15:0] GROUND_Y = 16'sd420;

    localparam [2:0] BG_CITY    = 3'd0;
    localparam [2:0] BG_LAB     = 3'd1;
    localparam [2:0] BG_SPACE   = 3'd2;
    localparam [2:0] BG_ZJG     = 3'd3;
    localparam [2:0] BG_NIGHT   = 3'd4;
    localparam [2:0] BG_DEFAULT = 3'd5;

    wire signed [15:0] sx = {6'b0, pixel_x};
    wire signed [15:0] sy = {6'b0, pixel_y};

    wire pipe0_on = (sx >= gap_left0) && (sx < gap_right0) &&
                    ((sy < gap_top0) || (sy >= gap_bottom0)) && (sy < GROUND_Y);
    wire pipe1_on = (sx >= gap_left1) && (sx < gap_right1) &&
                    ((sy < gap_top1) || (sy >= gap_bottom1)) && (sy < GROUND_Y);
    wire pipe2_on = (sx >= gap_left2) && (sx < gap_right2) &&
                    ((sy < gap_top2) || (sy >= gap_bottom2)) && (sy < GROUND_Y);
    wire pipe3_on = (sx >= gap_left3) && (sx < gap_right3) &&
                    ((sy < gap_top3) || (sy >= gap_bottom3)) && (sy < GROUND_Y);
    wire pipe4_on = (sx >= gap_left4) && (sx < gap_right4) &&
                    ((sy < gap_top4) || (sy >= gap_bottom4)) && (sy < GROUND_Y);

    assign pipe_on = pipe0_on || pipe1_on || pipe2_on || pipe3_on || pipe4_on;

    wire pipe_edge_on =
        pipe_on &&
        (
            (sx == gap_left0) || (sx == gap_right0 - 16'sd1) ||
            (sx == gap_left1) || (sx == gap_right1 - 16'sd1) ||
            (sx == gap_left2) || (sx == gap_right2 - 16'sd1) ||
            (sx == gap_left3) || (sx == gap_right3 - 16'sd1) ||
            (sx == gap_left4) || (sx == gap_right4 - 16'sd1)
        );

    wire pipe_shadow_on =
        pipe_on &&
        (
            (sx > gap_left0 + 16'sd18 && sx < gap_right0) ||
            (sx > gap_left1 + 16'sd18 && sx < gap_right1) ||
            (sx > gap_left2 + 16'sd18 && sx < gap_right2) ||
            (sx > gap_left3 + 16'sd18 && sx < gap_right3) ||
            (sx > gap_left4 + 16'sd18 && sx < gap_right4)
        );

    wire [11:0] pipe_main =
        (background_id == BG_SPACE) ? 12'h5CF :
        (background_id == BG_ZJG)   ? 12'hA5F :
        (background_id == BG_NIGHT) ? 12'h3A8 :
        (background_id == BG_LAB)   ? 12'h2B9 :
        (background_id == BG_CITY)  ? 12'h1C6 :
                                      12'h0C2;

    wire [11:0] pipe_edge =
        (background_id == BG_SPACE) ? 12'hEFF :
        (background_id == BG_ZJG)   ? 12'hF9D :
        (background_id == BG_NIGHT) ? 12'h8FD :
        (background_id == BG_LAB)   ? 12'h9FD :
        (background_id == BG_CITY)  ? 12'hBFE :
                                      12'h7F5;

    wire [11:0] pipe_shadow =
        (background_id == BG_SPACE) ? 12'h247 :
        (background_id == BG_ZJG)   ? 12'h527 :
        (background_id == BG_NIGHT) ? 12'h154 :
        (background_id == BG_LAB)   ? 12'h176 :
        (background_id == BG_CITY)  ? 12'h074 :
                                      12'h062;

    assign pipe_rgb = pipe_edge_on ? pipe_edge :
                      (pipe_shadow_on ? pipe_shadow : pipe_main);
endmodule
