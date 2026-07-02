`timescale 1ns / 1ps

// ============================================================
// Module: pipe_layer
// Function:
//   Draw pipe layer for Flappy Bird.
//
// Input:
//   pixel_x / pixel_y:
//      current VGA pixel coordinate
//
//   gap_left / gap_right / gap_top / gap_bottom:
//      the passable gap area of each pipe
//
// Output:
//   pipe_on:
//      1 means current pixel belongs to a pipe
//
//   pipe_rgb:
//      pipe color in 12-bit RGB format
// ============================================================

module pipe_layer(
    input  wire [9:0] pixel_x, // 当前像素横坐标
    input  wire [9:0] pixel_y, // 当前像素纵坐标

    // ========================================================
    // Pipe0 gap coordinates
    // gap 表示"可通过空隙"，不是管道本体
    // ========================================================
    input  wire signed [15:0] gap_left0,    // 第0根管道空隙左边界
    input  wire signed [15:0] gap_right0,   // 第0根管道空隙右边界
    input  wire signed [15:0] gap_top0,     // 第0根管道空隙上边界
    input  wire signed [15:0] gap_bottom0,  // 第0根管道空隙下边界

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

    output wire        pipe_on,  // 当前像素是否属于任意一根管道
    output wire [11:0] pipe_rgb  // 管道颜色，12-bit RGB
);

    // ========================================================
    // Basic parameters
    // ========================================================

    localparam signed [15:0] GROUND_Y = 16'sd420; // 地面开始位置，管道不画到地面以下

    // ========================================================
    // Color palette
    // ========================================================

    localparam [11:0] C_PIPE = 12'h0C2; // 管道绿色

    assign pipe_rgb = C_PIPE;

    // ========================================================
    // Convert pixel coordinate to signed value
    // ========================================================

    wire signed [15:0] sx; // 当前像素横坐标 signed 版本
    wire signed [15:0] sy; // 当前像素纵坐标 signed 版本

    assign sx = {6'b0, pixel_x};
    assign sy = {6'b0, pixel_y};

    // ========================================================
    // Pipe0
    //
    // x 在 gap_left0 ~ gap_right0 内；
    // y < gap_top0 是上管道；
    // y >= gap_bottom0 是下管道；
    // 中间 gap_top0 ~ gap_bottom0 是空隙。
    // ========================================================

    wire pipe0_x_on;
    wire pipe0_y_on;
    wire pipe0_on;

    assign pipe0_x_on =
        (sx >= gap_left0) &&
        (sx <  gap_right0);

    assign pipe0_y_on =
        (sy <  gap_top0) ||
        (sy >= gap_bottom0);

    assign pipe0_on =
        pipe0_x_on &&
        pipe0_y_on &&
        (sy < GROUND_Y);


    // ========================================================
    // Pipe1
    // ========================================================

    wire pipe1_x_on;
    wire pipe1_y_on;
    wire pipe1_on;

    assign pipe1_x_on =
        (sx >= gap_left1) &&
        (sx <  gap_right1);

    assign pipe1_y_on =
        (sy <  gap_top1) ||
        (sy >= gap_bottom1);

    assign pipe1_on =
        pipe1_x_on &&
        pipe1_y_on &&
        (sy < GROUND_Y);


    // ========================================================
    // Pipe2
    // ========================================================

    wire pipe2_x_on;
    wire pipe2_y_on;
    wire pipe2_on;

    assign pipe2_x_on =
        (sx >= gap_left2) &&
        (sx <  gap_right2);

    assign pipe2_y_on =
        (sy <  gap_top2) ||
        (sy >= gap_bottom2);

    assign pipe2_on =
        pipe2_x_on &&
        pipe2_y_on &&
        (sy < GROUND_Y);


    // ========================================================
    // Pipe3
    // ========================================================

    wire pipe3_x_on;
    wire pipe3_y_on;
    wire pipe3_on;

    assign pipe3_x_on =
        (sx >= gap_left3) &&
        (sx <  gap_right3);

    assign pipe3_y_on =
        (sy <  gap_top3) ||
        (sy >= gap_bottom3);

    assign pipe3_on =
        pipe3_x_on &&
        pipe3_y_on &&
        (sy < GROUND_Y);


    // ========================================================
    // Pipe4
    // ========================================================

    wire pipe4_x_on;
    wire pipe4_y_on;
    wire pipe4_on;

    assign pipe4_x_on =
        (sx >= gap_left4) &&
        (sx <  gap_right4);

    assign pipe4_y_on =
        (sy <  gap_top4) ||
        (sy >= gap_bottom4);

    assign pipe4_on =
        pipe4_x_on &&
        pipe4_y_on &&
        (sy < GROUND_Y);


    // ========================================================
    // Total pipe signal
    //
    // 只要当前像素属于任意一根管道，就认为 pipe_on = 1。
    // 因为所有管道当前画法相同，所以不需要区分是哪一根。
    // ========================================================

    assign pipe_on =
        pipe0_on ||
        pipe1_on ||
        pipe2_on ||
        pipe3_on ||
        pipe4_on;

endmodule