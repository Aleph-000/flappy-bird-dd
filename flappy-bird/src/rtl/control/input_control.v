`timescale 1ns / 1ps

// 输入去抖：按键或开关保持稳定一段时间后才更新输出。
module debounce #(
    parameter integer STABLE_COUNT = 2000000
)(
    input  wire clk,
    input  wire rst,
    input  wire noisy,
    output reg  clean
);
    reg sync0;
    reg sync1;
    reg [21:0] cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sync0 <= 1'b0;
            sync1 <= 1'b0;
            clean <= 1'b0;
            cnt   <= 22'd0;
        end else begin
            sync0 <= noisy;
            sync1 <= sync0;
            if (sync1 == clean) begin
                cnt <= 22'd0;
            end else if (cnt >= STABLE_COUNT - 1) begin
                clean <= sync1;
                cnt   <= 22'd0;
            end else begin
                cnt <= cnt + 1'b1;
            end
        end
    end
endmodule

// 板级输入接口：统一处理按钮和开关，输出游戏控制信号。
module input_control #(
    parameter integer DEBOUNCE_COUNT = 2000000
)(
    input  wire        clk,
    input  wire        rst,
    input  wire [3:0]  btn,
    input  wire [15:0] sw,
    output wire        jump_level,
    output wire        pause_level,
    output wire        restart_level,
    output wire        skin_next_level,
    output wire        background_next_level,
    output wire        immortal,
    output wire [1:0]  speed_sel,
    output wire [1:0]  gravity_sel,
    output wire [1:0]  jump_sel,
    output wire [1:0]  volume_sel,
    output wire        score_only_mode,
    output wire [3:0]  btn_clean,
    output wire [15:0] sw_clean
);
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_btn_db
            debounce #(.STABLE_COUNT(DEBOUNCE_COUNT)) u_btn_db (
                .clk(clk),
                .rst(rst),
                .noisy(btn[i]),
                .clean(btn_clean[i])
            );
        end
        for (i = 0; i < 16; i = i + 1) begin : gen_sw_db
            debounce #(.STABLE_COUNT(DEBOUNCE_COUNT)) u_sw_db (
                .clk(clk),
                .rst(rst),
                .noisy(sw[i]),
                .clean(sw_clean[i])
            );
        end
    endgenerate

    // 操作映射：动作类控制只使用 BTN，避免拨码开关造成误触发。
    assign jump_level    = btn_clean[3];
    assign skin_next_level = btn_clean[2];
    assign background_next_level = btn_clean[1];
    assign pause_level   = btn_clean[1];
    assign restart_level = btn_clean[0];

    assign immortal      = sw_clean[1];
    assign speed_sel     = sw_clean[5:4];
    assign gravity_sel   = sw_clean[7:6];
    assign jump_sel      = sw_clean[9:8];
    assign volume_sel    = sw_clean[11:10];
    assign score_only_mode = sw_clean[12];
endmodule
