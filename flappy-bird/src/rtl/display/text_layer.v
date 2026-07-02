`timescale 1ns / 1ps

// VGA 文字层：从字符缓存读取 ASCII，再用 8x8 字符 ROM 绘制。
module text_layer(
    input  wire       clk,
    input  wire       rst,
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    input  wire [1:0] game_state,
    input  wire [2:0] skin_id,
    input  wire [2:0] background_id,
    input  wire [15:0] score,
    output wire       text_on,
    output wire [11:0] text_rgb
);
    localparam [1:0] IDLE = 2'b00;
    localparam [9:0] ORIGIN_X = 10'd18;
    localparam [9:0] ORIGIN_Y = 10'd18;
    localparam [9:0] SCALE = 10'd2;
    localparam [9:0] CELL_W = 10'd16;
    localparam [9:0] CELL_H = 10'd16;
    localparam integer COLS = 32;
    localparam integer IDLE_ROWS = 2;
    localparam integer PLAY_ROWS = 1;

    wire [9:0] local_x = pixel_x - ORIGIN_X;
    wire [9:0] local_y = pixel_y - ORIGIN_Y;
    wire in_area = (pixel_x >= ORIGIN_X) && (pixel_y >= ORIGIN_Y) &&
                   (local_x < (COLS * CELL_W)) &&
                   (local_y < (((game_state == IDLE) ? IDLE_ROWS : PLAY_ROWS) * CELL_H));

    wire [4:0] cell_x = local_x[8:4];
    wire [1:0] cell_y = local_y[5:4];
    wire [2:0] font_col = local_x[3:1];
    wire [2:0] font_row = local_y[3:1];

    wire [7:0] ascii;
    wire [7:0] font_bits;
    wire glyph_pixel = in_area && font_bits[3'd7 - font_col];

    text_vram u_text_vram (
        .clk(clk),
        .rst(rst),
        .game_state(game_state),
        .skin_id(skin_id),
        .background_id(background_id),
        .score(score),
        .cell_x(cell_x),
        .cell_y(cell_y),
        .ascii(ascii)
    );

    font_rom_8x8 u_font_rom (
        .ascii(ascii),
        .row(font_row),
        .bits(font_bits)
    );

    // 深色半透明效果无法直接混色，这里用纯色描边底板增强可读性。
    wire panel_on = in_area &&
        (local_x < (COLS * CELL_W)) &&
        (local_y < (((game_state == IDLE) ? IDLE_ROWS : PLAY_ROWS) * CELL_H));
    wire panel_edge = panel_on &&
        ((local_x < 10'd4) || (local_y < 10'd4) ||
         (local_y >= ((((game_state == IDLE) ? IDLE_ROWS : PLAY_ROWS) * CELL_H) - 10'd4)));

    assign text_on = panel_on;
    assign text_rgb = glyph_pixel ? 12'hFFF :
                      (panel_edge ? 12'h49D : 12'h112);
endmodule
