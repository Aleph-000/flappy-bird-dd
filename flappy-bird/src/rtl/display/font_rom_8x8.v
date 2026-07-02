`timescale 1ns / 1ps

// 8x8 字符点阵 ROM：供 VGA 文字层显示分数、皮肤名和背景名。
module font_rom_8x8(
    input  wire [7:0] ascii,
    input  wire [2:0] row,
    output reg  [7:0] bits
);
    always @(*) begin
        case (ascii)
            "0": case (row)
                3'd0: bits = 8'b00111100; 3'd1: bits = 8'b01100110;
                3'd2: bits = 8'b01101110; 3'd3: bits = 8'b01110110;
                3'd4: bits = 8'b01100110; 3'd5: bits = 8'b01100110;
                3'd6: bits = 8'b00111100; default: bits = 8'b00000000;
            endcase
            "1": case (row)
                3'd0: bits = 8'b00011000; 3'd1: bits = 8'b00111000;
                3'd2: bits = 8'b00011000; 3'd3: bits = 8'b00011000;
                3'd4: bits = 8'b00011000; 3'd5: bits = 8'b00011000;
                3'd6: bits = 8'b01111110; default: bits = 8'b00000000;
            endcase
            "2": case (row)
                3'd0: bits = 8'b00111100; 3'd1: bits = 8'b01100110;
                3'd2: bits = 8'b00000110; 3'd3: bits = 8'b00001100;
                3'd4: bits = 8'b00110000; 3'd5: bits = 8'b01100000;
                3'd6: bits = 8'b01111110; default: bits = 8'b00000000;
            endcase
            "3": case (row)
                3'd0: bits = 8'b00111100; 3'd1: bits = 8'b01100110;
                3'd2: bits = 8'b00000110; 3'd3: bits = 8'b00011100;
                3'd4: bits = 8'b00000110; 3'd5: bits = 8'b01100110;
                3'd6: bits = 8'b00111100; default: bits = 8'b00000000;
            endcase
            "4": case (row)
                3'd0: bits = 8'b00001100; 3'd1: bits = 8'b00011100;
                3'd2: bits = 8'b00101100; 3'd3: bits = 8'b01001100;
                3'd4: bits = 8'b01111110; 3'd5: bits = 8'b00001100;
                3'd6: bits = 8'b00011110; default: bits = 8'b00000000;
            endcase
            "5": case (row)
                3'd0: bits = 8'b01111110; 3'd1: bits = 8'b01100000;
                3'd2: bits = 8'b01111100; 3'd3: bits = 8'b00000110;
                3'd4: bits = 8'b00000110; 3'd5: bits = 8'b01100110;
                3'd6: bits = 8'b00111100; default: bits = 8'b00000000;
            endcase
            "6": case (row)
                3'd0: bits = 8'b00111100; 3'd1: bits = 8'b01100110;
                3'd2: bits = 8'b01100000; 3'd3: bits = 8'b01111100;
                3'd4: bits = 8'b01100110; 3'd5: bits = 8'b01100110;
                3'd6: bits = 8'b00111100; default: bits = 8'b00000000;
            endcase
            "7": case (row)
                3'd0: bits = 8'b01111110; 3'd1: bits = 8'b00000110;
                3'd2: bits = 8'b00001100; 3'd3: bits = 8'b00011000;
                3'd4: bits = 8'b00110000; 3'd5: bits = 8'b00110000;
                3'd6: bits = 8'b00110000; default: bits = 8'b00000000;
            endcase
            "8": case (row)
                3'd0: bits = 8'b00111100; 3'd1: bits = 8'b01100110;
                3'd2: bits = 8'b01100110; 3'd3: bits = 8'b00111100;
                3'd4: bits = 8'b01100110; 3'd5: bits = 8'b01100110;
                3'd6: bits = 8'b00111100; default: bits = 8'b00000000;
            endcase
            "9": case (row)
                3'd0: bits = 8'b00111100; 3'd1: bits = 8'b01100110;
                3'd2: bits = 8'b01100110; 3'd3: bits = 8'b00111110;
                3'd4: bits = 8'b00000110; 3'd5: bits = 8'b01100110;
                3'd6: bits = 8'b00111100; default: bits = 8'b00000000;
            endcase
            "A": case (row)
                3'd0: bits = 8'b00011000; 3'd1: bits = 8'b00111100;
                3'd2: bits = 8'b01100110; 3'd3: bits = 8'b01100110;
                3'd4: bits = 8'b01111110; 3'd5: bits = 8'b01100110;
                3'd6: bits = 8'b01100110; default: bits = 8'b00000000;
            endcase
            "B": case (row)
                3'd0: bits = 8'b01111100; 3'd1: bits = 8'b01100110;
                3'd2: bits = 8'b01100110; 3'd3: bits = 8'b01111100;
                3'd4: bits = 8'b01100110; 3'd5: bits = 8'b01100110;
                3'd6: bits = 8'b01111100; default: bits = 8'b00000000;
            endcase
            "C": case (row)
                3'd0: bits = 8'b00111100; 3'd1: bits = 8'b01100110;
                3'd2: bits = 8'b01100000; 3'd3: bits = 8'b01100000;
                3'd4: bits = 8'b01100000; 3'd5: bits = 8'b01100110;
                3'd6: bits = 8'b00111100; default: bits = 8'b00000000;
            endcase
            "D": case (row)
                3'd0: bits = 8'b01111000; 3'd1: bits = 8'b01101100;
                3'd2: bits = 8'b01100110; 3'd3: bits = 8'b01100110;
                3'd4: bits = 8'b01100110; 3'd5: bits = 8'b01101100;
                3'd6: bits = 8'b01111000; default: bits = 8'b00000000;
            endcase
            "E": case (row)
                3'd0: bits = 8'b01111110; 3'd1: bits = 8'b01100000;
                3'd2: bits = 8'b01100000; 3'd3: bits = 8'b01111100;
                3'd4: bits = 8'b01100000; 3'd5: bits = 8'b01100000;
                3'd6: bits = 8'b01111110; default: bits = 8'b00000000;
            endcase
            "F": case (row)
                3'd0: bits = 8'b01111110; 3'd1: bits = 8'b01100000;
                3'd2: bits = 8'b01100000; 3'd3: bits = 8'b01111100;
                3'd4: bits = 8'b01100000; 3'd5: bits = 8'b01100000;
                3'd6: bits = 8'b01100000; default: bits = 8'b00000000;
            endcase
            "G": case (row)
                3'd0: bits = 8'b00111100; 3'd1: bits = 8'b01100110;
                3'd2: bits = 8'b01100000; 3'd3: bits = 8'b01101110;
                3'd4: bits = 8'b01100110; 3'd5: bits = 8'b01100110;
                3'd6: bits = 8'b00111110; default: bits = 8'b00000000;
            endcase
            "H": case (row)
                3'd0: bits = 8'b01100110; 3'd1: bits = 8'b01100110;
                3'd2: bits = 8'b01100110; 3'd3: bits = 8'b01111110;
                3'd4: bits = 8'b01100110; 3'd5: bits = 8'b01100110;
                3'd6: bits = 8'b01100110; default: bits = 8'b00000000;
            endcase
            "I": case (row)
                3'd0: bits = 8'b00111100; 3'd1: bits = 8'b00011000;
                3'd2: bits = 8'b00011000; 3'd3: bits = 8'b00011000;
                3'd4: bits = 8'b00011000; 3'd5: bits = 8'b00011000;
                3'd6: bits = 8'b00111100; default: bits = 8'b00000000;
            endcase
            "J": case (row)
                3'd0: bits = 8'b00011110; 3'd1: bits = 8'b00001100;
                3'd2: bits = 8'b00001100; 3'd3: bits = 8'b00001100;
                3'd4: bits = 8'b01101100; 3'd5: bits = 8'b01101100;
                3'd6: bits = 8'b00111000; default: bits = 8'b00000000;
            endcase
            "K": case (row)
                3'd0: bits = 8'b01100110; 3'd1: bits = 8'b01101100;
                3'd2: bits = 8'b01111000; 3'd3: bits = 8'b01110000;
                3'd4: bits = 8'b01111000; 3'd5: bits = 8'b01101100;
                3'd6: bits = 8'b01100110; default: bits = 8'b00000000;
            endcase
            "L": case (row)
                3'd0: bits = 8'b01100000; 3'd1: bits = 8'b01100000;
                3'd2: bits = 8'b01100000; 3'd3: bits = 8'b01100000;
                3'd4: bits = 8'b01100000; 3'd5: bits = 8'b01100000;
                3'd6: bits = 8'b01111110; default: bits = 8'b00000000;
            endcase
            "M": case (row)
                3'd0: bits = 8'b01100011; 3'd1: bits = 8'b01110111;
                3'd2: bits = 8'b01111111; 3'd3: bits = 8'b01101011;
                3'd4: bits = 8'b01100011; 3'd5: bits = 8'b01100011;
                3'd6: bits = 8'b01100011; default: bits = 8'b00000000;
            endcase
            "N": case (row)
                3'd0: bits = 8'b01100110; 3'd1: bits = 8'b01110110;
                3'd2: bits = 8'b01111110; 3'd3: bits = 8'b01111110;
                3'd4: bits = 8'b01101110; 3'd5: bits = 8'b01100110;
                3'd6: bits = 8'b01100110; default: bits = 8'b00000000;
            endcase
            "O": case (row)
                3'd0: bits = 8'b00111100; 3'd1: bits = 8'b01100110;
                3'd2: bits = 8'b01100110; 3'd3: bits = 8'b01100110;
                3'd4: bits = 8'b01100110; 3'd5: bits = 8'b01100110;
                3'd6: bits = 8'b00111100; default: bits = 8'b00000000;
            endcase
            "P": case (row)
                3'd0: bits = 8'b01111100; 3'd1: bits = 8'b01100110;
                3'd2: bits = 8'b01100110; 3'd3: bits = 8'b01111100;
                3'd4: bits = 8'b01100000; 3'd5: bits = 8'b01100000;
                3'd6: bits = 8'b01100000; default: bits = 8'b00000000;
            endcase
            "Q": case (row)
                3'd0: bits = 8'b00111100; 3'd1: bits = 8'b01100110;
                3'd2: bits = 8'b01100110; 3'd3: bits = 8'b01100110;
                3'd4: bits = 8'b01101110; 3'd5: bits = 8'b00111100;
                3'd6: bits = 8'b00000110; default: bits = 8'b00000000;
            endcase
            "R": case (row)
                3'd0: bits = 8'b01111100; 3'd1: bits = 8'b01100110;
                3'd2: bits = 8'b01100110; 3'd3: bits = 8'b01111100;
                3'd4: bits = 8'b01111000; 3'd5: bits = 8'b01101100;
                3'd6: bits = 8'b01100110; default: bits = 8'b00000000;
            endcase
            "S": case (row)
                3'd0: bits = 8'b00111110; 3'd1: bits = 8'b01100000;
                3'd2: bits = 8'b01100000; 3'd3: bits = 8'b00111100;
                3'd4: bits = 8'b00000110; 3'd5: bits = 8'b00000110;
                3'd6: bits = 8'b01111100; default: bits = 8'b00000000;
            endcase
            "T": case (row)
                3'd0: bits = 8'b01111110; 3'd1: bits = 8'b01011010;
                3'd2: bits = 8'b00011000; 3'd3: bits = 8'b00011000;
                3'd4: bits = 8'b00011000; 3'd5: bits = 8'b00011000;
                3'd6: bits = 8'b00111100; default: bits = 8'b00000000;
            endcase
            "U": case (row)
                3'd0: bits = 8'b01100110; 3'd1: bits = 8'b01100110;
                3'd2: bits = 8'b01100110; 3'd3: bits = 8'b01100110;
                3'd4: bits = 8'b01100110; 3'd5: bits = 8'b01100110;
                3'd6: bits = 8'b00111100; default: bits = 8'b00000000;
            endcase
            "V": case (row)
                3'd0: bits = 8'b01100110; 3'd1: bits = 8'b01100110;
                3'd2: bits = 8'b01100110; 3'd3: bits = 8'b01100110;
                3'd4: bits = 8'b01100110; 3'd5: bits = 8'b00111100;
                3'd6: bits = 8'b00011000; default: bits = 8'b00000000;
            endcase
            "W": case (row)
                3'd0: bits = 8'b01100011; 3'd1: bits = 8'b01100011;
                3'd2: bits = 8'b01100011; 3'd3: bits = 8'b01101011;
                3'd4: bits = 8'b01111111; 3'd5: bits = 8'b01110111;
                3'd6: bits = 8'b01100011; default: bits = 8'b00000000;
            endcase
            "X": case (row)
                3'd0: bits = 8'b01100110; 3'd1: bits = 8'b01100110;
                3'd2: bits = 8'b00111100; 3'd3: bits = 8'b00011000;
                3'd4: bits = 8'b00111100; 3'd5: bits = 8'b01100110;
                3'd6: bits = 8'b01100110; default: bits = 8'b00000000;
            endcase
            "Y": case (row)
                3'd0: bits = 8'b01100110; 3'd1: bits = 8'b01100110;
                3'd2: bits = 8'b00111100; 3'd3: bits = 8'b00011000;
                3'd4: bits = 8'b00011000; 3'd5: bits = 8'b00011000;
                3'd6: bits = 8'b00111100; default: bits = 8'b00000000;
            endcase
            "Z": case (row)
                3'd0: bits = 8'b01111110; 3'd1: bits = 8'b00000110;
                3'd2: bits = 8'b00001100; 3'd3: bits = 8'b00011000;
                3'd4: bits = 8'b00110000; 3'd5: bits = 8'b01100000;
                3'd6: bits = 8'b01111110; default: bits = 8'b00000000;
            endcase
            ":": case (row)
                3'd0: bits = 8'b00000000; 3'd1: bits = 8'b00011000;
                3'd2: bits = 8'b00011000; 3'd3: bits = 8'b00000000;
                3'd4: bits = 8'b00011000; 3'd5: bits = 8'b00011000;
                default: bits = 8'b00000000;
            endcase
            ".": case (row)
                3'd5: bits = 8'b00011000; 3'd6: bits = 8'b00011000;
                default: bits = 8'b00000000;
            endcase
            default: bits = 8'b00000000;
        endcase
    end
endmodule
