`timescale 1ns / 1ps

module tb_bird_layer;

    reg [9:0] pixel_x;
    reg [9:0] pixel_y;

    reg signed [15:0] bird_x;
    reg signed [15:0] bird_y;

    wire bird_on;
    wire [11:0] bird_rgb;

    bird_layer uut(
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .bird_x(bird_x),
        .bird_y(bird_y),
        .bird_on(bird_on),
        .bird_rgb(bird_rgb)
    );

    task check_bird;
        input [9:0] x;
        input [9:0] y;
        input expected_on;
        input [11:0] expected_rgb;
        input [1023:0] message;
        begin
            pixel_x = x;
            pixel_y = y;
            #1;

            if ((bird_on == expected_on) &&
                ((expected_on == 1'b0) || (bird_rgb == expected_rgb))) begin
                $display("[PASS] %s", message);
            end
            else begin
                $display("[FAIL] %s", message);
                $display("       At x=%d, y=%d", x, y);
                $display("       Expected bird_on = %b", expected_on);
                $display("       Got      bird_on = %b", bird_on);
                $display("       Expected RGB = %h", expected_rgb);
                $display("       Got      RGB = %h", bird_rgb);
            end
        end
    endtask

    initial begin
        // 小鸟中心坐标
        // bird_left = 160 - 32 = 128
        // bird_top  = 200 - 24 = 176
        bird_x = 16'sd160;
        bird_y = 16'sd200;

        // 身体内部：黄色
        check_bird(10'd150, 10'd200, 1'b1, 12'hFD0,
                   "bird body should be yellow");

        // 左上角边框：黑色
        check_bird(10'd128, 10'd176, 1'b1, 12'h000,
                   "bird outline should be black");

        // 嘴巴区域：橙色
        check_bird(10'd180, 10'd200, 1'b1, 12'hF60,
                   "bird beak should be orange");

        // 眼睛区域：白色
        check_bird(10'd170, 10'd190, 1'b1, 12'hFFF,
                   "bird eye should be white");

        // 翅膀区域：深黄色
        check_bird(10'd145, 10'd205, 1'b1, 12'hD80,
                   "bird wing should be dark yellow");

        // 小鸟外部
        check_bird(10'd100, 10'd100, 1'b0, 12'h000,
                   "outside bird should be off");

        $display("bird_layer simulation finished.");
        $finish;
    end

endmodule