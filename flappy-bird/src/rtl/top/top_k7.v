`timescale 1ns / 1ps

// 四位七段管十六进制显示，用于上板调试当前分数。
module sevenseg_hex(
    input  wire       clk,
    input  wire       rst,
    input  wire [15:0] value,
    output reg  [7:0] segment,
    output reg  [3:0] an
);
    reg [15:0] scan_cnt;
    reg [3:0]  digit;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scan_cnt <= 16'd0;
        end else begin
            scan_cnt <= scan_cnt + 1'b1;
        end
    end

    always @(*) begin
        case (scan_cnt[15:14])
            2'b00: begin an = 4'b1110; digit = value[3:0]; end
            2'b01: begin an = 4'b1101; digit = value[7:4]; end
            2'b10: begin an = 4'b1011; digit = value[11:8]; end
            default: begin an = 4'b0111; digit = value[15:12]; end
        endcase

        case (digit)
            4'h0: segment = 8'b11000000;
            4'h1: segment = 8'b11111001;
            4'h2: segment = 8'b10100100;
            4'h3: segment = 8'b10110000;
            4'h4: segment = 8'b10011001;
            4'h5: segment = 8'b10010010;
            4'h6: segment = 8'b10000010;
            4'h7: segment = 8'b11111000;
            4'h8: segment = 8'b10000000;
            4'h9: segment = 8'b10010000;
            4'ha: segment = 8'b10001000;
            4'hb: segment = 8'b10000011;
            4'hc: segment = 8'b11000110;
            4'hd: segment = 8'b10100001;
            4'he: segment = 8'b10000110;
            default: segment = 8'b10001110;
        endcase
    end
endmodule

// K7 板级顶层：连接真实管脚、控制接口、游戏核心和分层 VGA 显示。
module top_k7(
    input  wire       clk,
    input  wire       rstn,
    input  wire [3:0] BTN,
    input  wire [15:0] SW,
    input  wire       ps2_clk,
    input  wire       ps2_data,
    output wire [7:0] LED,
    output wire [7:0] SEGMENT,
    output wire [3:0] AN,
    output wire [3:0] r,
    output wire [3:0] g,
    output wire [3:0] b,
    output wire       hs,
    output wire       vs,
    output wire       beep,
    output wire       BTNX4
);
    wire rst = ~rstn;
    wire jump_level;
    wire pause_level;
    wire restart_level;
    wire skin_next_level;
    wire background_next_level;
    wire immortal;
    wire [1:0] speed_sel;
    wire [1:0] gravity_sel;
    wire [1:0] jump_sel;
    wire [1:0] volume_sel;
    wire score_only_mode;
    wire [3:0] btn_clean;
    wire [15:0] sw_clean;
    wire ps2_space_down;
    wire ps2_enter_down;

    // K7 板上 BTNX4 是按钮使能脚，不是游戏按键输入；拉低后 BTN[3:0] 才能正常工作。
    assign BTNX4 = 1'b0;

    input_control u_control (
        .clk(clk),
        .rst(rst),
        .btn(BTN),
        .sw(SW),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .jump_level(jump_level),
        .pause_level(pause_level),
        .restart_level(restart_level),
        .skin_next_level(skin_next_level),
        .background_next_level(background_next_level),
        .immortal(immortal),
        .speed_sel(speed_sel),
        .gravity_sel(gravity_sel),
        .jump_sel(jump_sel),
        .volume_sel(volume_sel),
        .score_only_mode(score_only_mode),
        .btn_clean(btn_clean),
        .sw_clean(sw_clean),
        .ps2_space_down(ps2_space_down),
        .ps2_enter_down(ps2_enter_down)
    );

    wire signed [15:0] bird_x;
    wire signed [15:0] bird_y;
    wire [1:0] game_state;
    wire collision_hit;
    wire jump_event;
    wire score_event;
    wire [15:0] score;
    wire [2:0] skin_id;
    wire [2:0] bird_frame;
    wire [1:0] background_id;
    wire signed [15:0] gap_left0;
    wire signed [15:0] gap_right0;
    wire signed [15:0] gap_top0;
    wire signed [15:0] gap_bottom0;
    wire signed [15:0] gap_left1;
    wire signed [15:0] gap_right1;
    wire signed [15:0] gap_top1;
    wire signed [15:0] gap_bottom1;
    wire signed [15:0] gap_left2;
    wire signed [15:0] gap_right2;
    wire signed [15:0] gap_top2;
    wire signed [15:0] gap_bottom2;
    wire signed [15:0] gap_left3;
    wire signed [15:0] gap_right3;
    wire signed [15:0] gap_top3;
    wire signed [15:0] gap_bottom3;
    wire signed [15:0] gap_left4;
    wire signed [15:0] gap_right4;
    wire signed [15:0] gap_top4;
    wire signed [15:0] gap_bottom4;

    game_core u_game (
        .clk(clk),
        .rst(rst),
        .jump_level(jump_level),
        .pause_level(pause_level),
        .restart_level(restart_level),
        .immortal(immortal),
        .speed_sel(speed_sel),
        .gravity_sel(gravity_sel),
        .jump_sel(jump_sel),
        .bird_x(bird_x),
        .bird_y(bird_y),
        .game_state(game_state),
        .collision_hit(collision_hit),
        .jump_event(jump_event),
        .score_event(score_event),
        .score(score),
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
        .gap_bottom4(gap_bottom4)
    );

    skin_control u_skin_control (
        .clk(clk),
        .rst(rst),
        .game_state(game_state),
        .skin_next_level(skin_next_level),
        .skin_id(skin_id),
        .frame_index(bird_frame)
    );

    background_control #(
        .BACKGROUND_COUNT(1)
    ) u_background_control (
        .clk(clk),
        .rst(rst),
        .game_state(game_state),
        .background_next_level(background_next_level),
        .background_id(background_id)
    );

    display u_display (
        .clk(clk),
        .rst(rst),
        .bird_x(bird_x),
        .bird_y(bird_y),
        .game_state(game_state),
        .skin_id(skin_id),
        .bird_frame(bird_frame),
        .background_id(background_id),
        .score(score),
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
        .hsync(hs),
        .vsync(vs),
        .vga_r(r),
        .vga_g(g),
        .vga_b(b)
    );

    sevenseg_hex u_seg (
        .clk(clk),
        .rst(rst),
        .value(score),
        .segment(SEGMENT),
        .an(AN)
    );

    audio_effects u_audio (
        .clk(clk),
        .rst(rst),
        .jump_event(jump_event),
        .score_event(score_event),
        .volume_sel(volume_sel),
        .score_only_mode(score_only_mode),
        .beep(beep)
    );

    // LED 调试：皮肤编号、动画低位、跳跃、碰撞和当前游戏状态。
    assign LED = {skin_id, bird_frame[0], jump_level, collision_hit, game_state};
endmodule
