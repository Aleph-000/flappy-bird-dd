`timescale 1ns / 1ps

// 临时 VGA 显示：在正式美术/VGA 模块合并前，用简单图形验证上板控制。
module debug_vga(
    input  wire clk,
    input  wire rst,
    input  wire signed [15:0] bird_x,
    input  wire signed [15:0] bird_y,
    input  wire [1:0] game_state,
    input  wire collision_hit,
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
    output reg  [3:0] r,
    output reg  [3:0] g,
    output reg  [3:0] b,
    output reg        hs,
    output reg        vs
);
    reg [1:0] pix_div;
    wire pix_tick = (pix_div == 2'd0);

    // 100MHz 四分频得到约 25MHz 像素节拍，适配 640x480@60Hz。
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pix_div <= 2'd0;
        end else begin
            pix_div <= pix_div + 1'b1;
        end
    end

    reg [9:0] h_cnt;
    reg [9:0] v_cnt;
    wire active = (h_cnt < 10'd640) && (v_cnt < 10'd480);
    wire signed [15:0] px = {6'd0, h_cnt};
    wire signed [15:0] py = {6'd0, v_cnt};

    wire bird_on = (px >= bird_x - 16'sd32) && (px <= bird_x + 16'sd32) &&
                   (py >= bird_y - 16'sd24) && (py <= bird_y + 16'sd24);
    wire pipe0_on = (px >= gap_left0) && (px <= gap_right0) &&
                    ((py <= gap_top0) || (py >= gap_bottom0));
    wire pipe1_on = (px >= gap_left1) && (px <= gap_right1) &&
                    ((py <= gap_top1) || (py >= gap_bottom1));
    wire pipe2_on = (px >= gap_left2) && (px <= gap_right2) &&
                    ((py <= gap_top2) || (py >= gap_bottom2));
    wire pipe3_on = (px >= gap_left3) && (px <= gap_right3) &&
                    ((py <= gap_top3) || (py >= gap_bottom3));
    wire pipe4_on = (px >= gap_left4) && (px <= gap_right4) &&
                    ((py <= gap_top4) || (py >= gap_bottom4));
    wire pipe_on = pipe0_on | pipe1_on | pipe2_on | pipe3_on | pipe4_on;
    wire ground_on = py >= 16'sd452;

    // VGA 时序计数，同时根据游戏对象位置输出基础颜色。
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            h_cnt <= 10'd0;
            v_cnt <= 10'd0;
            hs <= 1'b1;
            vs <= 1'b1;
            r <= 4'd0;
            g <= 4'd0;
            b <= 4'd0;
        end else if (pix_tick) begin
            if (h_cnt == 10'd799) begin
                h_cnt <= 10'd0;
                if (v_cnt == 10'd524) begin
                    v_cnt <= 10'd0;
                end else begin
                    v_cnt <= v_cnt + 1'b1;
                end
            end else begin
                h_cnt <= h_cnt + 1'b1;
            end

            hs <= ~((h_cnt >= 10'd656) && (h_cnt < 10'd752));
            vs <= ~((v_cnt >= 10'd490) && (v_cnt < 10'd492));

            if (!active) begin
                r <= 4'h0;
                g <= 4'h0;
                b <= 4'h0;
            end else if (collision_hit && game_state == 2'b10) begin
                r <= 4'hd;
                g <= bird_on ? 4'hd : 4'h2;
                b <= bird_on ? 4'h0 : 4'h2;
            end else if (bird_on) begin
                r <= 4'hf;
                g <= 4'hd;
                b <= 4'h0;
            end else if (pipe_on) begin
                r <= 4'h1;
                g <= 4'hb;
                b <= 4'h3;
            end else if (ground_on) begin
                r <= 4'h8;
                g <= 4'h6;
                b <= 4'h2;
            end else if (game_state == 2'b11) begin
                r <= 4'h4;
                g <= 4'h6;
                b <= 4'h8;
            end else if (game_state == 2'b00) begin
                r <= 4'h2;
                g <= 4'h8;
                b <= 4'hc;
            end else begin
                r <= 4'h7;
                g <= 4'hc;
                b <= 4'hf;
            end
        end
    end
endmodule
