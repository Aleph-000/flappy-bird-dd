`timescale 1ns / 1ps

// ============================================================
// Module: bird_layer
// Function:
//   Draw bird layer according to current pixel position.
//
// Input:
//   pixel_x / pixel_y:
//      current VGA pixel coordinate
//
//   bird_x / bird_y:
//      center coordinate of the bird
//
// Output:
//   bird_on:
//      1 means current pixel belongs to the bird
//
//   bird_rgb:
//      bird color in 12-bit RGB format
// ============================================================

module bird_layer(
    input  wire [9:0] pixel_x, // 当前像素横坐标
    input  wire [9:0] pixel_y, // 当前像素纵坐标

    input  wire signed [15:0] bird_x, // 小鸟中心横坐标
    input  wire signed [15:0] bird_y, // 小鸟中心纵坐标

    output wire        bird_on,  // 当前像素是否属于小鸟
    output reg  [11:0] bird_rgb  // 小鸟层输出颜色，12-bit RGB
);

    // ========================================================
    // Basic parameters
    // ========================================================

    localparam signed [15:0] BIRD_WIDTH  = 16'sd64;
    localparam signed [15:0] BIRD_HEIGHT = 16'sd48;

    // ========================================================
    // Color palette
    // ========================================================

    localparam [11:0] C_BIRD       = 12'hFD0; // 小鸟身体黄色
    localparam [11:0] C_BIRD_WING  = 12'hD80; // 小鸟翅膀深黄
    localparam [11:0] C_BIRD_BEAK  = 12'hF60; // 小鸟嘴巴橙色
    localparam [11:0] C_OUTLINE    = 12'h000; // 黑色边框
    localparam [11:0] C_WHITE      = 12'hFFF; // 白色眼睛

    // ========================================================
    // Convert pixel coordinate to signed value
    // ========================================================

    wire signed [15:0] sx;
    wire signed [15:0] sy;

    assign sx = {6'b0, pixel_x};
    assign sy = {6'b0, pixel_y};

    // ========================================================
    // Bird position
    //
    // bird_x / bird_y are center coordinates.
    // Convert them to top-left coordinates for drawing.
    // ========================================================

    wire signed [15:0] bird_left;
    wire signed [15:0] bird_top;

    assign bird_left = bird_x - BIRD_WIDTH  / 2;
    assign bird_top  = bird_y - BIRD_HEIGHT / 2;

    // ========================================================
    // Bird local coordinate
    //
    // bird_dx / bird_dy are coordinates inside the bird box.
    // ========================================================

    wire signed [15:0] bird_dx;
    wire signed [15:0] bird_dy;

    assign bird_dx = sx - bird_left;
    assign bird_dy = sy - bird_top;

    // ========================================================
    // Bird region
    // ========================================================

    assign bird_on =
        (sx >= bird_left) &&
        (sx <  bird_left + BIRD_WIDTH) &&
        (sy >= bird_top) &&
        (sy <  bird_top + BIRD_HEIGHT);

    // ========================================================
    // Bird parts
    //
    // 这一版仍然是简单坐标画法：
    //   body    : yellow
    //   wing    : dark yellow
    //   beak    : orange
    //   eye     : white
    //   outline : black
    //
    // 后面如果要美化，可以在这个模块内部改成 sprite ROM，
    // display 顶层不需要跟着大改。
    // ========================================================

    wire bird_outline;
    wire bird_wing;
    wire bird_beak;
    wire bird_eye;

    assign bird_outline =
        bird_on &&
        (
            (bird_dx < 16'sd3) ||
            (bird_dx >= BIRD_WIDTH - 16'sd3) ||
            (bird_dy < 16'sd3) ||
            (bird_dy >= BIRD_HEIGHT - 16'sd3)
        );

    assign bird_wing =
        bird_on &&
        (bird_dx >= 16'sd12) && (bird_dx < 16'sd30) &&
        (bird_dy >= 16'sd25) && (bird_dy < 16'sd38);

    assign bird_beak =
        bird_on &&
        (bird_dx >= 16'sd48) && (bird_dx < 16'sd64) &&
        (bird_dy >= 16'sd18) && (bird_dy < 16'sd30);

    assign bird_eye =
        bird_on &&
        (bird_dx >= 16'sd40) && (bird_dx < 16'sd48) &&
        (bird_dy >= 16'sd10) && (bird_dy < 16'sd18);

    // ========================================================
    // Bird color priority
    //
    // 后面的颜色覆盖前面的颜色：
    // body < wing < beak < eye < outline
    // ========================================================

    always @(*) begin
        bird_rgb = C_BIRD;

        if (bird_wing)
            bird_rgb = C_BIRD_WING;

        if (bird_beak)
            bird_rgb = C_BIRD_BEAK;

        if (bird_eye)
            bird_rgb = C_WHITE;

        if (bird_outline)
            bird_rgb = C_OUTLINE;
    end

endmodule