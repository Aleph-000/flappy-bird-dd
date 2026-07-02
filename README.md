# Flappy Bird Digital Design Project

本项目是数字逻辑设计课程的 FPGA 上板小游戏，实现了 Flappy Bird 的游戏逻辑、VGA 显示、按键/开关/PS2 控制、音效和皮肤动画选择。

## 文件结构

```text
flappy-bird-dd/
|-- README.md
|-- skins/                         # 皮肤素材
|   |-- original/                  # 原始小鸟皮肤
|   `-- qiu_shi_ying/              # 求是鹰皮肤
`-- flappy-bird/
    |-- flappy-bird.xpr            # Vivado 工程
    |-- verify_build.tcl           # 一键综合/实现/生成 bitstream
    |-- tools/
    |   `-- generate_skin_rom.py   # 从 skins 生成 sprite ROM
    `-- src/
        |-- constrs/k7.xdc
        |-- rtl/
        |   |-- top/top_k7.v
        |   |-- control/input_control.v
        |   |-- control/skin_control.v
        |   |-- core/game_core.v
        |   |-- game/bird.v
        |   |-- game/pipe.v
        |   |-- game/collision.v
        |   |-- display/display.v
        |   |-- display/bird_sprite_rom.v
        |   |-- display/bird_layer.v
        |   |-- display/pipe_layer.v
        |   |-- display/bg_layer.v
        |   |-- display/ui_layer.v
        |   |-- display/vga_ctrl.v
        |   `-- audio/audio_effects.v
        `-- sim/tb_game_logic.sv
```

## 上板操作

1. 打开 `flappy-bird/flappy-bird.xpr`。
2. 点击 `Generate Bitstream`，或在 `flappy-bird/` 目录运行：

   ```powershell
   vivado -mode batch -source verify_build.tcl
   ```

3. 生成的 bit 文件位置：

   ```text
   flappy-bird/flappy-bird.runs/impl_1/top_k7.bit
   ```

4. 烧录到 K7 板，接 VGA 显示器。

### 按键

| 控件 | 功能 |
| --- | --- |
| `rstn` | 低有效复位键，先按一次复位 |
| `BTN[3]` | 开始游戏 / 跳跃 |
| `BTN[2]` | 在开始界面切换皮肤 |
| `BTN[1]` | 暂停 / 继续 |
| `BTN[0]` | 重新开始 |
| `Space` | PS2 键盘跳跃 |
| `Enter` | PS2 键盘暂停 / 继续 |

### 开关

| 开关 | 功能 |
| --- | --- |
| `SW[0]` | 跳跃/开始，便于无键盘测试 |
| `SW[1]` | 无敌模式，屏蔽碰撞导致的游戏结束 |
| `SW[2]` | 暂停/继续，便于拨码测试 |
| `SW[5:4]` | 游戏速度档位：`00` 60Hz，`01` 75Hz，`10` 90Hz，`11` 120Hz |
| `SW[7:6]` | 重力档位：`00` 最慢，`11` 最快 |
| `SW[9:8]` | 跳跃初速度档位：`00` 最低，约为原速度 1/2；`11` 接近原速度 |
| `SW[15]` | 重新开始 |

`BTNX4` 是 K7 板的按键使能脚，不是玩家操作按键；顶层固定拉低以启用 `BTN[3:0]`。

## 皮肤说明

显示层的小鸟 sprite 固定按 `21x21` 绘制；碰撞判定仍按 `21x16`，对应 `collision.v` 中的 `BIRD_WIDTH=21`、`BIRD_HEIGHT=16`。

每个皮肤放在 `skins/<skin_name>/` 下，支持 1 到 8 张 PNG 帧。推荐目录：

```text
skins/<skin_name>/frames_21x21/frame_0_21x21.png
skins/<skin_name>/frames_21x21/frame_1_21x21.png
...
```

也可以使用 `frames_21x16`，生成脚本会居中补透明边到 `21x21`。新增或替换皮肤后运行：

```powershell
python flappy-bird/tools/generate_skin_rom.py
```

脚本会更新 `flappy-bird/src/rtl/display/bird_sprite_rom.v`。当前包含两个皮肤：

| 编号 | 皮肤 |
| --- | --- |
| `0` | `original` |
| `1` | `qiu_shi_ying` |

## 顶层接口

顶层模块是 `top_k7`：

```verilog
module top_k7(
    input  wire       clk,
    input  wire       rstn,
    input  wire [3:0] BTN,
    input  wire [15:0] SW,
    input  wire       ps2_clk,
    input  wire       ps2_data,
    output wire [7:0] LED,
    output wire [7:0] SEGMENT,
    output wire [3:0] AN,
    output wire [3:0] r,
    output wire [3:0] g,
    output wire [3:0] b,
    output wire       hs,
    output wire       vs,
    output wire       beep,
    output wire       BTNX4
);
```

`LED = {skin_id, bird_frame[0], jump_level, collision_hit, game_state}`，用于上板调试皮肤切换、动画、跳跃、碰撞和状态机。

## 排错文档

Vivado 生成失败、漏模块、皮肤未更新等问题记录在 `TROUBLESHOOTING.md`。如果再次出现 generate bitstream 失败，先按其中的检查命令看 `.xpr` 是否又出现 `top_k7.dcp` 或漏 RTL 源文件。

## 验证记录

已在本机 Vivado 2025.2 验证：

```powershell
xvlog ...
xelab top_k7 -s top_k7_elab
vivado -mode batch -source verify_build.tcl
```

结果：`synth_1`、`impl_1`、`write_bitstream` 均完成，DRC 为 0 Errors，bitstream 已生成。
