`timescale 1ns / 1ps

// ============================================================
// Module: bg_layer
// Function:
//   Generate static background color according to pixel position.
//
// This layer includes:
//   1. sky
//   2. clouds
//   3. mountains
//   4. buildings
//   5. windows
//   6. ground
//   7. flowers
//
// Note:
//   bg_layer always outputs a valid background color.
//   It does not need an "on" signal.
// ============================================================

module bg_layer(
    input  wire [9:0] pixel_x, // 当前像素横坐标
    input  wire [9:0] pixel_y, // 当前像素纵坐标

    output reg  [11:0] bg_rgb  // 背景层输出颜色，格式为 12-bit RGB
);

    // ========================================================
    // Basic parameters
    // ========================================================

    localparam signed [15:0] GROUND_Y = 16'sd420; // 地面开始位置

    // ========================================================
    // Color palette
    // ========================================================

    localparam [11:0] C_SKY        = 12'h6BF; // 浅蓝天空
    localparam [11:0] C_CLOUD      = 12'hFFF; // 白云
    localparam [11:0] C_MOUNTAIN   = 12'h8CD; // 淡蓝灰山
    localparam [11:0] C_BUILDING   = 12'h8DE; // 浅青色建筑
    localparam [11:0] C_WINDOW     = 12'hFFA; // 淡黄色窗户
    localparam [11:0] C_GRASS      = 12'h2C2; // 草地边缘
    localparam [11:0] C_GROUND     = 12'hB72; // 土地
    localparam [11:0] C_FLOWER     = 12'hF8D; // 粉色花瓣
    localparam [11:0] C_FLOWER_MID = 12'hFE0; // 黄色花心
    localparam [11:0] C_STEM       = 12'h191; // 花茎绿色

    // ========================================================
    // Convert pixel coordinate to signed value
    // ========================================================

    wire signed [15:0] sx;
    wire signed [15:0] sy;

    assign sx = {6'b0, pixel_x};
    assign sy = {6'b0, pixel_y};

    // ========================================================
    // Clouds
    // ========================================================

    wire cloud_on;

    assign cloud_on =
        // 左上方云朵
        ((sx >= 16'sd50)  && (sx < 16'sd130) && (sy >= 16'sd80)  && (sy < 16'sd100)) ||
        ((sx >= 16'sd75)  && (sx < 16'sd110) && (sy >= 16'sd65)  && (sy < 16'sd115)) ||
        ((sx >= 16'sd105) && (sx < 16'sd160) && (sy >= 16'sd90)  && (sy < 16'sd110)) ||

        // 右上方云朵
        ((sx >= 16'sd430) && (sx < 16'sd520) && (sy >= 16'sd95)  && (sy < 16'sd115)) ||
        ((sx >= 16'sd455) && (sx < 16'sd500) && (sy >= 16'sd80)  && (sy < 16'sd130)) ||
        ((sx >= 16'sd500) && (sx < 16'sd570) && (sy >= 16'sd105) && (sy < 16'sd125));

    // ========================================================
    // Mountains
    // ========================================================

    wire mountain1_on;
    wire mountain2_on;
    wire mountain_on;

    assign mountain1_on =
        (
            ((sx >= 16'sd20)  && (sx < 16'sd120) &&
             (sy >= 16'sd360 - (sx - 16'sd20)) &&
             (sy <  GROUND_Y))
            ||
            ((sx >= 16'sd120) && (sx < 16'sd220) &&
             (sy >= 16'sd260 + (sx - 16'sd120)) &&
             (sy <  GROUND_Y))
        );

    assign mountain2_on =
        (
            ((sx >= 16'sd240) && (sx < 16'sd360) &&
             (sy >= 16'sd390 - (sx - 16'sd240)) &&
             (sy <  GROUND_Y))
            ||
            ((sx >= 16'sd360) && (sx < 16'sd500) &&
             (sy >= 16'sd270 + (sx - 16'sd360)) &&
             (sy <  GROUND_Y))
        );

    assign mountain_on = mountain1_on || mountain2_on;

    // ========================================================
    // Buildings
    // ========================================================

    wire building1_on;
    wire building2_on;
    wire building3_on;
    wire building4_on;
    wire building5_on;
    wire building6_on;
    wire building_on;

    assign building1_on =
        (sx >= 16'sd40)  && (sx < 16'sd95)  &&
        (sy >= 16'sd330) && (sy < GROUND_Y);

    assign building2_on =
        (sx >= 16'sd110) && (sx < 16'sd170) &&
        (sy >= 16'sd300) && (sy < GROUND_Y);

    assign building3_on =
        (sx >= 16'sd190) && (sx < 16'sd250) &&
        (sy >= 16'sd350) && (sy < GROUND_Y);

    assign building4_on =
        (sx >= 16'sd300) && (sx < 16'sd370) &&
        (sy >= 16'sd290) && (sy < GROUND_Y);

    assign building5_on =
        (sx >= 16'sd410) && (sx < 16'sd500) &&
        (sy >= 16'sd340) && (sy < GROUND_Y);

    assign building6_on =
        (sx >= 16'sd530) && (sx < 16'sd600) &&
        (sy >= 16'sd315) && (sy < GROUND_Y);

    assign building_on =
        building1_on ||
        building2_on ||
        building3_on ||
        building4_on ||
        building5_on ||
        building6_on;

    // ========================================================
    // Windows
    // ========================================================

    wire window_on;

    assign window_on =
        // building1 windows
        (
            ((sx >= 16'sd50) && (sx < 16'sd62)) ||
            ((sx >= 16'sd72) && (sx < 16'sd84))
        ) &&
        (
            ((sy >= 16'sd345) && (sy < 16'sd355)) ||
            ((sy >= 16'sd370) && (sy < 16'sd380)) ||
            ((sy >= 16'sd395) && (sy < 16'sd405))
        )
        ||
        // building2 windows
        (
            ((sx >= 16'sd122) && (sx < 16'sd135)) ||
            ((sx >= 16'sd145) && (sx < 16'sd158))
        ) &&
        (
            ((sy >= 16'sd318) && (sy < 16'sd330)) ||
            ((sy >= 16'sd348) && (sy < 16'sd360)) ||
            ((sy >= 16'sd378) && (sy < 16'sd390))
        )
        ||
        // building4 windows
        (
            ((sx >= 16'sd315) && (sx < 16'sd328)) ||
            ((sx >= 16'sd342) && (sx < 16'sd355))
        ) &&
        (
            ((sy >= 16'sd310) && (sy < 16'sd322)) ||
            ((sy >= 16'sd340) && (sy < 16'sd352)) ||
            ((sy >= 16'sd370) && (sy < 16'sd382)) ||
            ((sy >= 16'sd400) && (sy < 16'sd412))
        )
        ||
        // building5 long windows
        (
            (sx >= 16'sd425) && (sx < 16'sd485)
        ) &&
        (
            ((sy >= 16'sd355) && (sy < 16'sd362)) ||
            ((sy >= 16'sd380) && (sy < 16'sd387)) ||
            ((sy >= 16'sd405) && (sy < 16'sd412))
        )
        ||
        // building6 windows
        (
            ((sx >= 16'sd545) && (sx < 16'sd558)) ||
            ((sx >= 16'sd570) && (sx < 16'sd583))
        ) &&
        (
            ((sy >= 16'sd335) && (sy < 16'sd347)) ||
            ((sy >= 16'sd365) && (sy < 16'sd377)) ||
            ((sy >= 16'sd395) && (sy < 16'sd407))
        );

    // ========================================================
    // Flowers
    // ========================================================

    wire flower_stem_on;
    wire flower_petal_on;
    wire flower_center_on;

    assign flower_stem_on =
        ((sx >= 16'sd80)  && (sx < 16'sd83)  && (sy >= 16'sd402) && (sy < GROUND_Y)) ||
        ((sx >= 16'sd255) && (sx < 16'sd258) && (sy >= 16'sd400) && (sy < GROUND_Y)) ||
        ((sx >= 16'sd560) && (sx < 16'sd563) && (sy >= 16'sd405) && (sy < GROUND_Y));

    assign flower_petal_on =
        ((sx >= 16'sd76)  && (sx < 16'sd87)  && (sy >= 16'sd394) && (sy < 16'sd405)) ||
        ((sx >= 16'sd251) && (sx < 16'sd262) && (sy >= 16'sd392) && (sy < 16'sd403)) ||
        ((sx >= 16'sd556) && (sx < 16'sd567) && (sy >= 16'sd397) && (sy < 16'sd408));

    assign flower_center_on =
        ((sx >= 16'sd80)  && (sx < 16'sd83)  && (sy >= 16'sd398) && (sy < 16'sd401)) ||
        ((sx >= 16'sd255) && (sx < 16'sd258) && (sy >= 16'sd396) && (sy < 16'sd399)) ||
        ((sx >= 16'sd560) && (sx < 16'sd563) && (sy >= 16'sd401) && (sy < 16'sd404));

    // ========================================================
    // Background color priority
    //
    // 后面的颜色覆盖前面的颜色：
    // sky < cloud < mountain < building < window < ground < grass < flower
    // ========================================================

    always @(*) begin
        bg_rgb = C_SKY;

        if (cloud_on)
            bg_rgb = C_CLOUD;

        if (mountain_on)
            bg_rgb = C_MOUNTAIN;

        if (building_on)
            bg_rgb = C_BUILDING;

        if (window_on)
            bg_rgb = C_WINDOW;

        if (sy >= GROUND_Y)
            bg_rgb = C_GROUND;

        if ((sy >= GROUND_Y) && (sy < GROUND_Y + 16'sd8))
            bg_rgb = C_GRASS;

        if (flower_stem_on)
            bg_rgb = C_STEM;

        if (flower_petal_on)
            bg_rgb = C_FLOWER;

        if (flower_center_on)
            bg_rgb = C_FLOWER_MID;
    end

endmodule