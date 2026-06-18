`timescale 1ns / 1ps

// ============================================================
// Module: vga_ctrl
// Function:
//   1. Generate VGA horizontal sync signal hsync
//   2. Generate VGA vertical sync signal vsync
//   3. Generate current pixel coordinate pixel_x / pixel_y
//   4. Generate video_on to indicate visible display area
//
// VGA Mode:
//   640 x 480 @ 60Hz
//   Pixel clock is about 25MHz.
//   Here we divide 100MHz system clock by 4 to get 25MHz.
// ============================================================

module vga_ctrl(
    input  wire clk,        // 系统时钟，开发板一般提供 100MHz 时钟
    input  wire rst,        // 复位信号，高电平有效

    output wire hsync,      // VGA 行同步信号，低电平有效
    output wire vsync,      // VGA 场同步/帧同步信号，低电平有效
    output wire video_on,   // 当前像素是否处于可见区域，1 表示可以显示颜色
    output wire [9:0] pixel_x, // 当前扫描像素的横坐标，范围 0~799
    output wire [9:0] pixel_y  // 当前扫描像素的纵坐标，范围 0~524
);

    // ========================================================
    // 640x480 @ 60Hz VGA timing parameters
    //
    // 一行总共有 800 个时钟：
    //   640 可见区域 + 16 前沿 + 96 同步脉冲 + 48 后沿
    //
    // 一帧总共有 525 行：
    //   480 可见区域 + 10 前沿 + 2 同步脉冲 + 33 后沿
    // ========================================================

    localparam H_VISIBLE = 10'd640; // 水平方向可见像素数
    localparam H_FRONT   = 10'd16;  // 水平前沿
    localparam H_SYNC    = 10'd96;  // 水平同步脉冲宽度
    localparam H_BACK    = 10'd48;  // 水平后沿
    localparam H_TOTAL   = 10'd800; // 一整行总像素周期

    localparam V_VISIBLE = 10'd480; // 垂直方向可见行数
    localparam V_FRONT   = 10'd10;  // 垂直前沿
    localparam V_SYNC    = 10'd2;   // 垂直同步脉冲宽度
    localparam V_BACK    = 10'd33;  // 垂直后沿
    localparam V_TOTAL   = 10'd525; // 一整帧总行数

    // ========================================================
    // Pixel clock generation
    //
    // 开发板时钟 clk = 100MHz
    // VGA 640x480@60Hz 需要约 25MHz 像素时钟
    // 所以这里用 2 位计数器进行 4 分频：
    //   100MHz / 4 = 25MHz
    //
    // pixel_tick 每 4 个 clk 周期产生一次高电平
    // 后面的 h_cnt / v_cnt 只在 pixel_tick 有效时变化
    // ========================================================

    reg [1:0] clk_div;      // 2 位分频计数器
    wire pixel_tick;        // 像素时钟使能信号，不是真正的新时钟

    always @(posedge clk or posedge rst) begin
        if (rst)
            clk_div <= 2'b00;
        else
            clk_div <= clk_div + 2'b01;
    end

    assign pixel_tick = (clk_div == 2'b00);

    // ========================================================
    // Horizontal and vertical counters
    //
    // h_cnt：当前正在扫描一行中的第几个像素
    // v_cnt：当前正在扫描一帧中的第几行
    //
    // h_cnt: 0 -> 799 -> 0
    // v_cnt: 0 -> 524 -> 0
    // ========================================================

    reg [9:0] h_cnt;        // 水平扫描计数器
    reg [9:0] v_cnt;        // 垂直扫描计数器

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            h_cnt <= 10'd0;
            v_cnt <= 10'd0;
        end
        else if (pixel_tick) begin
            if (h_cnt == H_TOTAL - 1) begin
                h_cnt <= 10'd0;

                if (v_cnt == V_TOTAL - 1)
                    v_cnt <= 10'd0;
                else
                    v_cnt <= v_cnt + 10'd1;
            end
            else begin
                h_cnt <= h_cnt + 10'd1;
            end
        end
    end

    // 当前像素坐标直接由扫描计数器给出
    assign pixel_x = h_cnt;
    assign pixel_y = v_cnt;

    // ========================================================
    // Visible area
    //
    // 只有 pixel_x < 640 且 pixel_y < 480 时，才是真正显示区域。
    // 其他区域是 VGA 的消隐区，不应该输出有效颜色。
    // ========================================================

    assign video_on = (h_cnt < H_VISIBLE) && (v_cnt < V_VISIBLE);

    // ========================================================
    // VGA sync signals
    //
    // VGA 的 hsync / vsync 一般是低电平有效。
    //
    // hsync 在水平同步区间拉低：
    //   x = 640 + 16  到  640 + 16 + 96
    //
    // vsync 在垂直同步区间拉低：
    //   y = 480 + 10  到  480 + 10 + 2
    // ========================================================

    assign hsync = ~((h_cnt >= H_VISIBLE + H_FRONT) &&
                     (h_cnt <  H_VISIBLE + H_FRONT + H_SYNC));

    assign vsync = ~((v_cnt >= V_VISIBLE + V_FRONT) &&
                     (v_cnt <  V_VISIBLE + V_FRONT + V_SYNC));

endmodule