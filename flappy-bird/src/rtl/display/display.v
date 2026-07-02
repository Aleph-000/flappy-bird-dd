`timescale 1ns / 1ps

// ============================================================
// Module: display
// Function:
//   Top display compositor for Flappy Bird project.
//
// This module does not draw objects directly.
// It combines several display layers:
//
//   1. vga_ctrl    : generate VGA timing and pixel coordinate
//   2. bg_layer    : background color
//   3. pipe_layer  : pipe overlay
//   4. bird_layer  : bird overlay
//   5. ui_layer    : UI overlay
//
// Layer priority:
//   UI > Bird > Pipe > Background
// ============================================================
module display(
    input  wire clk,    // 系统时钟，通常为开发板 100MHz 时钟
    input  wire rst,    // 复位信号，高电平有效

    // ========================================================
    // Signals from bird module
    // ========================================================
    input  wire signed [15:0] bird_x,     // 小鸟中心横坐标，后续用于绘制小鸟
    input  wire signed [15:0] bird_y,     // 小鸟中心纵坐标，后续用于绘制小鸟
    input  wire [1:0] game_state,         // 游戏状态：IDLE / PLAY / GAMEOVER / PAUSE
    input  wire [15:0] score,             // 当前分数，后续用于绘制分数

    // ========================================================
    // Signals from pipe module
    //
    // 注意：
    // gap_left / gap_right / gap_top / gap_bottom
    // 表示“管道中间可通过空隙”的边界，
    // 不是管道本体的边界。
    //
    // 对于某一根管道：
    //   x 在 gap_left ~ gap_right 之间
    //   y < gap_top       是上管道
    //   y >= gap_bottom   是下管道
    //   gap_top ~ gap_bottom 中间区域是空隙
    // ========================================================

    input  wire signed [15:0] gap_left0,    // 第0组管道空隙左边界
    input  wire signed [15:0] gap_right0,   // 第0组管道空隙右边界
    input  wire signed [15:0] gap_top0,     // 第0组管道空隙上边界
    input  wire signed [15:0] gap_bottom0,  // 第0组管道空隙下边界

    input  wire signed [15:0] gap_left1,    // 第1组管道空隙左边界
    input  wire signed [15:0] gap_right1,   // 第1组管道空隙右边界
    input  wire signed [15:0] gap_top1,     // 第1组管道空隙上边界
    input  wire signed [15:0] gap_bottom1,  // 第1组管道空隙下边界

    input  wire signed [15:0] gap_left2,    // 第2组管道空隙左边界
    input  wire signed [15:0] gap_right2,   // 第2组管道空隙右边界
    input  wire signed [15:0] gap_top2,     // 第2组管道空隙上边界
    input  wire signed [15:0] gap_bottom2,  // 第2组管道空隙下边界

    input  wire signed [15:0] gap_left3,    // 第3组管道空隙左边界
    input  wire signed [15:0] gap_right3,   // 第3组管道空隙右边界
    input  wire signed [15:0] gap_top3,     // 第3组管道空隙上边界
    input  wire signed [15:0] gap_bottom3,  // 第3组管道空隙下边界

    input  wire signed [15:0] gap_left4,    // 第4组管道空隙左边界
    input  wire signed [15:0] gap_right4,   // 第4组管道空隙右边界
    input  wire signed [15:0] gap_top4,     // 第4组管道空隙上边界
    input  wire signed [15:0] gap_bottom4,  // 第4组管道空隙下边界

    // ========================================================
    // VGA output signals
    // ========================================================
    output wire hsync,       // VGA 行同步信号，连接到 VGA_HS 引脚
    output wire vsync,       // VGA 场同步/帧同步信号，连接到 VGA_VS 引脚
    output wire [3:0] vga_r, // VGA 红色通道，4位颜色强度
    output wire [3:0] vga_g, // VGA 绿色通道，4位颜色强度
    output wire [3:0] vga_b  // VGA 蓝色通道，4位颜色强度
);

    
    localparam [11:0] C_BLACK    = 12'h000; // 黑色边框
    
    // ========================================================
    // Internal wires from vga_ctrl
    // ========================================================

    wire video_on;       // 当前像素是否位于可见区域
    wire [9:0] pixel_x;  // 当前像素横坐标
    wire [9:0] pixel_y;  // 当前像素纵坐标

    // ========================================================
    // Instantiate VGA controller
    //
    // vga_ctrl 负责产生：
    //   hsync / vsync
    //   pixel_x / pixel_y
    //   video_on
    // ========================================================

    vga_ctrl u_vga_ctrl(
        .clk(clk),
        .rst(rst),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );
    
    // ========================================================
    // Color generation logic
    // ========================================================

    wire [11:0] bg_rgb;
    
    bg_layer u_bg_layer(
    .pixel_x(pixel_x),
    .pixel_y(pixel_y),
    .bg_rgb(bg_rgb)
     );
     
     wire pipe_on;
     wire [11:0] pipe_rgb;
     
    // ========================================================
    // Pipe layer
    //
    // pipe_layer only judges whether the current pixel belongs
    // to any pipe and gives the pipe color.
    // ========================================================
    
    pipe_layer u_pipe_layer(
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
    
     // ========================================================
    // BIRD layer
    // ===============================================
    bird_layer u_bird_layer(
    .pixel_x(pixel_x),
    .pixel_y(pixel_y),
    .bird_x(bird_x),
    .bird_y(bird_y),
    .bird_on(bird_on),
    .bird_rgb(bird_rgb)
    );
    
    wire ui_on;
    wire [11:0] ui_rgb;
    
    // ========================================================
    // UI layer
    // ========================================================
    
    ui_layer u_ui_layer(
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .game_state(game_state),
    
        .ui_on(ui_on),
        .ui_rgb(ui_rgb)
    );
  
    // ========================================================
    // RGB registers
    //
    // 因为颜色是在 always @(*) 里面根据坐标判断的，
    // 所以这里先用 reg 保存颜色，
    // 最后再 assign 给 output wire。
    // ========================================================

    reg [3:0] r_reg;
    reg [3:0] g_reg;
    reg [3:0] b_reg;

    assign vga_r = r_reg;
    assign vga_g = g_reg;
    assign vga_b = b_reg;

always @(*) begin
    if (!video_on) begin
        // 消隐区：黑色
        {r_reg,g_reg,b_reg} = C_BLACK;
    end
    else begin
       {r_reg, g_reg, b_reg} = bg_rgb;

        // ====================================================
        // Pipe layer
        //
        // pipe_layer has already generated pipe_rgb.
        // If pipe_on = 1, pipe layer covers background.
        // ====================================================
        
        if (pipe_on) begin
            {r_reg, g_reg, b_reg} = pipe_rgb;
        end

        // ====================================================
        // Bird layer
        //
        // bird_layer has already generated bird_rgb.
        // If bird_on = 1, bird layer covers pipe/background.
        // ====================================================
        
        if (bird_on) begin
            {r_reg, g_reg, b_reg} = bird_rgb;
        end
        // ====================================================
        // UI layer
        //
        // UI has the highest priority.
        // ====================================================
        if (ui_on) begin
            {r_reg, g_reg, b_reg} = ui_rgb;
        end
    end
end
endmodule