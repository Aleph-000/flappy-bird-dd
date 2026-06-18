`timescale 1ns / 1ps

module tb_pipe_layer;

    reg [9:0] pixel_x;
    reg [9:0] pixel_y;

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

    wire pipe_on;
    wire [11:0] pipe_rgb;

    pipe_layer uut(
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

    task check_pipe;
        input [9:0] x;
        input [9:0] y;
        input expected_on;
        input [1023:0] message;
        begin
            pixel_x = x;
            pixel_y = y;
            #1;

            if (pipe_on == expected_on) begin
                $display("[PASS] %s", message);
            end
            else begin
                $display("[FAIL] %s", message);
                $display("       At x=%d, y=%d", x, y);
                $display("       Expected pipe_on = %b", expected_on);
                $display("       Got      pipe_on = %b", pipe_on);
            end
        end
    endtask

    initial begin
        // ----------------------------------------------------
        // Pipe0:
        // x = 300 ~ 359
        // gap y = 150 ~ 299
        // ----------------------------------------------------
        gap_left0   = 16'sd300;
        gap_right0  = 16'sd360;
        gap_top0    = 16'sd150;
        gap_bottom0 = 16'sd300;

        // ----------------------------------------------------
        // Pipe1:
        // x = 420 ~ 479
        // gap y = 180 ~ 319
        // ----------------------------------------------------
        gap_left1   = 16'sd420;
        gap_right1  = 16'sd480;
        gap_top1    = 16'sd180;
        gap_bottom1 = 16'sd320;

        // 其他管道先设为空范围，不显示
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

        // Pipe0 upper part
        check_pipe(10'd320, 10'd100, 1'b1,
                   "pipe0 upper part should be on");

        // Pipe0 gap
        check_pipe(10'd320, 10'd200, 1'b0,
                   "pipe0 gap area should be off");

        // Pipe0 lower part
        check_pipe(10'd320, 10'd350, 1'b1,
                   "pipe0 lower part should be on");

        // Outside pipe0 x range
        check_pipe(10'd250, 10'd100, 1'b0,
                   "outside pipe0 should be off");

        // Pipe1 upper part
        check_pipe(10'd440, 10'd100, 1'b1,
                   "pipe1 upper part should be on");

        // Pipe1 gap
        check_pipe(10'd440, 10'd250, 1'b0,
                   "pipe1 gap area should be off");

        // Pipe1 lower part
        check_pipe(10'd440, 10'd360, 1'b1,
                   "pipe1 lower part should be on");

        // Pipe should not cover ground
        check_pipe(10'd320, 10'd430, 1'b0,
                   "pipe should not be drawn below ground");

        // Color check
        if (pipe_rgb == 12'h0C2)
            $display("[PASS] pipe_rgb should be green");
        else begin
            $display("[FAIL] pipe_rgb should be green");
            $display("       Expected RGB = 0C2");
            $display("       Got      RGB = %h", pipe_rgb);
        end

        $display("pipe_layer simulation finished.");
        $finish;
    end

endmodule
