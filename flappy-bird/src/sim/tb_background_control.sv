`timescale 1ns / 1ps

module tb_background_control;
    localparam [1:0] IDLE = 2'b00;

    reg clk = 1'b0;
    reg rst = 1'b1;
    reg background_next_level = 1'b0;
    wire [1:0] background_id;

    always #5 clk = ~clk;

    background_control #(
        .BACKGROUND_COUNT(4)
    ) dut (
        .clk(clk),
        .rst(rst),
        .game_state(IDLE),
        .background_next_level(background_next_level),
        .background_id(background_id)
    );

    task press_background;
        begin
            @(posedge clk);
            background_next_level <= 1'b1;
            @(posedge clk);
            background_next_level <= 1'b0;
            @(posedge clk);
        end
    endtask

    task expect_background;
        input [1:0] expected;
        begin
            if (background_id !== expected) begin
                $error("background_id=%0d, expected=%0d", background_id, expected);
                $finish;
            end
        end
    endtask

    initial begin
        repeat (3) @(posedge clk);
        rst <= 1'b0;
        @(posedge clk);
        expect_background(2'd0);

        press_background();
        expect_background(2'd1);

        press_background();
        expect_background(2'd2);

        press_background();
        expect_background(2'd3);

        press_background();
        expect_background(2'd0);

        $display("tb_background_control passed");
        $finish;
    end
endmodule
