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

// PS/2 键盘解码：只提取游戏需要的 Space 和 Enter 按下状态。
module ps2_keys(
    input  wire clk,
    input  wire rst,
    input  wire ps2_clk,
    input  wire ps2_data,
    output reg  space_down,
    output reg  enter_down
);
    reg ps2c0;
    reg ps2c1;
    reg ps2c2;
    reg ps2d0;
    reg ps2d1;
    wire ps2_fall = ps2c2 & ~ps2c1;

    reg [10:0] shift;
    reg [3:0]  bit_count;
    reg        break_seen;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ps2c0 <= 1'b1;
            ps2c1 <= 1'b1;
            ps2c2 <= 1'b1;
            ps2d0 <= 1'b1;
            ps2d1 <= 1'b1;
            shift <= 11'd0;
            bit_count <= 4'd0;
            break_seen <= 1'b0;
            space_down <= 1'b0;
            enter_down <= 1'b0;
        end else begin
            ps2c0 <= ps2_clk;
            ps2c1 <= ps2c0;
            ps2c2 <= ps2c1;
            ps2d0 <= ps2_data;
            ps2d1 <= ps2d0;

            if (ps2_fall) begin
                shift[bit_count] <= ps2d1;
                if (bit_count == 4'd10) begin
                    bit_count <= 4'd0;
                    if (shift[8:1] == 8'hF0) begin
                        break_seen <= 1'b1;
                    end else if (shift[8:1] == 8'hE0) begin
                        break_seen <= break_seen;
                    end else begin
                        case (shift[8:1])
                            8'h29: space_down <= ~break_seen;
                            8'h5A: enter_down <= ~break_seen;
                            default: ;
                        endcase
                        break_seen <= 1'b0;
                    end
                end else begin
                    bit_count <= bit_count + 1'b1;
                end
            end
        end
    end
endmodule

// 板级输入接口：统一处理按钮、开关和 PS/2 键盘，输出游戏控制信号。
module input_control #(
    parameter integer DEBOUNCE_COUNT = 2000000
)(
    input  wire        clk,
    input  wire        rst,
    input  wire [3:0]  btn,
    input  wire [15:0] sw,
    input  wire        ps2_clk,
    input  wire        ps2_data,
    output wire        jump_level,
    output wire        pause_level,
    output wire        restart_level,
    output wire        immortal,
    output wire [1:0]  speed_sel,
    output wire [1:0]  gravity_sel,
    output wire [3:0]  btn_clean,
    output wire [15:0] sw_clean,
    output wire        ps2_space_down,
    output wire        ps2_enter_down
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

    ps2_keys u_ps2 (
        .clk(clk),
        .rst(rst),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .space_down(ps2_space_down),
        .enter_down(ps2_enter_down)
    );

    // 操作映射：BTN3/Space/SW0 跳跃，BTN1/Enter/SW2 暂停。
    assign jump_level    = btn_clean[3] | sw_clean[0] | ps2_space_down;
    assign pause_level   = btn_clean[1] | sw_clean[2] | ps2_enter_down;
    assign restart_level = btn_clean[0] | sw_clean[15];
    assign immortal      = sw_clean[1];
    assign speed_sel     = sw_clean[5:4];
    assign gravity_sel   = sw_clean[7:6];
endmodule
