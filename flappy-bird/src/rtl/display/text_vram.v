`timescale 1ns / 1ps

// 字符级显示缓存：保存当前 VGA 文字层要显示的 ASCII 字符。
// IDLE 显示皮肤和背景，进入游戏后仅显示分数。
module text_vram #(
    parameter integer COLS = 32,
    parameter integer ROWS = 4
)(
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] game_state,
    input  wire [2:0] skin_id,
    input  wire [2:0] background_id,
    input  wire [15:0] score,
    input  wire [4:0] cell_x,
    input  wire [1:0] cell_y,
    output reg  [7:0] ascii
);
    localparam [1:0] IDLE = 2'b00;
    localparam integer TEXT_CELLS = COLS * ROWS;

    reg [7:0] vram [0:TEXT_CELLS-1];
    integer i;
    integer col;

    function [7:0] dec_digit;
        input [15:0] value;
        begin
            dec_digit = "0" + value[3:0];
        end
    endfunction

    function [7:0] skin_name_char;
        input [2:0] id;
        input [4:0] pos;
        begin
            skin_name_char = " ";
            case (id)
                3'd0: case (pos) // Qiu Shi Ying
                    5'd0: skin_name_char = "Q"; 5'd1: skin_name_char = "I";
                    5'd2: skin_name_char = "U"; 5'd3: skin_name_char = " ";
                    5'd4: skin_name_char = "S"; 5'd5: skin_name_char = "H";
                    5'd6: skin_name_char = "I"; 5'd7: skin_name_char = " ";
                    5'd8: skin_name_char = "Y"; 5'd9: skin_name_char = "I";
                    5'd10: skin_name_char = "N"; 5'd11: skin_name_char = "G";
                    default: skin_name_char = " ";
                endcase
                3'd1: case (pos) // Mr. dyb
                    5'd0: skin_name_char = "M"; 5'd1: skin_name_char = "R";
                    5'd2: skin_name_char = "."; 5'd3: skin_name_char = " ";
                    5'd4: skin_name_char = "D"; 5'd5: skin_name_char = "Y";
                    5'd6: skin_name_char = "B"; default: skin_name_char = " ";
                endcase
                3'd2: case (pos) // UFO
                    5'd0: skin_name_char = "U"; 5'd1: skin_name_char = "F";
                    5'd2: skin_name_char = "O"; default: skin_name_char = " ";
                endcase
                default: case (pos) // Flappy Bird
                    5'd0: skin_name_char = "F"; 5'd1: skin_name_char = "L";
                    5'd2: skin_name_char = "A"; 5'd3: skin_name_char = "P";
                    5'd4: skin_name_char = "P"; 5'd5: skin_name_char = "Y";
                    5'd6: skin_name_char = " "; 5'd7: skin_name_char = "B";
                    5'd8: skin_name_char = "I"; 5'd9: skin_name_char = "R";
                    5'd10: skin_name_char = "D"; default: skin_name_char = " ";
                endcase
            endcase
        end
    endfunction

    function [7:0] background_name_char;
        input [2:0] id;
        input [4:0] pos;
        begin
            background_name_char = " ";
            case (id)
                3'd0: case (pos) // city
                    5'd0: background_name_char = "C"; 5'd1: background_name_char = "I";
                    5'd2: background_name_char = "T"; 5'd3: background_name_char = "Y";
                    default: background_name_char = " ";
                endcase
                3'd1: case (pos) // lab
                    5'd0: background_name_char = "L"; 5'd1: background_name_char = "A";
                    5'd2: background_name_char = "B"; default: background_name_char = " ";
                endcase
                3'd2: case (pos) // space
                    5'd0: background_name_char = "S"; 5'd1: background_name_char = "P";
                    5'd2: background_name_char = "A"; 5'd3: background_name_char = "C";
                    5'd4: background_name_char = "E"; default: background_name_char = " ";
                endcase
                3'd3: case (pos) // zjg
                    5'd0: background_name_char = "Z"; 5'd1: background_name_char = "J";
                    5'd2: background_name_char = "G"; default: background_name_char = " ";
                endcase
                3'd4: case (pos) // night
                    5'd0: background_name_char = "N"; 5'd1: background_name_char = "I";
                    5'd2: background_name_char = "G"; 5'd3: background_name_char = "H";
                    5'd4: background_name_char = "T"; default: background_name_char = " ";
                endcase
                default: case (pos) // default
                    5'd0: background_name_char = "D"; 5'd1: background_name_char = "E";
                    5'd2: background_name_char = "F"; 5'd3: background_name_char = "A";
                    5'd4: background_name_char = "U"; 5'd5: background_name_char = "L";
                    5'd6: background_name_char = "T"; default: background_name_char = " ";
                endcase
            endcase
        end
    endfunction

    function [7:0] idle_skin_row_char;
        input [4:0] pos;
        begin
            case (pos)
                5'd0: idle_skin_row_char = "S";
                5'd1: idle_skin_row_char = "K";
                5'd2: idle_skin_row_char = "I";
                5'd3: idle_skin_row_char = "N";
                5'd4: idle_skin_row_char = ":";
                5'd5: idle_skin_row_char = " ";
                default: idle_skin_row_char = skin_name_char(skin_id, pos - 5'd6);
            endcase
        end
    endfunction

    function [7:0] idle_bg_row_char;
        input [4:0] pos;
        begin
            case (pos)
                5'd0: idle_bg_row_char = "B";
                5'd1: idle_bg_row_char = "G";
                5'd2: idle_bg_row_char = ":";
                5'd3: idle_bg_row_char = " ";
                default: idle_bg_row_char = background_name_char(background_id, pos - 5'd4);
            endcase
        end
    endfunction

    function [7:0] score_row_char;
        input [4:0] pos;
        reg [15:0] ones;
        reg [15:0] tens;
        reg [15:0] hundreds;
        reg [15:0] thousands;
        begin
            ones = score % 16'd10;
            tens = (score / 16'd10) % 16'd10;
            hundreds = (score / 16'd100) % 16'd10;
            thousands = (score / 16'd1000) % 16'd10;
            case (pos)
                5'd0: score_row_char = "S";
                5'd1: score_row_char = "C";
                5'd2: score_row_char = "O";
                5'd3: score_row_char = "R";
                5'd4: score_row_char = "E";
                5'd5: score_row_char = ":";
                5'd6: score_row_char = " ";
                5'd7: score_row_char = dec_digit(thousands);
                5'd8: score_row_char = dec_digit(hundreds);
                5'd9: score_row_char = dec_digit(tens);
                5'd10: score_row_char = dec_digit(ones);
                default: score_row_char = " ";
            endcase
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < TEXT_CELLS; i = i + 1)
                vram[i] <= " ";
        end else begin
            for (col = 0; col < COLS; col = col + 1) begin
                if (game_state == IDLE) begin
                    vram[col] <= idle_skin_row_char(col[4:0]);
                    vram[COLS + col] <= idle_bg_row_char(col[4:0]);
                    vram[(2 * COLS) + col] <= " ";
                    vram[(3 * COLS) + col] <= " ";
                end else begin
                    vram[col] <= score_row_char(col[4:0]);
                    vram[COLS + col] <= " ";
                    vram[(2 * COLS) + col] <= " ";
                    vram[(3 * COLS) + col] <= " ";
                end
            end
        end
    end

    always @(*) begin
        if (cell_x < COLS && cell_y < ROWS)
            ascii = vram[(cell_y * COLS) + cell_x];
        else
            ascii = " ";
    end
endmodule
