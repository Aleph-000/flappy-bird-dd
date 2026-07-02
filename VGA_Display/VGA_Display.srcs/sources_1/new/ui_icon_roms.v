`timescale 1ns / 1ps

// ============================================================
// UI icon ROMs
//
// Color format:
//   12-bit RGB: [11:8]=R, [7:4]=G, [3:0]=B
//
// Transparent color:
//   12'hF0F
//
// Put the .mem files in the same Vivado sources folder as this file.
// If simulation gives xxx, change the $readmemh path to an absolute path.
// ============================================================


// 32 x 32 play icon
module ui_play_icon_rom(
    input  wire [9:0]  addr,   // 0 ~ 1023
    output reg  [11:0] color
);
    reg [11:0] rom [0:1023];

    initial begin
        $readmemh("D:/verilog/VGA_Display/VGA_Display/VGA_Display.srcs/sources_1/new/ui_play_icon.mem", rom);
        // If needed, use absolute path, for example:
        // $readmemh("D:/verilog/VGA_Display/VGA_Display/VGA_Display.srcs/sources_1/new/ui_play_icon.mem", rom);
    end

    always @(*) begin
        color = rom[addr];
    end
endmodule


// 64 x 64 pause icon
module ui_pause_icon_rom(
    input  wire [11:0] addr,   // 0 ~ 4095
    output reg  [11:0] color
);
    reg [11:0] rom [0:4095];

    initial begin
        $readmemh("D:/verilog/VGA_Display/VGA_Display/VGA_Display.srcs/sources_1/new/ui_pause_icon.mem", rom);
        // If needed, use absolute path, for example:
        // $readmemh("D:/verilog/VGA_Display/VGA_Display/VGA_Display.srcs/sources_1/new/ui_pause_icon.mem", rom);
    end

    always @(*) begin
        color = rom[addr];
    end
endmodule


// 64 x 64 gameover X icon
module ui_gameover_x_rom(
    input  wire [11:0] addr,   // 0 ~ 4095
    output reg  [11:0] color
);
    reg [11:0] rom [0:4095];

    initial begin
       $readmemh("D:/verilog/VGA_Display/VGA_Display/VGA_Display.srcs/sources_1/new/ui_gameover_x.mem", rom);
        // If needed, use absolute path, for example:
        // $readmemh("D:/verilog/VGA_Display/VGA_Display/VGA_Display.srcs/sources_1/new/ui_gameover_x.mem", rom);
    end

    always @(*) begin
        color = rom[addr];
    end
endmodule
