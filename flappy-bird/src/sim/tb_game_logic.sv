`timescale 1ns / 1ps

// 游戏逻辑单元测试：覆盖小鸟运动、管道生成/移动、碰撞边界。
module tb_game_logic;
    localparam signed [15:0] GROUND_Y   = 16'sd420;
    localparam signed [15:0] BIRD_HALF_H = 16'sd8;
    localparam signed [15:0] GAP_HEIGHT = 16'sd140;
    localparam signed [15:0] PIPE_WIDTH = 16'sd60;
    localparam signed [15:0] PIPE_SPACING = 16'sd300;

    reg clk = 1'b0;
    always #5 clk = ~clk;

    // bird 测试信号
    reg bird_rst;
    reg bird_jump;
    reg bird_pause;
    reg bird_collision;
    reg [1:0] gravity_sel;
    wire signed [15:0] bird_x;
    wire signed [15:0] bird_y;
    wire [1:0] bird_state;

    bird u_bird (
        .clk(clk),
        .rst(bird_rst),
        .jump_ctrl(bird_jump),
        .pause_ctrl(bird_pause),
        .collision(bird_collision),
        .gravity_sel(gravity_sel),
        .jump_sel(2'b00),
        .bird_x(bird_x),
        .bird_y(bird_y),
        .game_state(bird_state)
    );

    // pipe 测试信号
    reg [15:0] pipe_score;
    reg [1:0] pipe_state;
    wire signed [15:0] gap_left0, gap_right0, gap_top0, gap_bottom0;
    wire signed [15:0] gap_left1, gap_right1, gap_top1, gap_bottom1;
    wire signed [15:0] gap_left2, gap_right2, gap_top2, gap_bottom2;
    wire signed [15:0] gap_left3, gap_right3, gap_top3, gap_bottom3;
    wire signed [15:0] gap_left4, gap_right4, gap_top4, gap_bottom4;

    pipe u_pipe (
        .clk(clk),
        .score(pipe_score),
        .game_state(pipe_state),
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

    // collision 测试信号
    reg [1:0] collision_state;
    reg signed [15:0] test_bird_y;
    reg signed [15:0] c_gap_top0;
    reg signed [15:0] c_gap_bottom0;
    wire collision_hit;

    collision u_collision (
        .clk(clk),
        .score(16'd0),
        .game_state(collision_state),
        .bird_x(16'sd250),
        .bird_y(test_bird_y),
        .gap_left0(16'sd200),
        .gap_right0(16'sd300),
        .gap_top0(c_gap_top0),
        .gap_bottom0(c_gap_bottom0),
        .gap_left1(16'sd700),
        .gap_right1(16'sd820),
        .gap_top1(16'sd100),
        .gap_bottom1(16'sd240),
        .gap_left2(16'sd900),
        .gap_right2(16'sd1020),
        .gap_top2(16'sd100),
        .gap_bottom2(16'sd240),
        .gap_left3(16'sd1100),
        .gap_right3(16'sd1220),
        .gap_top3(16'sd100),
        .gap_bottom3(16'sd240),
        .gap_left4(16'sd1300),
        .gap_right4(16'sd1420),
        .gap_top4(16'sd100),
        .gap_bottom4(16'sd240),
        .collision(collision_hit)
    );

    task automatic tick(input integer n);
        integer k;
        begin
            for (k = 0; k < n; k = k + 1)
                @(posedge clk);
            #1;
        end
    endtask

    task automatic check_one_gap(
        input signed [15:0] left,
        input signed [15:0] right,
        input signed [15:0] top,
        input signed [15:0] bottom
    );
        begin
            assert (right > left) else $fatal(1, "pipe width is invalid");
            assert ((right - left) == PIPE_WIDTH) else $fatal(1, "pipe width should be half size");
            assert ((bottom - top) == GAP_HEIGHT) else $fatal(1, "pipe gap height is invalid");
            assert (top >= 16'sd60) else $fatal(1, "pipe gap top is too high");
            assert (bottom <= GROUND_Y) else $fatal(1, "pipe gap enters ground");
        end
    endtask

    task automatic check_all_gaps;
        begin
            check_one_gap(gap_left0, gap_right0, gap_top0, gap_bottom0);
            check_one_gap(gap_left1, gap_right1, gap_top1, gap_bottom1);
            check_one_gap(gap_left2, gap_right2, gap_top2, gap_bottom2);
            check_one_gap(gap_left3, gap_right3, gap_top3, gap_bottom3);
            check_one_gap(gap_left4, gap_right4, gap_top4, gap_bottom4);
        end
    endtask

    initial begin
        integer start_y;
        integer jump_y;
        integer old_left0;

        // 小鸟：复位后居中，开始后受重力下落，跳跃后向上移动，碰撞后进入结束状态。
        gravity_sel = 2'b00;
        bird_rst = 1'b1;
        bird_jump = 1'b0;
        bird_pause = 1'b0;
        bird_collision = 1'b0;
        tick(2);
        bird_rst = 1'b0;
        tick(1);
        assert (bird_state == 2'b00) else $fatal(1, "bird should reset to IDLE");
        assert (bird_y == 16'sd240) else $fatal(1, "bird should reset to screen center");

        bird_jump = 1'b1;
        tick(1);
        bird_jump = 1'b0;
        tick(1);
        assert (bird_state == 2'b01) else $fatal(1, "bird should enter PLAY after jump");

        start_y = bird_y;
        tick(40);
        assert (bird_y > start_y) else $fatal(1, "bird should fall under gravity");

        start_y = bird_y;
        bird_pause = 1'b1;
        tick(1);
        bird_pause = 1'b0;
        tick(5);
        assert (bird_state == 2'b11) else $fatal(1, "bird should enter PAUSE");
        assert (bird_y == start_y) else $fatal(1, "bird should hold position while paused");
        bird_pause = 1'b1;
        tick(1);
        bird_pause = 1'b0;
        tick(1);
        assert (bird_state == 2'b01) else $fatal(1, "bird should resume from PAUSE");

        bird_jump = 1'b1;
        tick(1);
        bird_jump = 1'b0;
        jump_y = bird_y;
        tick(3);
        assert (bird_y < jump_y) else $fatal(1, "bird should move upward after jump");

        bird_collision = 1'b1;
        tick(1);
        bird_collision = 1'b0;
        tick(1);
        assert (bird_state == 2'b10) else $fatal(1, "bird should enter GAMEOVER after collision");

        // 管道：初始化在屏幕右侧，播放时左移，缺口高度和地面边界始终合法。
        pipe_score = 16'd0;
        pipe_state = 2'b00;
        tick(2);
        check_all_gaps();
        assert ((gap_left1 - gap_left0) == PIPE_SPACING) else $fatal(1, "pipe spacing is invalid");
        assert ((gap_left2 - gap_left1) == PIPE_SPACING) else $fatal(1, "pipe spacing is invalid");
        old_left0 = gap_left0;
        pipe_state = 2'b01;
        tick(1);
        assert (gap_left0 == old_left0 - 16'sd4) else $fatal(1, "pipe should move left at base speed");
        old_left0 = gap_left0;
        pipe_state = 2'b11;
        tick(3);
        assert (gap_left0 == old_left0) else $fatal(1, "pipe should hold position while paused");
        pipe_state = 2'b01;
        repeat (260) begin
            tick(1);
            check_all_gaps();
        end

        // 碰撞：小鸟底部到达绿色地面线时结束；在管道缺口内不碰撞，碰到管壁时碰撞。
        collision_state = 2'b01;
        c_gap_top0 = 16'sd0;
        c_gap_bottom0 = GROUND_Y;
        test_bird_y = GROUND_Y - BIRD_HALF_H - 16'sd1;
        tick(1);
        assert (!collision_hit) else $fatal(1, "bird should survive just above ground");

        test_bird_y = GROUND_Y - BIRD_HALF_H;
        tick(1);
        assert (collision_hit) else $fatal(1, "bird should collide with ground line");

        c_gap_top0 = 16'sd100;
        c_gap_bottom0 = 16'sd240;
        test_bird_y = 16'sd170;
        tick(1);
        assert (!collision_hit) else $fatal(1, "bird should pass inside pipe gap");

        test_bird_y = 16'sd80;
        tick(1);
        assert (collision_hit) else $fatal(1, "bird should collide with upper pipe");

        $display("tb_game_logic PASS");
        $finish;
    end
endmodule
