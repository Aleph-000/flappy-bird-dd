`timescale 1ns / 1ps

// VGA 显示总成：组合背景、管子、小鸟 sprite 和 UI 图层。
module display(
    input  wire clk,
    input  wire rst,
    input  wire signed [15:0] bird_x,
    input  wire signed [15:0] bird_y,
    input  wire [1:0] game_state,
    input  wire [2:0] skin_id,
    input  wire [2:0] bird_frame,
    input  wire [1:0] background_id,
    input  wire [15:0] score,

    input  wire signed [15:0] gap_left0,
    input  wire signed [15:0] gap_right0,
    input  wire signed [15:0] gap_top0,
    input  wire signed [15:0] gap_bottom0,
    input  wire signed [15:0] gap_left1,
    input  wire signed [15:0] gap_right1,
    input  wire signed [15:0] gap_top1,
    input  wire signed [15:0] gap_bottom1,
    input  wire signed [15:0] gap_left2,
    input  wire signed [15:0] gap_right2,
    input  wire signed [15:0] gap_top2,
    input  wire signed [15:0] gap_bottom2,
    input  wire signed [15:0] gap_left3,
    input  wire signed [15:0] gap_right3,
    input  wire signed [15:0] gap_top3,
    input  wire signed [15:0] gap_bottom3,
    input  wire signed [15:0] gap_left4,
    input  wire signed [15:0] gap_right4,
    input  wire signed [15:0] gap_top4,
    input  wire signed [15:0] gap_bottom4,

    output wire hsync,
    output wire vsync,
    output wire [3:0] vga_r,
    output wire [3:0] vga_g,
    output wire [3:0] vga_b
);
    localparam [1:0] IDLE = 2'b00;
    localparam [11:0] C_BLACK = 12'h000;

    wire video_on;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;

    // score 目前由七段管显示，VGA 层暂不绘制；保留端口便于后续扩展。
    wire [15:0] unused_score = score;

    vga_ctrl u_vga_ctrl (
        .clk(clk),
        .rst(rst),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );

    wire [11:0] bg_rgb;
    bg_layer u_bg_layer (
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .background_id(background_id),
        .bg_rgb(bg_rgb)
    );

    wire pipe_on;
    wire [11:0] pipe_rgb;
    pipe_layer u_pipe_layer (
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .gap_left0(gap_left0),
        .gap_right0(gap_right0),
        .gap_top0(gap_top0),
        .gap_bottom0(gap_bottom0),
        .gap_left1(gap_left1),
        .gap_right1(gap_right1),
        .gap_top1(gap_top1),
        .gap_bottom1(gap_bottom1),
        .gap_left2(gap_left2),
        .gap_right2(gap_right2),
        .gap_top2(gap_top2),
        .gap_bottom2(gap_bottom2),
        .gap_left3(gap_left3),
        .gap_right3(gap_right3),
        .gap_top3(gap_top3),
        .gap_bottom3(gap_bottom3),
        .gap_left4(gap_left4),
        .gap_right4(gap_right4),
        .gap_top4(gap_top4),
        .gap_bottom4(gap_bottom4),
        .pipe_on(pipe_on),
        .pipe_rgb(pipe_rgb)
    );

    wire bird_on;
    wire [11:0] bird_rgb;
    bird_layer u_bird_layer (
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .bird_x(bird_x),
        .bird_y(bird_y),
        .game_state(game_state),
        .skin_id(skin_id),
        .frame_index(bird_frame),
        .bird_on(bird_on),
        .bird_rgb(bird_rgb)
    );

    wire ui_on;
    wire [11:0] ui_rgb;
    ui_layer u_ui_layer (
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .game_state(game_state),
        .ui_on(ui_on),
        .ui_rgb(ui_rgb)
    );

    reg [11:0] rgb_reg;
    assign vga_r = rgb_reg[11:8];
    assign vga_g = rgb_reg[7:4];
    assign vga_b = rgb_reg[3:0];

    always @(*) begin
        if (!video_on) begin
            rgb_reg = C_BLACK;
        end else begin
            rgb_reg = bg_rgb;
            if (pipe_on)
                rgb_reg = pipe_rgb;
            if (bird_on)
                rgb_reg = bird_rgb;
            if (ui_on)
                rgb_reg = ui_rgb;

            // 开始界面中，小鸟 sprite 作为皮肤预览显示在 UI 面板上方。
            if ((game_state == IDLE) && bird_on)
                rgb_reg = bird_rgb;
        end
    end
endmodule
