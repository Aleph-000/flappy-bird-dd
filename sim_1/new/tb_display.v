`timescale 1ns / 1ps

module tb_display;

    // ========================================================
    // Clock and reset
    // ========================================================

    reg clk;
    reg rst;

    // ========================================================
    // Inputs to display
    // ========================================================

    reg signed [15:0] bird_x;
    reg signed [15:0] bird_y;
    reg [1:0] game_state;
    reg [15:0] score;

    reg signed [15:0] gap_left0;
    reg signed [15:0] gap_right0;
    reg signed [15:0] gap_top0;
    reg signed [15:0] gap_bottom0;

    reg signed [15:0] gap_left1;
    reg signed [15:0] gap_right1;
    reg signed [15:0] gap_top1;
    reg signed [15:0] gap_bottom1;

    reg signed [15:0] gap_left2;
    reg signed [15:0] gap_right2;
    reg signed [15:0] gap_top2;
    reg signed [15:0] gap_bottom2;

    reg signed [15:0] gap_left3;
    reg signed [15:0] gap_right3;
    reg signed [15:0] gap_top3;
    reg signed [15:0] gap_bottom3;

    reg signed [15:0] gap_left4;
    reg signed [15:0] gap_right4;
    reg signed [15:0] gap_top4;
    reg signed [15:0] gap_bottom4;

    // ========================================================
    // VGA outputs
    // ========================================================

    wire hsync;
    wire vsync;
    wire [3:0] vga_r;
    wire [3:0] vga_g;
    wire [3:0] vga_b;

    // ========================================================
    // Instantiate display
    // ========================================================

    display uut(
        .clk(clk),
        .rst(rst),

        .bird_x(bird_x),
        .bird_y(bird_y),
        .game_state(game_state),
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

        .hsync(hsync),
        .vsync(vsync),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b)
    );

    // ========================================================
    // 100MHz clock
    // ========================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ========================================================
    // Check RGB at a given VGA coordinate
    //
    // 注意：
    //   uut.pixel_x / uut.pixel_y 是 display 内部信号。
    //   仿真中可以用层次引用访问。
    // ========================================================

    task check_rgb;
        input [9:0] x;
        input [9:0] y;
        input [11:0] expected_rgb;
        input [1023:0] message;

        integer count;

        begin
            count = 0;

            // 等待 VGA 扫描到目标像素
            while (!((uut.pixel_x == x) && (uut.pixel_y == y)) &&
                   (count < 3000000)) begin
                @(posedge clk);
                count = count + 1;
            end

            #1;

            if (count >= 3000000) begin
                $display("[FAIL] %s", message);
                $display("       Timeout waiting for x=%d, y=%d", x, y);
            end
            else if ({vga_r, vga_g, vga_b} == expected_rgb) begin
                $display("[PASS] %s", message);
            end
            else begin
                $display("[FAIL] %s", message);
                $display("       At x=%d, y=%d", x, y);
                $display("       Expected RGB = %h", expected_rgb);
                $display("       Got      RGB = %h", {vga_r, vga_g, vga_b});
            end
        end
    endtask

    // ========================================================
    // Main test process
    // ========================================================

    initial begin
        // ----------------------------------------------------
        // Initial values
        // ----------------------------------------------------
        rst = 1'b1;

        // PLAY 状态，先测试普通游戏画面
        game_state = 2'b01;
        score = 16'd0;

        // 小鸟中心坐标
        bird_x = 16'sd160;
        bird_y = 16'sd200;

        // Pipe0:
        // x = 300 ~ 359
        // gap y = 150 ~ 299
        gap_left0   = 16'sd300;
        gap_right0  = 16'sd360;
        gap_top0    = 16'sd150;
        gap_bottom0 = 16'sd300;

        // Pipe1:
        // x = 420 ~ 479
        // gap y = 180 ~ 319
        gap_left1   = 16'sd420;
        gap_right1  = 16'sd480;
        gap_top1    = 16'sd180;
        gap_bottom1 = 16'sd320;

        // 其他 pipe 暂时关闭
        gap_left2   = 16'sd0;
        gap_right2  = 16'sd0;
        gap_top2    = 16'sd0;
        gap_bottom2 = 16'sd0;

        gap_left3   = 16'sd0;
        gap_right3  = 16'sd0;
        gap_top3    = 16'sd0;
        gap_bottom3 = 16'sd0;

        gap_left4   = 16'sd0;
        gap_right4  = 16'sd0;
        gap_top4    = 16'sd0;
        gap_bottom4 = 16'sd0;

        // 释放复位
        #100;
        rst = 1'b0;

        // ----------------------------------------------------
        // PLAY state tests
        // ----------------------------------------------------

        // 1. 背景层：天空
        check_rgb(10'd250, 10'd50, 12'h6BF,
                  "display should show background sky in PLAY");

        // 2. 管道覆盖背景
        check_rgb(10'd320, 10'd100, 12'h0C2,
                  "pipe should cover background");

        // 3. 小鸟覆盖背景
        check_rgb(10'd150, 10'd200, 12'hFD0,
                  "bird should cover background");

        // 4. 管道 gap 区域不画管道，应该露出背景
        check_rgb(10'd320, 10'd200, 12'h6BF,
                  "pipe gap should show background");

        // ----------------------------------------------------
        // Bird over pipe priority test
        // ----------------------------------------------------
        // 把小鸟中心放到 pipe0 上管道区域。
        // 如果图层优先级正确，应该显示小鸟黄色，而不是管道绿色。
        bird_x = 16'sd320;
        bird_y = 16'sd100;
        game_state = 2'b01;

        check_rgb(10'd320, 10'd100, 12'hFD0,
                  "bird should cover pipe");

        // ----------------------------------------------------
        // UI priority test
        // ----------------------------------------------------
        // 把小鸟放在 UI 按钮位置，同时切到 IDLE。
        // 如果 UI 优先级正确，应该显示 UI 蓝色按钮，而不是小鸟黄色。
        bird_x = 16'sd270;
        bird_y = 16'sd240;
        game_state = 2'b00;

        check_rgb(10'd270, 10'd240, 12'h37F,
                  "IDLE UI should cover bird and background");
        
        
        // ----------------------------------------------------
        // PAUSE UI priority test
        // ----------------------------------------------------
        // 切到 PAUSE，在暂停图标位置应该显示 UI 黄色，
        // 说明 UI 可以覆盖背景/管道/小鸟。
        game_state = 2'b11; // PAUSE
        
        check_rgb(10'd290, 10'd230, 12'hFE3,
                  "PAUSE UI should cover game screen");
        
        
        // ----------------------------------------------------
        // GAMEOVER UI priority test
        // ----------------------------------------------------
        // 切到 GAMEOVER，在 X 图标位置应该显示白色，
        // 说明 GAMEOVER UI 可以覆盖游戏画面。
        game_state = 2'b10; // GAMEOVER
        
        check_rgb(10'd320, 10'd260, 12'hFFF,
                  "GAMEOVER UI should cover game screen");

        // ----------------------------------------------------
        // Blanking area test
        // ----------------------------------------------------
        // 如果你的 vga_ctrl 在消隐区仍然输出 h_count/v_count，
        // 这个测试应该通过。
        check_rgb(10'd700, 10'd10, 12'h000,
                  "blanking area should be black");

        $display("display layered simulation finished.");
        $finish;
    end

endmodule