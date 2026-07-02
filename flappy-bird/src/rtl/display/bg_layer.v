`timescale 1ns / 1ps

// 背景显示层：按 background_id 程序化绘制 640x480 背景。
// ID 顺序：0 city, 1 lab, 2 space, 3 zjg, 4 night, 5 default。
module bg_layer(
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    input  wire [2:0] background_id,
    output reg  [11:0] bg_rgb
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

    wire cloud_on =
        ((sx >= 16'sd50)  && (sx < 16'sd155) && (sy >= 16'sd75)  && (sy < 16'sd112)) ||
        ((sx >= 16'sd420) && (sx < 16'sd565) && (sy >= 16'sd88)  && (sy < 16'sd128));

    wire default_mountain_on =
        (((sx >= 16'sd20)  && (sx < 16'sd140) && (sy >= 16'sd360 - (sx - 16'sd20))  && (sy < GROUND_Y)) ||
         ((sx >= 16'sd140) && (sx < 16'sd260) && (sy >= 16'sd240 + (sx - 16'sd140)) && (sy < GROUND_Y)) ||
         ((sx >= 16'sd290) && (sx < 16'sd410) && (sy >= 16'sd380 - (sx - 16'sd290)) && (sy < GROUND_Y)) ||
         ((sx >= 16'sd410) && (sx < 16'sd550) && (sy >= 16'sd260 + (sx - 16'sd410)) && (sy < GROUND_Y)));

    wire building_on =
        ((sx >= 16'sd40)  && (sx < 16'sd96)  && (sy >= 16'sd330) && (sy < GROUND_Y)) ||
        ((sx >= 16'sd112) && (sx < 16'sd172) && (sy >= 16'sd300) && (sy < GROUND_Y)) ||
        ((sx >= 16'sd300) && (sx < 16'sd372) && (sy >= 16'sd290) && (sy < GROUND_Y)) ||
        ((sx >= 16'sd420) && (sx < 16'sd504) && (sy >= 16'sd340) && (sy < GROUND_Y)) ||
        ((sx >= 16'sd532) && (sx < 16'sd604) && (sy >= 16'sd315) && (sy < GROUND_Y));

    wire window_on = building_on &&
        (pixel_x[4:0] >= 5'd7) && (pixel_x[4:0] <= 5'd13) &&
        (pixel_y[4:0] >= 5'd7) && (pixel_y[4:0] <= 5'd15);

    wire city_hill_on = (sy >= 16'sd300) && (sy < 16'sd350) &&
        (((sx >= 16'sd0) && (sx < 16'sd260)) || ((sx >= 16'sd330) && (sx < 16'sd640)));
    wire city_water_on = (sx < 16'sd230) && (sy >= 16'sd382) && (sy < GROUND_Y);
    wire city_tree_on =
        ((sx >= 16'sd0) && (sx < 16'sd170) && (sy >= 16'sd335) && (sy < GROUND_Y)) ||
        ((sx >= 16'sd302) && (sx < 16'sd430) && (sy >= 16'sd330) && (sy < GROUND_Y));
    wire city_tower_on = (sx >= 16'sd430) && (sx < 16'sd506) && (sy >= 16'sd145) && (sy < GROUND_Y);

    wire lab_wall_panel_on = (sy >= 16'sd110) && (sy < 16'sd250) &&
        ((pixel_x[7:0] < 8'd110) || (pixel_x[7:0] > 8'd145));
    wire lab_light_on =
        ((sx >= 16'sd80)  && (sx < 16'sd190) && (sy >= 16'sd36) && (sy < 16'sd48)) ||
        ((sx >= 16'sd250) && (sx < 16'sd390) && (sy >= 16'sd36) && (sy < 16'sd48)) ||
        ((sx >= 16'sd460) && (sx < 16'sd580) && (sy >= 16'sd36) && (sy < 16'sd48));
    wire lab_desk_on = (sy >= 16'sd330) && (sy < 16'sd382) &&
        (((sx >= 16'sd20) && (sx < 16'sd210)) ||
         ((sx >= 16'sd230) && (sx < 16'sd430)) ||
         ((sx >= 16'sd450) && (sx < 16'sd628)));
    wire lab_monitor_on = (sy >= 16'sd260) && (sy < 16'sd330) &&
        (((sx >= 16'sd60) && (sx < 16'sd132)) ||
         ((sx >= 16'sd278) && (sx < 16'sd350)) ||
         ((sx >= 16'sd492) && (sx < 16'sd564)));

    wire space_band_on =
        ((sx >= 16'sd120) && (sx < 16'sd540) && (sy >= 16'sd285) && (sy < 16'sd372)) ||
        ((sx >= 16'sd450) && (sx < 16'sd630) && (sy >= 16'sd205) && (sy < 16'sd300));
    wire space_star_on =
        ((pixel_x[5:0] == 6'd7)  && (pixel_y[6:0] == 7'd42)) ||
        ((pixel_x[5:0] == 6'd19) && (pixel_y[6:0] == 7'd88)) ||
        ((pixel_x[5:0] == 6'd51) && (pixel_y[6:0] == 7'd11)) ||
        ((pixel_x[5:0] == 6'd33) && (pixel_y[6:0] == 7'd65)) ||
        ((sx >= 16'sd570) && (sx < 16'sd577) && (sy >= 16'sd170) && (sy < 16'sd177));

    wire zjg_sun_on = (sx >= 16'sd470) && (sx < 16'sd530) && (sy >= 16'sd72) && (sy < 16'sd132);
    wire zjg_tower_on = (sx >= 16'sd286) && (sx < 16'sd354) && (sy >= 16'sd160) && (sy < GROUND_Y);
    wire zjg_skyline_on =
        ((sx >= 16'sd20) && (sx < 16'sd120) && (sy >= 16'sd300) && (sy < GROUND_Y)) ||
        ((sx >= 16'sd135) && (sx < 16'sd240) && (sy >= 16'sd275) && (sy < GROUND_Y)) ||
        ((sx >= 16'sd390) && (sx < 16'sd520) && (sy >= 16'sd292) && (sy < GROUND_Y)) ||
        ((sx >= 16'sd540) && (sx < 16'sd630) && (sy >= 16'sd318) && (sy < GROUND_Y));
    wire zjg_water_on = (sy >= 16'sd374) && (sy < GROUND_Y);

    always @(*) begin
        case (background_id)
            BG_CITY: begin
                bg_rgb = (sy < 16'sd95) ? 12'h28F : ((sy < 16'sd190) ? 12'h5CF : 12'h9EE);
                if (cloud_on) bg_rgb = 12'hFFD;
                if (city_hill_on) bg_rgb = 12'h7BD;
                if (building_on || city_tower_on) bg_rgb = city_tower_on ? 12'h68A : 12'hD97;
                if (window_on) bg_rgb = 12'hFE8;
                if (city_tree_on) bg_rgb = 12'h194;
                if (city_water_on) bg_rgb = 12'h08C;
                if (sy >= GROUND_Y) bg_rgb = 12'h678;
                if (sy >= GROUND_Y && sy < GROUND_Y + 16'sd8) bg_rgb = 12'hBCA;
            end
            BG_LAB: begin
                bg_rgb = (sy < 16'sd92) ? 12'hECD : 12'hDBB;
                if (lab_light_on) bg_rgb = 12'hFFD;
                if (lab_wall_panel_on) bg_rgb = 12'hCDA;
                if (lab_monitor_on) bg_rgb = 12'h123;
                if (lab_monitor_on && pixel_y[4]) bg_rgb = 12'h19C;
                if (lab_desk_on) bg_rgb = 12'h975;
                if (sy >= GROUND_Y) bg_rgb = 12'h986;
                if (sy >= GROUND_Y && sy < GROUND_Y + 16'sd8) bg_rgb = 12'hEDB;
            end
            BG_SPACE: begin
                bg_rgb = (sy < 16'sd250) ? 12'h113 : 12'h124;
                if (space_band_on) bg_rgb = 12'h286;
                if (space_star_on) bg_rgb = 12'hEFF;
                if (sy >= GROUND_Y) bg_rgb = 12'h134;
                if (sy >= GROUND_Y && sy < GROUND_Y + 16'sd6) bg_rgb = 12'h49A;
            end
            BG_ZJG: begin
                bg_rgb = (sy < 16'sd150) ? 12'hC68 : ((sy < 16'sd275) ? 12'h86A : 12'h535);
                if (zjg_sun_on) bg_rgb = 12'hFB6;
                if (zjg_skyline_on || zjg_tower_on) bg_rgb = zjg_tower_on ? 12'h646 : 12'h423;
                if ((zjg_tower_on || zjg_skyline_on) && window_on) bg_rgb = 12'hFDA;
                if (zjg_water_on) bg_rgb = 12'h468;
                if (sy >= GROUND_Y) bg_rgb = 12'h534;
                if (sy >= GROUND_Y && sy < GROUND_Y + 16'sd8) bg_rgb = 12'hA76;
            end
            BG_NIGHT: begin
                bg_rgb = 12'h136;
                if (cloud_on) bg_rgb = 12'h68A;
                if (space_star_on) bg_rgb = 12'hFFF;
                if (default_mountain_on) bg_rgb = 12'h348;
                if (building_on) bg_rgb = 12'h234;
                if (window_on) bg_rgb = 12'hFD4;
                if (sy >= GROUND_Y) bg_rgb = 12'h463;
                if (sy >= GROUND_Y && sy < GROUND_Y + 16'sd8) bg_rgb = 12'h173;
            end
            default: begin
                bg_rgb = 12'h6BF;
                if (cloud_on) bg_rgb = 12'hFFF;
                if (default_mountain_on) bg_rgb = 12'h8CD;
                if (building_on) bg_rgb = 12'h8DE;
                if (window_on) bg_rgb = 12'hFFA;
                if (sy >= GROUND_Y) bg_rgb = 12'hB72;
                if (sy >= GROUND_Y && sy < GROUND_Y + 16'sd8) bg_rgb = 12'h2C2;
            end
        endcase
    end
endmodule
