`timescale 1ns / 1ps

// ============================================================
// Module: bird_sprite_rom
// Function:
//   Store bird sprite pixels.
//
// Sprite size:
//   64 x 48
//
// Color format:
//   12-bit RGB
//
// Transparent color used in .mem:
//   12'hF0F
//
// Note:
//   Add bird_sprite.mem to the Vivado project as a memory
//   initialization file, or keep it in the simulation/run folder
//   where $readmemh can find it.
// ============================================================

module bird_sprite_rom(
    input  wire [11:0] addr,   // sprite pixel address: y * 64 + x
    output reg  [11:0] color   // 12-bit RGB color
);

    // 64 * 48 = 3072 pixels
    reg [11:0] rom [0:3071];

    initial begin
        $readmemh("D:/verilog/VGA_Display/VGA_Display/VGA_Display.srcs/sources_1/new/bird_sprite.mem", rom);
    end

    always @(*) begin
        color = rom[addr];
    end

endmodule
