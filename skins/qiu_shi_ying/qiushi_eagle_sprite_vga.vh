// Qiushi Eagle Flappy-style sprite, generated for VGA use.
// Layout: 6 frames, each 21x16, arranged as 3 columns x 2 rows.
// Sheet size: 63x32.
// Data order in .mem/.coe files: row-major over the whole 63x32 sheet.
// Palette index 0 is transparent/background.

localparam QIUSHI_SPRITE_W        = 21;
localparam QIUSHI_SPRITE_H        = 16;
localparam QIUSHI_SPRITE_FRAMES   = 6;
localparam QIUSHI_SPRITE_COLS     = 3;
localparam QIUSHI_SPRITE_ROWS     = 2;
localparam QIUSHI_SHEET_W         = 63;
localparam QIUSHI_SHEET_H         = 32;
localparam QIUSHI_SHEET_PIXELS    = 2016;

// Use with: reg [2:0] sprite_idx [0:QIUSHI_SHEET_PIXELS-1];
// initial $readmemh("qiushi_eagle_sprite_index3.mem", sprite_idx);
//
// For frame f, local pixel (x,y):
// sheet_x = (f % 3) * 21 + x;
// sheet_y = (f / 3) * 16 + y;
// addr    = sheet_y * 63 + sheet_x;

function [11:0] qiushi_palette_rgb444;
    input [2:0] idx;
    begin
        case (idx)
            3'h0: qiushi_palette_rgb444 = 12'h000; // transparent/background
            3'h1: qiushi_palette_rgb444 = 12'h014; // dark navy outline
            3'h2: qiushi_palette_rgb444 = 12'h048; // dark blue shadow
            3'h3: qiushi_palette_rgb444 = 12'h06B; // main blue
            3'h4: qiushi_palette_rgb444 = 12'h28D; // light blue highlight
            3'h5: qiushi_palette_rgb444 = 12'hFFF; // eye white
            3'h6: qiushi_palette_rgb444 = 12'hFD1; // beak yellow
            3'h7: qiushi_palette_rgb444 = 12'hE90; // beak orange shadow
            default: qiushi_palette_rgb444 = 12'h000;
        endcase
    end
endfunction
