求是鹰 Flappy Bird VGA Sprite 包

内容：
1. qiushi_eagle_sprite_sheet_63x32.png
   - 精确 sprite sheet。
   - 6 帧动画，每帧 21x16。
   - 排布为 3 列 x 2 行，总尺寸 63x32。
   - 透明背景。

2. frames_21x16/frame_0_21x16.png ... frame_5_21x16.png
   - 单帧图片，均为 21x16。
   - 顺序是：
     frame_0: 上排左
     frame_1: 上排中
     frame_2: 上排右
     frame_3: 下排左
     frame_4: 下排中
     frame_5: 下排右

3. qiushi_eagle_sprite_index3.mem
   - 适合 Verilog $readmemh。
   - 每行 1 个十六进制 palette index，范围 0~7。
   - 按 63x32 整张 sheet 行优先 row-major 存储。
   - reg [2:0] sprite_idx [0:2015];

4. qiushi_eagle_sprite_rgb444.mem
   - 每行 1 个 RGB444 颜色值。
   - 适合 reg [11:0] sprite_rgb [0:2015];

5. qiushi_eagle_sprite_alpha.mem
   - 每行 0/1。
   - 0 表示透明，不画；1 表示有效像素。

6. qiushi_eagle_sprite_index3.coe / qiushi_eagle_sprite_rgb444.coe
   - Xilinx Block Memory Generator 可用的 COE 初始化文件。

7. qiushi_eagle_sprite_vga.vh
   - Verilog 参数和 palette 映射函数。

坐标与地址：
- frame = 0..5
- local_x = 0..20
- local_y = 0..15
- sheet_x = (frame % 3) * 21 + local_x
- sheet_y = (frame / 3) * 16 + local_y
- addr = sheet_y * 63 + sheet_x

Palette：
0: transparent/background, RGB444 000
1: dark navy outline,     RGB444 014
2: dark blue shadow,      RGB444 048
3: main blue,             RGB444 06B
4: light blue highlight,  RGB444 28D
5: white eye,             RGB444 FFF
6: yellow beak,           RGB444 FD1
7: orange beak shadow,    RGB444 E90

建议：
- VGA 绘制时用 index3.mem + palette 映射更灵活。
- index == 0 时跳过绘制，显示背景。
- 动画帧可按 0,1,2,3,4,5 循环，也可按 0,1,2,3,4,5,4,3,2,1 往返循环。
