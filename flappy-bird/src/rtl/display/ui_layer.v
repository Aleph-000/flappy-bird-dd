`timescale 1ns / 1ps

// ============================================================
// Module: ui_layer
// Function:
//   Draw UI overlay layer according to game_state.
//
// Current version:
//   IDLE screen:
//     - center panel
//     - blue start button
//     - yellow button border
//     - white play icon
//
// Later extension:
//   PAUSE screen
//   GAMEOVER screen
//
// Output:
//   ui_on:
//      1 means current pixel belongs to UI overlay
//
//   ui_rgb:
//      UI color in 12-bit RGB format
// ============================================================

module ui_layer(
    input  wire [9:0] pixel_x,    // 当前像素横坐标
    input  wire [9:0] pixel_y,    // 当前像素纵坐标
    input  wire [1:0] game_state, // 游戏状态

    output wire        ui_on,     // 当前像素是否属于 UI 层
    output reg  [11:0] ui_rgb     // UI 层输出颜色
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
    localparam [11:0] C_WHITE         = 12'hFFF; // 白色
    localparam [11:0] C_UI_DANGER   = 12'hC22; // GameOver 红色标题条
    localparam [11:0] C_UI_DARK_RED = 12'h611; // GameOver 深红面板

    // ========================================================
    // Convert pixel coordinate to signed value
    // ========================================================

    wire signed [15:0] sx;
    wire signed [15:0] sy;

    assign sx = {6'b0, pixel_x};
    assign sy = {6'b0, pixel_y};

    // ----------------------
    // UI center panel
    // ----------------------
    wire ui_panel_on;

    assign ui_panel_on =
        (sx >= 16'sd190) && (sx < 16'sd450) &&
        (sy >= 16'sd140) && (sy < 16'sd320);

    // ----------------------
    // UI panel border
    // ----------------------
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
    // IDLE start button
    // ----------------------
    wire idle_button_on;

    assign idle_button_on =
        (sx >= 16'sd250) && (sx < 16'sd390) &&
        (sy >= 16'sd220) && (sy < 16'sd270);

    // ----------------------
    // IDLE start button border
    // ----------------------
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
    // IDLE play icon
    // ----------------------
    // 白色播放三角形。
    // 注意：这里只是工程版图标，后面可以换成 sprite。
    wire signed [15:0] idle_icon_dx;
    wire signed [15:0] idle_icon_dy;
    wire signed [15:0] idle_icon_abs_dy;

    assign idle_icon_dx = sx - 16'sd300;
    assign idle_icon_dy = sy - 16'sd245;

    assign idle_icon_abs_dy =
        (idle_icon_dy >= 16'sd0) ? idle_icon_dy : -idle_icon_dy;

    wire idle_play_icon_on;

    assign idle_play_icon_on =
        (sx >= 16'sd300) && (sx < 16'sd345) &&
        (sy >= 16'sd230) && (sy < 16'sd260) &&
        (idle_icon_dx > idle_icon_abs_dy);

    // ========================================================
    // PAUSE UI regions
    // ========================================================
    
    // 暂停图标：两个黄色竖条
    wire pause_icon_on;
    
    assign pause_icon_on =
        (
            (sx >= 16'sd285) && (sx < 16'sd310) &&
            (sy >= 16'sd210) && (sy < 16'sd270)
        )
        ||
        (
            (sx >= 16'sd330) && (sx < 16'sd355) &&
            (sy >= 16'sd210) && (sy < 16'sd270)
        );

    // ========================================================
    // GAMEOVER UI regions
    // ========================================================
    
    // 红色标题条
    wire gameover_banner_on;
    
    assign gameover_banner_on =
        (sx >= 16'sd220) && (sx < 16'sd420) &&
        (sy >= 16'sd165) && (sy < 16'sd215);
    
    
    // GAMEOVER 的 X 图标
    // 用两条对角线画一个白色 X
    wire signed [15:0] go_dx;
    wire signed [15:0] go_dy;
    wire signed [15:0] go_sum;
    
    assign go_dx  = sx - 16'sd285;
    assign go_dy  = sy - 16'sd225;
    assign go_sum = go_dx + go_dy;
    
    wire gameover_x_box_on;
    
    assign gameover_x_box_on =
        (sx >= 16'sd285) && (sx < 16'sd355) &&
        (sy >= 16'sd225) && (sy < 16'sd295);
    
    wire gameover_x_on;
    
    assign gameover_x_on =
        gameover_x_box_on &&
        (
            // 主对角线：dx ≈ dy
            ((go_dx - go_dy >= -16'sd4) && (go_dx - go_dy <= 16'sd4))
            ||
            // 副对角线：dx + dy ≈ 70
            ((go_sum >= 16'sd66) && (go_sum <= 16'sd74))
        );
    
    // ========================================================
    // Total UI on signal
    //
    // 目前只有 IDLE UI。
    // PLAY 状态下 ui_on = 0，不覆盖游戏画面。
    // ========================================================

 assign ui_on =
    (
        (game_state == IDLE) &&
        (
            ui_panel_on ||
            ui_panel_border_on ||
            idle_button_on ||
            idle_button_border_on ||
            idle_play_icon_on
        )
    )
    ||
    (
        (game_state == PAUSE) &&
        (
            ui_panel_on ||
            ui_panel_border_on ||
            pause_icon_on
        )
    )
    ||
    (
        (game_state == GAMEOVER) &&
        (
            ui_panel_on ||
            ui_panel_border_on ||
            gameover_banner_on ||
            gameover_x_on
        )
    );

    // ========================================================
    // UI color priority
    //
    // 后面的颜色覆盖前面的颜色：
    // panel < panel border < button < button border < play icon
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

            if (idle_play_icon_on)
                ui_rgb = C_WHITE;
        end
        
        // ----------------------
        // PAUSE screen
        // ----------------------
        if (game_state == PAUSE) begin
            if (ui_panel_on)
                ui_rgb = C_UI_PANEL;
    
            if (ui_panel_border_on)
                ui_rgb = C_UI_BORDER;
    
            if (pause_icon_on)
                ui_rgb = C_UI_HIGHLIGHT;
        end
        // ----------------------
        // GAMEOVER screen
        // ----------------------
        if (game_state == GAMEOVER) begin
            // 深红色中央面板
            if (ui_panel_on)
                ui_rgb = C_UI_DARK_RED;
        
            // 深蓝色面板边框
            if (ui_panel_border_on)
                ui_rgb = C_UI_BORDER;
        
            // 红色标题条
            if (gameover_banner_on)
                ui_rgb = C_UI_DANGER;
        
            // 白色 X 图标
            if (gameover_x_on)
                ui_rgb = C_WHITE;
        end
    end

endmodule
