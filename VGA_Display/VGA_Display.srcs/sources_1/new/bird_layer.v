`timescale 1ns / 1ps

// ============================================================
// Module: bird_layer
// Function:
//   Draw bird sprite according to current pixel position.
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
//      1 means current pixel belongs to visible bird sprite
//
//   bird_rgb:
//      bird color in 12-bit RGB format
//
// Sprite:
//   size = 64 x 48
//   transparent color = 12'hF0F
// ============================================================

module bird_layer(
    input  wire [9:0] pixel_x, // 当前像素横坐标
    input  wire [9:0] pixel_y, // 当前像素纵坐标

    input  wire signed [15:0] bird_x, // 小鸟中心横坐标
    input  wire signed [15:0] bird_y, // 小鸟中心纵坐标

    output wire        bird_on,  // 当前像素是否属于可见小鸟 sprite
    output reg  [11:0] bird_rgb  // 小鸟层输出颜色，12-bit RGB
);

    // ========================================================
    // Basic parameters
    // ========================================================

    localparam signed [15:0] BIRD_WIDTH  = 16'sd64;
    localparam signed [15:0] BIRD_HEIGHT = 16'sd48;

    localparam [11:0] TRANSPARENT = 12'hF0F;

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
    // Convert them to top-left coordinate for sprite drawing.
    // ========================================================

    wire signed [15:0] bird_left;
    wire signed [15:0] bird_top;

    assign bird_left = bird_x - BIRD_WIDTH  / 2;
    assign bird_top  = bird_y - BIRD_HEIGHT / 2;

    // ========================================================
    // Bird box check
    // ========================================================

    wire bird_box_on;

    assign bird_box_on =
        (sx >= bird_left) &&
        (sx <  bird_left + BIRD_WIDTH) &&
        (sy >= bird_top) &&
        (sy <  bird_top + BIRD_HEIGHT);

    // ========================================================
    // Local coordinate inside sprite
    //
    // These coordinates are meaningful only when bird_box_on = 1.
    // ========================================================

    wire [5:0] sprite_x; // 0 ~ 63
    wire [5:0] sprite_y; // 0 ~ 47

    assign sprite_x = sx - bird_left;
    assign sprite_y = sy - bird_top;

    // ========================================================
    // Sprite address
    //
    // addr = sprite_y * 64 + sprite_x
    // Since 64 = 2^6, multiply by 64 can be implemented
    // as left shift by 6 bits.
    //
    // When current pixel is outside the bird box, use addr = 0
    // to avoid out-of-range ROM access in simulation.
    // ========================================================

    wire [11:0] sprite_addr;

    assign sprite_addr =
        bird_box_on ? ({sprite_y, 6'b0} + sprite_x) : 12'd0;

    // ========================================================
    // Sprite ROM
    // ========================================================

    wire [11:0] sprite_color;

    bird_sprite_rom u_bird_sprite_rom(
        .addr(sprite_addr),
        .color(sprite_color)
    );

    // ========================================================
    // Output logic
    //
    // bird_on only becomes 1 when:
    //   1. current pixel is inside the bird box
    //   2. sprite pixel is not transparent
    // ========================================================

    assign bird_on =
        bird_box_on &&
        (sprite_color != TRANSPARENT);

    always @(*) begin
        if (bird_on)
            bird_rgb = sprite_color;
        else
            bird_rgb = 12'h000;
    end

endmodule
