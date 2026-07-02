`timescale 1ns / 1ps

// UI 覆盖层：绘制开始、暂停、结束界面的几何面板和图标。
module ui_layer(
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    input  wire [1:0] game_state,
    input  wire [2:0] background_id,
    output wire       ui_on,
    output reg  [11:0] ui_rgb
);
    localparam [1:0] IDLE     = 2'b00;
    localparam [1:0] PLAY     = 2'b01;
    localparam [1:0] GAMEOVER = 2'b10;
    localparam [1:0] PAUSE    = 2'b11;

    localparam [2:0] BG_CITY    = 3'd0;
    localparam [2:0] BG_LAB     = 3'd1;
    localparam [2:0] BG_SPACE   = 3'd2;
    localparam [2:0] BG_ZJG     = 3'd3;
    localparam [2:0] BG_NIGHT   = 3'd4;
    localparam [2:0] BG_DEFAULT = 3'd5;

    wire signed [15:0] sx = {6'b0, pixel_x};
    wire signed [15:0] sy = {6'b0, pixel_y};

    wire dark_style = (background_id == BG_SPACE) ||
                      (background_id == BG_ZJG) ||
                      (background_id == BG_NIGHT);
    wire warm_style = (background_id == BG_LAB) || (background_id == BG_DEFAULT);
    wire unused_play = (game_state == PLAY);

    wire [11:0] c_panel      = dark_style ? 12'h124 : (warm_style ? 12'hEDC : 12'hDEF);
    wire [11:0] c_panel_deep = dark_style ? 12'h013 : (warm_style ? 12'hBA8 : 12'hBCD);
    wire [11:0] c_border     = dark_style ? 12'h5CF : 12'h047;
    wire [11:0] c_border_hi  = dark_style ? 12'h8FE : (warm_style ? 12'hFE8 : 12'hFE3);
    wire [11:0] c_button     = dark_style ? 12'h168 : (warm_style ? 12'hB75 : 12'h27D);
    wire [11:0] c_icon       = dark_style ? 12'hEFF : 12'hFFF;
    wire [11:0] c_shadow     = dark_style ? 12'h001 : 12'h79A;
    wire [11:0] c_danger     = dark_style ? 12'hE43 : 12'hC22;
    wire [11:0] c_danger_bg  = dark_style ? 12'h311 : 12'h611;

    wire panel_on =
        (sx >= 16'sd176) && (sx < 16'sd464) &&
        (sy >= 16'sd138) && (sy < 16'sd322);

    wire panel_border_on =
        panel_on &&
        ((sx < 16'sd182) || (sx >= 16'sd458) ||
         (sy < 16'sd144) || (sy >= 16'sd316));

    wire panel_inner_line_on =
        panel_on &&
        (((sx >= 16'sd194) && (sx < 16'sd446) && (sy >= 16'sd160) && (sy < 16'sd164)) ||
         ((sx >= 16'sd194) && (sx < 16'sd446) && (sy >= 16'sd294) && (sy < 16'sd298)));

    wire panel_corner_on =
        panel_on &&
        (((sx >= 16'sd188) && (sx < 16'sd214) && (sy >= 16'sd150) && (sy < 16'sd154)) ||
         ((sx >= 16'sd426) && (sx < 16'sd452) && (sy >= 16'sd150) && (sy < 16'sd154)) ||
         ((sx >= 16'sd188) && (sx < 16'sd214) && (sy >= 16'sd306) && (sy < 16'sd310)) ||
         ((sx >= 16'sd426) && (sx < 16'sd452) && (sy >= 16'sd306) && (sy < 16'sd310)));

    wire idle_button_shadow_on =
        (sx >= 16'sd252) && (sx < 16'sd396) &&
        (sy >= 16'sd232) && (sy < 16'sd282);

    wire idle_button_on =
        (sx >= 16'sd246) && (sx < 16'sd390) &&
        (sy >= 16'sd226) && (sy < 16'sd276);

    wire idle_button_border_on =
        idle_button_on &&
        ((sx < 16'sd252) || (sx >= 16'sd384) ||
         (sy < 16'sd232) || (sy >= 16'sd270));

    wire signed [15:0] idle_icon_dx = sx - 16'sd301;
    wire signed [15:0] idle_icon_dy = sy - 16'sd251;
    wire signed [15:0] idle_icon_abs_dy =
        (idle_icon_dy >= 16'sd0) ? idle_icon_dy : -idle_icon_dy;

    wire idle_play_icon_on =
        (sx >= 16'sd300) && (sx < 16'sd348) &&
        (sy >= 16'sd233) && (sy < 16'sd269) &&
        (idle_icon_dx > idle_icon_abs_dy);

    // 六个背景选择点，仅开始界面显示，当前背景高亮。
    wire selector0 = (sx >= 16'sd214) && (sx < 16'sd226) && (sy >= 16'sd286) && (sy < 16'sd298);
    wire selector1 = (sx >= 16'sd252) && (sx < 16'sd264) && (sy >= 16'sd286) && (sy < 16'sd298);
    wire selector2 = (sx >= 16'sd290) && (sx < 16'sd302) && (sy >= 16'sd286) && (sy < 16'sd298);
    wire selector3 = (sx >= 16'sd328) && (sx < 16'sd340) && (sy >= 16'sd286) && (sy < 16'sd298);
    wire selector4 = (sx >= 16'sd366) && (sx < 16'sd378) && (sy >= 16'sd286) && (sy < 16'sd298);
    wire selector5 = (sx >= 16'sd404) && (sx < 16'sd416) && (sy >= 16'sd286) && (sy < 16'sd298);
    wire idle_selector_on = selector0 || selector1 || selector2 || selector3 || selector4 || selector5;
    wire idle_selector_active_on =
        ((background_id == 3'd0) && selector0) ||
        ((background_id == 3'd1) && selector1) ||
        ((background_id == 3'd2) && selector2) ||
        ((background_id == 3'd3) && selector3) ||
        ((background_id == 3'd4) && selector4) ||
        ((background_id == 3'd5) && selector5);

    wire pause_icon_shadow_on =
        ((sx >= 16'sd292) && (sx < 16'sd319) && (sy >= 16'sd214) && (sy < 16'sd274)) ||
        ((sx >= 16'sd334) && (sx < 16'sd361) && (sy >= 16'sd214) && (sy < 16'sd274));

    wire pause_icon_on =
        ((sx >= 16'sd286) && (sx < 16'sd313) && (sy >= 16'sd208) && (sy < 16'sd268)) ||
        ((sx >= 16'sd328) && (sx < 16'sd355) && (sy >= 16'sd208) && (sy < 16'sd268));

    wire gameover_banner_on =
        (sx >= 16'sd216) && (sx < 16'sd424) &&
        (sy >= 16'sd164) && (sy < 16'sd214);

    wire signed [15:0] go_dx  = sx - 16'sd285;
    wire signed [15:0] go_dy  = sy - 16'sd224;
    wire signed [15:0] go_sum = go_dx + go_dy;
    wire gameover_x_box_on =
        (sx >= 16'sd285) && (sx < 16'sd355) &&
        (sy >= 16'sd224) && (sy < 16'sd294);
    wire gameover_x_on =
        gameover_x_box_on &&
        (((go_dx - go_dy >= -16'sd5) && (go_dx - go_dy <= 16'sd5)) ||
         ((go_sum >= 16'sd65) && (go_sum <= 16'sd75)));

    assign ui_on =
        ((game_state == IDLE) &&
            (panel_on || panel_border_on || panel_inner_line_on || panel_corner_on ||
             idle_button_shadow_on || idle_button_on || idle_button_border_on ||
             idle_play_icon_on || idle_selector_on || idle_selector_active_on)) ||
        ((game_state == PAUSE) &&
            (panel_on || panel_border_on || panel_inner_line_on || panel_corner_on ||
             pause_icon_shadow_on || pause_icon_on)) ||
        ((game_state == GAMEOVER) &&
            (panel_on || panel_border_on || panel_inner_line_on || panel_corner_on ||
             gameover_banner_on || gameover_x_on));

    always @(*) begin
        ui_rgb = 12'h000;

        if (game_state == IDLE) begin
            if (panel_on) ui_rgb = c_panel;
            if (panel_inner_line_on) ui_rgb = c_panel_deep;
            if (panel_border_on || panel_corner_on) ui_rgb = c_border;
            if (idle_button_shadow_on) ui_rgb = c_shadow;
            if (idle_button_on) ui_rgb = c_button;
            if (idle_button_border_on) ui_rgb = c_border_hi;
            if (idle_selector_on) ui_rgb = c_border;
            if (idle_selector_active_on) ui_rgb = c_border_hi;
            if (idle_play_icon_on) ui_rgb = c_icon;
        end

        if (game_state == PAUSE) begin
            if (panel_on) ui_rgb = c_panel;
            if (panel_inner_line_on) ui_rgb = c_panel_deep;
            if (panel_border_on || panel_corner_on) ui_rgb = c_border;
            if (pause_icon_shadow_on) ui_rgb = c_shadow;
            if (pause_icon_on) ui_rgb = c_border_hi;
        end

        if (game_state == GAMEOVER) begin
            if (panel_on) ui_rgb = c_danger_bg;
            if (panel_inner_line_on) ui_rgb = 12'h411;
            if (panel_border_on || panel_corner_on) ui_rgb = c_border;
            if (gameover_banner_on) ui_rgb = c_danger;
            if (gameover_x_on) ui_rgb = c_icon;
        end
    end
endmodule
