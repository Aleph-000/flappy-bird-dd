`timescale 1ns / 1ps

// 背景显示层：根据 background_id 绘制不同风格的 640x480 背景。
// 说明：素材 PNG 只作为美术参考，FPGA 上实际使用逻辑图形生成，避免占用过大的 ROM。
module bg_layer(
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    input  wire [1:0] background_id,
    output reg  [11:0] bg_rgb
);
    localparam signed [15:0] GROUND_Y = 16'sd420;

    localparam [1:0] BG_DEFAULT = 2'd0;
    localparam [1:0] BG_NIGHT   = 2'd1;
    localparam [1:0] BG_SPACE   = 2'd2;
    localparam [1:0] BG_CITY    = 2'd3;

    wire signed [15:0] sx = {6'b0, pixel_x};
    wire signed [15:0] sy = {6'b0, pixel_y};

    wire night_bg = (background_id == BG_NIGHT);
    wire space_bg = (background_id == BG_SPACE);
    wire city_bg  = (background_id == BG_CITY);

    // 默认/夜景背景配色
    localparam [11:0] C_SKY        = 12'h6BF;
    localparam [11:0] C_CLOUD      = 12'hFFF;
    localparam [11:0] C_MOUNTAIN   = 12'h8CD;
    localparam [11:0] C_BUILDING   = 12'h8DE;
    localparam [11:0] C_WINDOW     = 12'hFFA;
    localparam [11:0] C_GRASS      = 12'h2C2;
    localparam [11:0] C_GROUND     = 12'hB72;
    localparam [11:0] C_FLOWER     = 12'hF8D;
    localparam [11:0] C_FLOWER_MID = 12'hFE0;
    localparam [11:0] C_STEM       = 12'h191;

    localparam [11:0] C_NIGHT_SKY      = 12'h136;
    localparam [11:0] C_NIGHT_CLOUD    = 12'h68A;
    localparam [11:0] C_NIGHT_MOUNTAIN = 12'h348;
    localparam [11:0] C_NIGHT_BUILDING = 12'h234;
    localparam [11:0] C_NIGHT_WINDOW   = 12'hFD4;
    localparam [11:0] C_NIGHT_GROUND   = 12'h463;
    localparam [11:0] C_NIGHT_GRASS    = 12'h173;

    // 星空背景配色：贴近素材里的深蓝紫天空、青绿色星云和冷色岩层。
    localparam [11:0] C_SPACE_SKY      = 12'h113;
    localparam [11:0] C_SPACE_SKY_BAND = 12'h124;
    localparam [11:0] C_SPACE_NEBULA_0 = 12'h164;
    localparam [11:0] C_SPACE_NEBULA_1 = 12'h286;
    localparam [11:0] C_SPACE_NEBULA_2 = 12'h4A8;
    localparam [11:0] C_SPACE_STAR     = 12'hEFF;
    localparam [11:0] C_SPACE_STAR_DIM = 12'h6BA;
    localparam [11:0] C_SPACE_GROUND   = 12'h134;
    localparam [11:0] C_SPACE_EDGE     = 12'h49A;
    localparam [11:0] C_SPACE_ROCK     = 12'h256;

    // 城市/校园背景配色：参考新增 PNG 的蓝天、远山、城区和前景屋顶。
    localparam [11:0] C_CITY_SKY_0     = 12'h28F;
    localparam [11:0] C_CITY_SKY_1     = 12'h5CF;
    localparam [11:0] C_CITY_SKY_2     = 12'h9EE;
    localparam [11:0] C_CITY_CLOUD     = 12'hFFD;
    localparam [11:0] C_CITY_CLOUD_SHA = 12'hEDB;
    localparam [11:0] C_CITY_MOUNTAIN  = 12'h49C;
    localparam [11:0] C_CITY_HILL      = 12'h7BD;
    localparam [11:0] C_CITY_BUILDING  = 12'h68A;
    localparam [11:0] C_CITY_BUILDING2 = 12'hD97;
    localparam [11:0] C_CITY_WINDOW    = 12'hFE8;
    localparam [11:0] C_CITY_TREE      = 12'h194;
    localparam [11:0] C_CITY_TREE_LIT  = 12'h3B5;
    localparam [11:0] C_CITY_WATER     = 12'h08C;
    localparam [11:0] C_CITY_GROUND    = 12'h678;
    localparam [11:0] C_CITY_EDGE      = 12'hBCA;

    // ---------------- 默认/夜景元素 ----------------
    wire cloud_on =
        ((sx >= 16'sd50)  && (sx < 16'sd130) && (sy >= 16'sd80)  && (sy < 16'sd100)) ||
        ((sx >= 16'sd75)  && (sx < 16'sd110) && (sy >= 16'sd65)  && (sy < 16'sd115)) ||
        ((sx >= 16'sd105) && (sx < 16'sd160) && (sy >= 16'sd90)  && (sy < 16'sd110)) ||
        ((sx >= 16'sd430) && (sx < 16'sd520) && (sy >= 16'sd95)  && (sy < 16'sd115)) ||
        ((sx >= 16'sd455) && (sx < 16'sd500) && (sy >= 16'sd80)  && (sy < 16'sd130)) ||
        ((sx >= 16'sd500) && (sx < 16'sd570) && (sy >= 16'sd105) && (sy < 16'sd125));

    wire star_on =
        night_bg &&
        (
            ((sx >= 16'sd80)  && (sx < 16'sd84)  && (sy >= 16'sd42)  && (sy < 16'sd46)) ||
            ((sx >= 16'sd210) && (sx < 16'sd214) && (sy >= 16'sd95)  && (sy < 16'sd99)) ||
            ((sx >= 16'sd360) && (sx < 16'sd364) && (sy >= 16'sd58)  && (sy < 16'sd62)) ||
            ((sx >= 16'sd520) && (sx < 16'sd524) && (sy >= 16'sd72)  && (sy < 16'sd76))
        );

    wire mountain1_on =
        (((sx >= 16'sd20)  && (sx < 16'sd120) && (sy >= 16'sd360 - (sx - 16'sd20))  && (sy < GROUND_Y)) ||
         ((sx >= 16'sd120) && (sx < 16'sd220) && (sy >= 16'sd260 + (sx - 16'sd120)) && (sy < GROUND_Y)));

    wire mountain2_on =
        (((sx >= 16'sd240) && (sx < 16'sd360) && (sy >= 16'sd390 - (sx - 16'sd240)) && (sy < GROUND_Y)) ||
         ((sx >= 16'sd360) && (sx < 16'sd500) && (sy >= 16'sd270 + (sx - 16'sd360)) && (sy < GROUND_Y)));

    wire mountain_on = mountain1_on || mountain2_on;

    wire building1_on = (sx >= 16'sd40)  && (sx < 16'sd95)  && (sy >= 16'sd330) && (sy < GROUND_Y);
    wire building2_on = (sx >= 16'sd110) && (sx < 16'sd170) && (sy >= 16'sd300) && (sy < GROUND_Y);
    wire building3_on = (sx >= 16'sd190) && (sx < 16'sd250) && (sy >= 16'sd350) && (sy < GROUND_Y);
    wire building4_on = (sx >= 16'sd300) && (sx < 16'sd370) && (sy >= 16'sd290) && (sy < GROUND_Y);
    wire building5_on = (sx >= 16'sd410) && (sx < 16'sd500) && (sy >= 16'sd340) && (sy < GROUND_Y);
    wire building6_on = (sx >= 16'sd530) && (sx < 16'sd600) && (sy >= 16'sd315) && (sy < GROUND_Y);
    wire building_on = building1_on || building2_on || building3_on || building4_on || building5_on || building6_on;

    wire window_on =
        ((((sx >= 16'sd50) && (sx < 16'sd62)) || ((sx >= 16'sd72) && (sx < 16'sd84))) &&
         (((sy >= 16'sd345) && (sy < 16'sd355)) || ((sy >= 16'sd370) && (sy < 16'sd380)) || ((sy >= 16'sd395) && (sy < 16'sd405)))) ||
        ((((sx >= 16'sd122) && (sx < 16'sd135)) || ((sx >= 16'sd145) && (sx < 16'sd158))) &&
         (((sy >= 16'sd318) && (sy < 16'sd330)) || ((sy >= 16'sd348) && (sy < 16'sd360)) || ((sy >= 16'sd378) && (sy < 16'sd390)))) ||
        ((((sx >= 16'sd315) && (sx < 16'sd328)) || ((sx >= 16'sd342) && (sx < 16'sd355))) &&
         (((sy >= 16'sd310) && (sy < 16'sd322)) || ((sy >= 16'sd340) && (sy < 16'sd352)) ||
          ((sy >= 16'sd370) && (sy < 16'sd382)) || ((sy >= 16'sd400) && (sy < 16'sd412)))) ||
        (((sx >= 16'sd425) && (sx < 16'sd485)) &&
         (((sy >= 16'sd355) && (sy < 16'sd362)) || ((sy >= 16'sd380) && (sy < 16'sd387)) || ((sy >= 16'sd405) && (sy < 16'sd412)))) ||
        ((((sx >= 16'sd545) && (sx < 16'sd558)) || ((sx >= 16'sd570) && (sx < 16'sd583))) &&
         (((sy >= 16'sd335) && (sy < 16'sd347)) || ((sy >= 16'sd365) && (sy < 16'sd377)) || ((sy >= 16'sd395) && (sy < 16'sd407))));

    wire flower_stem_on =
        ((sx >= 16'sd80)  && (sx < 16'sd83)  && (sy >= 16'sd402) && (sy < GROUND_Y)) ||
        ((sx >= 16'sd255) && (sx < 16'sd258) && (sy >= 16'sd400) && (sy < GROUND_Y)) ||
        ((sx >= 16'sd560) && (sx < 16'sd563) && (sy >= 16'sd405) && (sy < GROUND_Y));

    wire flower_petal_on =
        ((sx >= 16'sd76)  && (sx < 16'sd87)  && (sy >= 16'sd394) && (sy < 16'sd405)) ||
        ((sx >= 16'sd251) && (sx < 16'sd262) && (sy >= 16'sd392) && (sy < 16'sd403)) ||
        ((sx >= 16'sd556) && (sx < 16'sd567) && (sy >= 16'sd397) && (sy < 16'sd408));

    wire flower_center_on =
        ((sx >= 16'sd80)  && (sx < 16'sd83)  && (sy >= 16'sd398) && (sy < 16'sd401)) ||
        ((sx >= 16'sd255) && (sx < 16'sd258) && (sy >= 16'sd396) && (sy < 16'sd399)) ||
        ((sx >= 16'sd560) && (sx < 16'sd563) && (sy >= 16'sd401) && (sy < 16'sd404));

    // ---------------- 星空元素 ----------------
    wire space_sky_band_on =
        (sy >= 16'sd250) &&
        (
            ((sx >= 16'sd120) && (sx < 16'sd520) && (sy < 16'sd320)) ||
            ((sx >= 16'sd180) && (sx < 16'sd610) && (sy >= 16'sd300) && (sy < 16'sd385))
        );

    wire space_nebula_0_on =
        ((sx >= 16'sd120) && (sx < 16'sd430) && (sy >= 16'sd330) && (sy < 16'sd395)) ||
        ((sx >= 16'sd240) && (sx < 16'sd560) && (sy >= 16'sd285) && (sy < 16'sd350)) ||
        ((sx >= 16'sd475) && (sx < 16'sd630) && (sy >= 16'sd210) && (sy < 16'sd305));

    wire space_nebula_1_on =
        ((sx >= 16'sd155) && (sx < 16'sd330) && (sy >= 16'sd360) && (sy < 16'sd405)) ||
        ((sx >= 16'sd300) && (sx < 16'sd500) && (sy >= 16'sd315) && (sy < 16'sd365)) ||
        ((sx >= 16'sd520) && (sx < 16'sd610) && (sy >= 16'sd185) && (sy < 16'sd250));

    wire space_nebula_2_on =
        ((sx >= 16'sd170) && (sx < 16'sd280) && (sy >= 16'sd388) && (sy < 16'sd414)) ||
        ((sx >= 16'sd300) && (sx < 16'sd430) && (sy >= 16'sd340) && (sy < 16'sd372)) ||
        ((sx >= 16'sd500) && (sx < 16'sd565) && (sy >= 16'sd225) && (sy < 16'sd255));

    wire space_star_on =
        ((sx >= 16'sd95)  && (sx < 16'sd99)  && (sy >= 16'sd250) && (sy < 16'sd254)) ||
        ((sx >= 16'sd130) && (sx < 16'sd135) && (sy >= 16'sd302) && (sy < 16'sd307)) ||
        ((sx >= 16'sd205) && (sx < 16'sd211) && (sy >= 16'sd230) && (sy < 16'sd236)) ||
        ((sx >= 16'sd404) && (sx < 16'sd411) && (sy >= 16'sd305) && (sy < 16'sd312)) ||
        ((sx >= 16'sd570) && (sx < 16'sd577) && (sy >= 16'sd330) && (sy < 16'sd337)) ||
        ((sx >= 16'sd590) && (sx < 16'sd598) && (sy >= 16'sd170) && (sy < 16'sd178));

    wire space_star_dim_on =
        ((pixel_x[5:0] == 6'd7)  && (pixel_y[6:0] == 7'd42)) ||
        ((pixel_x[5:0] == 6'd19) && (pixel_y[6:0] == 7'd88)) ||
        ((pixel_x[5:0] == 6'd51) && (pixel_y[6:0] == 7'd11)) ||
        ((pixel_x[5:0] == 6'd33) && (pixel_y[6:0] == 7'd65));

    wire space_ground_top_on = (sy >= GROUND_Y) && (sy < GROUND_Y + 16'sd6);
    wire space_rock_on =
        (sy >= GROUND_Y + 16'sd6) &&
        (
            ((pixel_x[5:3] == 3'b010) && (pixel_y[4:2] == 3'b101)) ||
            ((pixel_x[6:4] == 3'b101) && (pixel_y[5:3] == 3'b011))
        );

    // ---------------- 城市/校园元素 ----------------
    wire city_cloud_on =
        ((sx >= 16'sd0)   && (sx < 16'sd105) && (sy >= 16'sd35)  && (sy < 16'sd70))  ||
        ((sx >= 16'sd55)  && (sx < 16'sd240) && (sy >= 16'sd82)  && (sy < 16'sd105)) ||
        ((sx >= 16'sd160) && (sx < 16'sd300) && (sy >= 16'sd123) && (sy < 16'sd142)) ||
        ((sx >= 16'sd290) && (sx < 16'sd435) && (sy >= 16'sd110) && (sy < 16'sd138)) ||
        ((sx >= 16'sd445) && (sx < 16'sd555) && (sy >= 16'sd82)  && (sy < 16'sd105)) ||
        ((sx >= 16'sd545) && (sx < 16'sd640) && (sy >= 16'sd118) && (sy < 16'sd150));

    wire city_cloud_shadow_on =
        city_cloud_on && (pixel_y[3:1] == 3'b101);

    wire city_mountain_on =
        (((sx >= 16'sd0)   && (sx < 16'sd90)  && (sy >= 16'sd230 - (sx >>> 2))               && (sy < 16'sd285)) ||
         ((sx >= 16'sd90)  && (sx < 16'sd190) && (sy >= 16'sd208 + ((sx - 16'sd90) >>> 2))   && (sy < 16'sd285)) ||
         ((sx >= 16'sd210) && (sx < 16'sd350) && (sy >= 16'sd270 - ((sx - 16'sd210) >>> 2))  && (sy < 16'sd300)) ||
         ((sx >= 16'sd350) && (sx < 16'sd520) && (sy >= 16'sd235 + ((sx - 16'sd350) >>> 2))  && (sy < 16'sd300)));

    wire city_hill_on =
        (sy >= 16'sd300) && (sy < 16'sd350) &&
        (((sx >= 16'sd0) && (sx < 16'sd260)) || ((sx >= 16'sd330) && (sx < 16'sd640)));

    wire city_building_on =
        ((sx >= 16'sd15)  && (sx < 16'sd65)  && (sy >= 16'sd285) && (sy < GROUND_Y)) ||
        ((sx >= 16'sd80)  && (sx < 16'sd145) && (sy >= 16'sd270) && (sy < GROUND_Y)) ||
        ((sx >= 16'sd165) && (sx < 16'sd220) && (sy >= 16'sd250) && (sy < GROUND_Y)) ||
        ((sx >= 16'sd245) && (sx < 16'sd300) && (sy >= 16'sd275) && (sy < GROUND_Y)) ||
        ((sx >= 16'sd430) && (sx < 16'sd505) && (sy >= 16'sd145) && (sy < GROUND_Y)) ||
        ((sx >= 16'sd525) && (sx < 16'sd585) && (sy >= 16'sd270) && (sy < GROUND_Y)) ||
        ((sx >= 16'sd590) && (sx < 16'sd640) && (sy >= 16'sd245) && (sy < GROUND_Y));

    wire city_tall_building_on =
        (sx >= 16'sd430) && (sx < 16'sd505) && (sy >= 16'sd145) && (sy < GROUND_Y);

    wire city_window_on =
        city_building_on &&
        (pixel_x[4:0] >= 5'd7) && (pixel_x[4:0] <= 5'd12) &&
        (pixel_y[4:0] >= 5'd7) && (pixel_y[4:0] <= 5'd15);

    wire city_tree_on =
        ((sx >= 16'sd0)   && (sx < 16'sd165) && (sy >= 16'sd335) && (sy < GROUND_Y)) ||
        ((sx >= 16'sd300) && (sx < 16'sd430) && (sy >= 16'sd330) && (sy < GROUND_Y));

    wire city_tree_lit_on =
        city_tree_on && ((pixel_x[4:2] == 3'b011) || (pixel_y[4:2] == 3'b100));

    wire city_water_on =
        (sx >= 16'sd0) && (sx < 16'sd220) && (sy >= 16'sd382) && (sy < GROUND_Y);

    wire city_ground_top_on = (sy >= GROUND_Y) && (sy < GROUND_Y + 16'sd8);
    wire city_roof_line_on =
        (sy >= GROUND_Y + 16'sd18) &&
        ((pixel_x[5:0] == 6'd8) || (pixel_x[5:0] == 6'd42));

    always @(*) begin
        if (city_bg) begin
            if (sy < 16'sd90)
                bg_rgb = C_CITY_SKY_0;
            else if (sy < 16'sd190)
                bg_rgb = C_CITY_SKY_1;
            else
                bg_rgb = C_CITY_SKY_2;

            if (city_cloud_on)
                bg_rgb = city_cloud_shadow_on ? C_CITY_CLOUD_SHA : C_CITY_CLOUD;
            if (city_mountain_on)
                bg_rgb = C_CITY_MOUNTAIN;
            if (city_hill_on)
                bg_rgb = C_CITY_HILL;
            if (city_building_on)
                bg_rgb = city_tall_building_on ? C_CITY_BUILDING : C_CITY_BUILDING2;
            if (city_window_on)
                bg_rgb = C_CITY_WINDOW;
            if (city_tree_on)
                bg_rgb = city_tree_lit_on ? C_CITY_TREE_LIT : C_CITY_TREE;
            if (city_water_on)
                bg_rgb = C_CITY_WATER;
            if (sy >= GROUND_Y)
                bg_rgb = C_CITY_GROUND;
            if (city_ground_top_on)
                bg_rgb = C_CITY_EDGE;
            if (city_roof_line_on)
                bg_rgb = 12'h456;
        end else if (space_bg) begin
            bg_rgb = C_SPACE_SKY;

            if (space_sky_band_on)
                bg_rgb = C_SPACE_SKY_BAND;
            if (space_nebula_0_on)
                bg_rgb = C_SPACE_NEBULA_0;
            if (space_nebula_1_on)
                bg_rgb = C_SPACE_NEBULA_1;
            if (space_nebula_2_on)
                bg_rgb = C_SPACE_NEBULA_2;
            if (space_star_dim_on)
                bg_rgb = C_SPACE_STAR_DIM;
            if (space_star_on)
                bg_rgb = C_SPACE_STAR;
            if (sy >= GROUND_Y)
                bg_rgb = C_SPACE_GROUND;
            if (space_ground_top_on)
                bg_rgb = C_SPACE_EDGE;
            if (space_rock_on)
                bg_rgb = C_SPACE_ROCK;
        end else begin
            bg_rgb = night_bg ? C_NIGHT_SKY : C_SKY;

            if (cloud_on)
                bg_rgb = night_bg ? C_NIGHT_CLOUD : C_CLOUD;
            if (star_on)
                bg_rgb = 12'hFFF;
            if (mountain_on)
                bg_rgb = night_bg ? C_NIGHT_MOUNTAIN : C_MOUNTAIN;
            if (building_on)
                bg_rgb = night_bg ? C_NIGHT_BUILDING : C_BUILDING;
            if (window_on)
                bg_rgb = night_bg ? C_NIGHT_WINDOW : C_WINDOW;
            if (sy >= GROUND_Y)
                bg_rgb = night_bg ? C_NIGHT_GROUND : C_GROUND;
            if ((sy >= GROUND_Y) && (sy < GROUND_Y + 16'sd8))
                bg_rgb = night_bg ? C_NIGHT_GRASS : C_GRASS;
            if (flower_stem_on)
                bg_rgb = C_STEM;
            if (flower_petal_on)
                bg_rgb = C_FLOWER;
            if (flower_center_on)
                bg_rgb = C_FLOWER_MID;
        end
    end
endmodule
