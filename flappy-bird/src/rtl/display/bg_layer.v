`timescale 1ns / 1ps

// 背景显示层：根据 background_id 选择不同背景风格。
module bg_layer(
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    input  wire [1:0] background_id,
    output reg  [11:0] bg_rgb
);
    localparam signed [15:0] GROUND_Y = 16'sd420;

    wire signed [15:0] sx = {6'b0, pixel_x};
    wire signed [15:0] sy = {6'b0, pixel_y};

    wire night_bg = (background_id == 2'd1);

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

    always @(*) begin
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
endmodule
