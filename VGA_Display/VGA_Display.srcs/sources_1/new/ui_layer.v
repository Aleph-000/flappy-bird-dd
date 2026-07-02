`timescale 1ns / 1ps

// ============================================================
// Module: ui_layer
// Function:
//   Draw UI overlay layer according to game_state.
//
// Current UI:
//   IDLE:
//     - center panel
//     - blue start button
//     - yellow button border
//     - play icon sprite
//
//   PAUSE:
//     - center panel
//     - pause icon sprite
//
//   GAMEOVER:
//     - dark red panel
//     - red banner
//     - gameover X sprite
//
// Layer rule:
//   ui_on = 1 means current pixel belongs to UI layer.
//   display.v will use ui_rgb to cover background / pipe / bird.
// ============================================================

module ui_layer(
    input  wire [9:0] pixel_x,    // 当前像素横坐标
    input  wire [9:0] pixel_y,    // 当前像素纵坐标
    input  wire [1:0] game_state, // 游戏状态

    output wire        ui_on,     // 当前像素是否属于 UI 层
    output reg  [11:0] ui_rgb     // UI 层输出颜色，12-bit RGB
);

    // ========================================================
    // Game state parameters
    // ========================================================

    localparam [1:0] IDLE     = 2'b00;
    localparam [1:0] PLAY     = 2'b01;
    localparam [1:0] GAMEOVER = 2'b10;
    localparam [1:0] PAUSE    = 2'b11;

    // ========================================================
    // UI color palette
    // ========================================================

    localparam [11:0] C_UI_PANEL      = 12'hDFF; // UI浅蓝白面板
    localparam [11:0] C_UI_BORDER     = 12'h049; // UI深蓝边框
    localparam [11:0] C_UI_START_BTN  = 12'h37F; // Start蓝色按钮
    localparam [11:0] C_UI_HIGHLIGHT  = 12'hFE3; // 黄色强调色
    localparam [11:0] C_UI_DANGER     = 12'hC22; // GameOver红色标题条
    localparam [11:0] C_UI_DARK_RED   = 12'h611; // GameOver深红面板
    localparam [11:0] C_TRANSPARENT   = 12'hF0F; // sprite 透明色

    // ========================================================
    // Convert pixel coordinate to signed value
    // ========================================================

    wire signed [15:0] sx;
    wire signed [15:0] sy;

    assign sx = {6'b0, pixel_x};
    assign sy = {6'b0, pixel_y};

    // ========================================================
    // Common UI panel
    //
    // IDLE / PAUSE / GAMEOVER 共用中央面板区域。
    // ========================================================

    wire ui_panel_on;

    assign ui_panel_on =
        (sx >= 16'sd190) && (sx < 16'sd450) &&
        (sy >= 16'sd140) && (sy < 16'sd320);

    wire ui_panel_border_on;

    assign ui_panel_border_on =
        ui_panel_on &&
        (
            (sx < 16'sd195) ||
            (sx >= 16'sd445) ||
            (sy < 16'sd145) ||
            (sy >= 16'sd315)
        );

    // ========================================================
    // IDLE UI regions
    // ========================================================

    // ----------------------
    // Start button
    // ----------------------

    wire idle_button_on;

    assign idle_button_on =
        (sx >= 16'sd250) && (sx < 16'sd390) &&
        (sy >= 16'sd220) && (sy < 16'sd270);

    wire idle_button_border_on;

    assign idle_button_border_on =
        idle_button_on &&
        (
            (sx < 16'sd255) ||
            (sx >= 16'sd385) ||
            (sy < 16'sd225) ||
            (sy >= 16'sd265)
        );

    // ----------------------
    // Play icon sprite
    //
    // Sprite size: 32 x 32
    // Position: x = 304 ~ 335, y = 229 ~ 260
    // ----------------------

    wire play_icon_box_on;
    wire [4:0] play_icon_x;
    wire [4:0] play_icon_y;
    wire [9:0] play_icon_addr;
    wire [11:0] play_icon_color;
    wire play_icon_visible;

    assign play_icon_box_on =
        (sx >= 16'sd304) && (sx < 16'sd336) &&
        (sy >= 16'sd229) && (sy < 16'sd261);

    assign play_icon_x = sx - 16'sd304;
    assign play_icon_y = sy - 16'sd229;

    // addr = y * 32 + x
    assign play_icon_addr = {play_icon_y, 5'b0} + play_icon_x;

    ui_play_icon_rom u_ui_play_icon_rom(
        .addr(play_icon_addr),
        .color(play_icon_color)
    );

    assign play_icon_visible =
        play_icon_box_on &&
        (play_icon_color != C_TRANSPARENT);

    // ========================================================
    // PAUSE UI regions
    // ========================================================

    // ----------------------
    // Pause icon sprite
    //
    // Sprite size: 64 x 64
    // Position: x = 288 ~ 351, y = 208 ~ 271
    // ----------------------

    wire pause_icon_box_on;
    wire [5:0] pause_icon_x;
    wire [5:0] pause_icon_y;
    wire [11:0] pause_icon_addr;
    wire [11:0] pause_icon_color;
    wire pause_icon_visible;

    assign pause_icon_box_on =
        (sx >= 16'sd288) && (sx < 16'sd352) &&
        (sy >= 16'sd208) && (sy < 16'sd272);

    assign pause_icon_x = sx - 16'sd288;
    assign pause_icon_y = sy - 16'sd208;

    // addr = y * 64 + x
    assign pause_icon_addr = {pause_icon_y, 6'b0} + pause_icon_x;

    ui_pause_icon_rom u_ui_pause_icon_rom(
        .addr(pause_icon_addr),
        .color(pause_icon_color)
    );

    assign pause_icon_visible =
        pause_icon_box_on &&
        (pause_icon_color != C_TRANSPARENT);

    // ========================================================
    // GAMEOVER UI regions
    // ========================================================

    // ----------------------
    // Red banner
    // ----------------------

    wire gameover_banner_on;

    assign gameover_banner_on =
        (sx >= 16'sd220) && (sx < 16'sd420) &&
        (sy >= 16'sd165) && (sy < 16'sd215);

    // ----------------------
    // GameOver X sprite
    //
    // Sprite size: 64 x 64
    // Position: x = 288 ~ 351, y = 228 ~ 291
    // ----------------------

    wire gameover_x_box_on;
    wire [5:0] gameover_x_local_x;
    wire [5:0] gameover_x_local_y;
    wire [11:0] gameover_x_addr;
    wire [11:0] gameover_x_color;
    wire gameover_x_visible;

    assign gameover_x_box_on =
        (sx >= 16'sd288) && (sx < 16'sd352) &&
        (sy >= 16'sd228) && (sy < 16'sd292);

    assign gameover_x_local_x = sx - 16'sd288;
    assign gameover_x_local_y = sy - 16'sd228;

    // addr = y * 64 + x
    assign gameover_x_addr = {gameover_x_local_y, 6'b0} + gameover_x_local_x;

    ui_gameover_x_rom u_ui_gameover_x_rom(
        .addr(gameover_x_addr),
        .color(gameover_x_color)
    );

    assign gameover_x_visible =
        gameover_x_box_on &&
        (gameover_x_color != C_TRANSPARENT);

    // ========================================================
    // Total UI on signal
    //
    // PLAY 状态下 ui_on = 0，不覆盖游戏画面。
    // IDLE / PAUSE / GAMEOVER 状态下，在对应 UI 区域内 ui_on = 1。
    // ========================================================

    assign ui_on =
        (
            (game_state == IDLE) &&
            (
                ui_panel_on ||
                ui_panel_border_on ||
                idle_button_on ||
                idle_button_border_on ||
                play_icon_visible
            )
        )
        ||
        (
            (game_state == PAUSE) &&
            (
                ui_panel_on ||
                ui_panel_border_on ||
                pause_icon_visible
            )
        )
        ||
        (
            (game_state == GAMEOVER) &&
            (
                ui_panel_on ||
                ui_panel_border_on ||
                gameover_banner_on ||
                gameover_x_visible
            )
        );

    // ========================================================
    // UI color priority
    //
    // 后面的颜色覆盖前面的颜色。
    // ========================================================

    always @(*) begin
        ui_rgb = 12'h000;

        // ----------------------
        // IDLE screen
        // ----------------------
        if (game_state == IDLE) begin
            if (ui_panel_on)
                ui_rgb = C_UI_PANEL;

            if (ui_panel_border_on)
                ui_rgb = C_UI_BORDER;

            if (idle_button_on)
                ui_rgb = C_UI_START_BTN;

            if (idle_button_border_on)
                ui_rgb = C_UI_HIGHLIGHT;

            if (play_icon_visible)
                ui_rgb = play_icon_color;
        end

        // ----------------------
        // PAUSE screen
        // ----------------------
        if (game_state == PAUSE) begin
            if (ui_panel_on)
                ui_rgb = C_UI_PANEL;

            if (ui_panel_border_on)
                ui_rgb = C_UI_BORDER;

            if (pause_icon_visible)
                ui_rgb = pause_icon_color;
        end

        // ----------------------
        // GAMEOVER screen
        // ----------------------
        if (game_state == GAMEOVER) begin
            if (ui_panel_on)
                ui_rgb = C_UI_DARK_RED;

            if (ui_panel_border_on)
                ui_rgb = C_UI_BORDER;

            if (gameover_banner_on)
                ui_rgb = C_UI_DANGER;

            if (gameover_x_visible)
                ui_rgb = gameover_x_color;
        end
    end

endmodule