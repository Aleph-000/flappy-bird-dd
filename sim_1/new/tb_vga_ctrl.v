`timescale 1ns / 1ps

// ============================================================
// Testbench: tb_vga_ctrl
// Function:
//   Verify VGA timing logic.
//
// What we check:
//   1. pixel_x / pixel_y scan correctly
//   2. video_on is high in visible area
//   3. hsync becomes low in horizontal sync area
//   4. vsync becomes low in vertical sync area
// ============================================================

module tb_vga_ctrl;

    reg clk;        // 仿真用系统时钟，模拟开发板 100MHz
    reg rst;        // 仿真用复位信号，高电平有效

    wire hsync;     // VGA 行同步信号
    wire vsync;     // VGA 场同步/帧同步信号
    wire video_on;  // 可见区域标志
    wire [9:0] pixel_x; // 当前像素横坐标
    wire [9:0] pixel_y; // 当前像素纵坐标

    // 实例化待测试模块
    vga_ctrl uut(
        .clk(clk),
        .rst(rst),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );

    // ========================================================
    // Generate 100MHz clock
    //
    // 100MHz 时钟周期 = 10ns
    // 所以每 5ns 翻转一次
    // ========================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ========================================================
    // Simple check task
    // ========================================================

    task check;
        input condition;
        input [1023:0] message;
        begin
            if (condition)
                $display("[PASS] %s", message);
            else
                $display("[FAIL] %s", message);
        end
    endtask

    // ========================================================
    // Main simulation process
    // ========================================================

    initial begin
        // 初始复位
        rst = 1'b1;
        #100;
        rst = 1'b0;

        // 稍微等一下，让计数器开始工作
        #100;

        // ----------------------------------------------------
        // 1. Check visible area
        // x=10, y=0 属于可见区域
        // video_on 应该为 1
        // hsync / vsync 此时一般都为 1
        // ----------------------------------------------------
        wait(pixel_x == 10'd10 && pixel_y == 10'd0);
        #1;
        check(video_on == 1'b1, "video_on should be 1 in visible area");
        check(hsync == 1'b1, "hsync should be 1 before horizontal sync area");
        check(vsync == 1'b1, "vsync should be 1 before vertical sync area");

        // ----------------------------------------------------
        // 2. Check hsync low area
        //
        // hsync 低电平区间：
        // x = 640 + 16 = 656
        // 到
        // x = 640 + 16 + 96 - 1 = 751
        //
        // 所以 x=656 时，hsync 应该为 0
        // ----------------------------------------------------
        wait(pixel_x == 10'd656 && pixel_y == 10'd0);
        #1;
        check(hsync == 1'b0, "hsync should be 0 in horizontal sync area");

        // ----------------------------------------------------
        // 3. Check hsync returns high
        //
        // x=752 时已经离开 hsync 低电平区间
        // hsync 应该恢复为 1
        // ----------------------------------------------------
        wait(pixel_x == 10'd752 && pixel_y == 10'd0);
        #1;
        check(hsync == 1'b1, "hsync should return to 1 after horizontal sync area");

        // ----------------------------------------------------
        // 4. Check line change
        //
        // 一行最后一个点是 x=799
        // 下一步应该回到 x=0, y 加 1
        // ----------------------------------------------------
        wait(pixel_x == 10'd799 && pixel_y == 10'd0);
        #1;
        check(pixel_x == 10'd799 && pixel_y == 10'd0, "last pixel of first line");

        wait(pixel_x == 10'd0 && pixel_y == 10'd1);
        #1;
        check(pixel_x == 10'd0 && pixel_y == 10'd1, "pixel_y should increase after one line");

        // ----------------------------------------------------
        // 5. Check vsync low area
        //
        // vsync 低电平区间：
        // y = 480 + 10 = 490
        // 到
        // y = 480 + 10 + 2 - 1 = 491
        //
        // 所以 y=490 时，vsync 应该为 0
        // ----------------------------------------------------
        wait(pixel_x == 10'd0 && pixel_y == 10'd490);
        #1;
        check(vsync == 1'b0, "vsync should be 0 in vertical sync area");

        // ----------------------------------------------------
        // 6. Check vsync returns high
        //
        // y=492 时已经离开 vsync 低电平区间
        // vsync 应该恢复为 1
        // ----------------------------------------------------
        wait(pixel_x == 10'd0 && pixel_y == 10'd492);
        #1;
        check(vsync == 1'b1, "vsync should return to 1 after vertical sync area");

        $display("vga_ctrl simulation finished.");
        $finish;
    end

endmodule