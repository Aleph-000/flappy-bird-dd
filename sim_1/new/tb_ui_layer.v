`timescale 1ns / 1ps

module tb_ui_layer;

    // ========================================================
    // Inputs
    // ========================================================

    reg [9:0] pixel_x;
    reg [9:0] pixel_y;
    reg [1:0] game_state;

    // ========================================================
    // Outputs
    // ========================================================

    wire ui_on;
    wire [11:0] ui_rgb;

    // ========================================================
    // Instantiate ui_layer
    // ========================================================

    ui_layer uut(
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .game_state(game_state),

        .ui_on(ui_on),
        .ui_rgb(ui_rgb)
    );

    // ========================================================
    // Check task
    // ========================================================

    task check_ui;
        input [9:0] x;
        input [9:0] y;
        input expected_on;
        input [11:0] expected_rgb;
        input [1023:0] message;
        begin
            pixel_x = x;
            pixel_y = y;
            #1;

            if ((ui_on == expected_on) &&
                ((expected_on == 1'b0) || (ui_rgb == expected_rgb))) begin
                $display("[PASS] %s", message);
            end
            else begin
                $display("[FAIL] %s", message);
                $display("       At x=%d, y=%d", x, y);
                $display("       Expected ui_on = %b", expected_on);
                $display("       Got      ui_on = %b", ui_on);
                $display("       Expected RGB = %h", expected_rgb);
                $display("       Got      RGB = %h", ui_rgb);
            end
        end
    endtask

    // ========================================================
    // Main test
    // ========================================================

    initial begin
        // ----------------------------------------------------
        // PLAY state:
        // UI should be off everywhere.
        // ----------------------------------------------------
        game_state = 2'b01; // PLAY

        check_ui(10'd270, 10'd240, 1'b0, 12'h000,
                 "PLAY state should not show UI at start button area");

        check_ui(10'd320, 10'd240, 1'b0, 12'h000,
                 "PLAY state should not show UI at center area");


        // ----------------------------------------------------
        // IDLE state:
        // UI should be visible.
        // ----------------------------------------------------
        game_state = 2'b00; // IDLE

        // 面板边框：深蓝色 C_UI_BORDER = 12'h049
        check_ui(10'd192, 10'd150, 1'b1, 12'h049,
                 "IDLE panel border should be dark blue");

        // 面板内部：浅蓝白色 C_UI_PANEL = 12'hDFF
        check_ui(10'd220, 10'd170, 1'b1, 12'hDFF,
                 "IDLE panel body should be light blue white");

        // Start 按钮内部：蓝色 C_UI_START_BTN = 12'h37F
        check_ui(10'd270, 10'd240, 1'b1, 12'h37F,
                 "IDLE start button should be blue");

        // Start 按钮边框：黄色 C_UI_HIGHLIGHT = 12'hFE3
        check_ui(10'd252, 10'd222, 1'b1, 12'hFE3,
                 "IDLE start button border should be yellow");

        // 播放图标：白色 C_WHITE = 12'hFFF
        check_ui(10'd330, 10'd245, 1'b1, 12'hFFF,
                 "IDLE play icon should be white");

        // 面板外部：不属于 UI
        check_ui(10'd100, 10'd100, 1'b0, 12'h000,
                 "outside IDLE panel should not show UI");

        // ----------------------------------------------------
        // PAUSE state:
        // UI should show pause panel and pause icon.
        // ----------------------------------------------------
        game_state = 2'b11; // PAUSE
        
        // 面板边框：深蓝色
        check_ui(10'd192, 10'd150, 1'b1, 12'h049,
                 "PAUSE panel border should be dark blue");
        
        // 面板内部：浅蓝白色
        check_ui(10'd220, 10'd170, 1'b1, 12'hDFF,
                 "PAUSE panel body should be light blue white");
        
        // 左暂停竖条：黄色
        check_ui(10'd290, 10'd230, 1'b1, 12'hFE3,
                 "PAUSE left icon bar should be yellow");
        
        // 右暂停竖条：黄色
        check_ui(10'd340, 10'd230, 1'b1, 12'hFE3,
                 "PAUSE right icon bar should be yellow");
        
        // 两个暂停条中间的空隙：仍然是面板颜色
        check_ui(10'd320, 10'd230, 1'b1, 12'hDFF,
                 "PAUSE icon gap should show panel color");
        
        // 面板外部：不显示 UI
        check_ui(10'd100, 10'd100, 1'b0, 12'h000,
                 "outside PAUSE panel should not show UI");
                 
        // ----------------------------------------------------
        // GAMEOVER state:
        // UI should show gameover panel, red banner and white X.
        // ----------------------------------------------------
        game_state = 2'b10; // GAMEOVER
        
        // 面板边框：深蓝色
        check_ui(10'd192, 10'd150, 1'b1, 12'h049,
                 "GAMEOVER panel border should be dark blue");
        
        // 面板内部：深红色
        check_ui(10'd220, 10'd250, 1'b1, 12'h611,
                 "GAMEOVER panel body should be dark red");
        
        // 红色标题条
        check_ui(10'd250, 10'd180, 1'b1, 12'hC22,
                 "GAMEOVER banner should be red");
        
        // 白色 X 图标
        check_ui(10'd320, 10'd260, 1'b1, 12'hFFF,
                 "GAMEOVER X should be white");
        
        // X 图标外但仍在面板内：深红色
        check_ui(10'd320, 10'd230, 1'b1, 12'h611,
                 "GAMEOVER non-X panel area should be dark red");
        
        // 面板外部：不显示 UI
        check_ui(10'd100, 10'd100, 1'b0, 12'h000,
                 "outside GAMEOVER panel should not show UI");         
                         
        $display("ui_layer simulation finished.");
        $finish;
    end

endmodule