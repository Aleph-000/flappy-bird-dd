# Flappy Bird Digital Design Project

这是数字逻辑设计课程的 FPGA 上板小游戏项目，实现 Flappy Bird 的游戏逻辑、VGA 分层显示、按键/开关/PS2 控制、音效、皮肤选择和背景选择。

## 文件结构

```text
flappy-bird-dd/
|-- README.md
|-- TROUBLESHOOTING.md
|-- backgrounds/
|   |-- city/
|   |-- lab/
|   |-- space/
|   |-- zjg/
|   |-- night/
|   `-- default/
|-- skins/
|   |-- qiu_shi_ying/
|   |-- dyb/
|   |-- space/
|   `-- original/
`-- flappy-bird/
    |-- flappy-bird.xpr
    |-- verify_build.tcl
    |-- tools/generate_skin_rom.py
    `-- src/
        |-- constrs/k7.xdc
        |-- rtl/audio/
        |-- rtl/control/
        |-- rtl/core/
        |-- rtl/display/
        |-- rtl/game/
        |-- rtl/top/
        `-- sim/
```

## 上板操作

1. 打开 `flappy-bird/flappy-bird.xpr`。
2. Generate Bitstream，或在 `flappy-bird/` 目录运行：

```powershell
vivado -mode batch -source verify_build.tcl
```

3. 烧录生成的 `flappy-bird/flappy-bird.runs/impl_1/top_k7.bit`。
4. 连接 VGA 显示器，按一次 `rstn` 复位后开始操作。

## 按键

| 控件 | 功能 |
| --- | --- |
| `rstn` | 低有效复位 |
| `BTN[3]` | 开始 / 跳跃 |
| `BTN[2]` | 开始界面切换皮肤 |
| `BTN[1]` | 开始界面切换背景；游戏中暂停 / 继续 |
| `BTN[0]` | 重新开始 |
| `Space` | PS2 键盘跳跃 |
| `Enter` | PS2 键盘暂停 / 继续 |

## 开关

| 开关 | 功能 |
| --- | --- |
| `SW[0]` | 跳跃/开始，便于无键盘测试 |
| `SW[1]` | 无敌模式，屏蔽碰撞导致的游戏结束 |
| `SW[2]` | 暂停/继续 |
| `SW[5:4]` | 游戏速度档位：`00` 60Hz，`01` 75Hz，`10` 90Hz，`11` 120Hz |
| `SW[7:6]` | 重力档位：`00` 最慢，`11` 最快 |
| `SW[9:8]` | 跳跃初速度档位：`00` 最低，约为原速度 1/2 |
| `SW[11:10]` | 音量 4 档 |
| `SW[12]` | 音效模式：`0` 跳跃和得分都有音效，`1` 仅得分音效 |
| `SW[15]` | 重新开始 |

`BTNX4` 是 K7 板的按键使能脚，顶层固定拉低，不是玩家操作键。

## VGA 显示

VGA 采用分层绘制：`bg_layer -> pipe_layer -> bird_layer -> ui_layer -> text_layer`。开始界面显示当前 `SKIN` 和 `BG`，游戏开始、暂停、结束时只显示 `SCORE`。文字显示由 `font_rom_8x8.v` 字符 ROM 和 `text_vram.v` 字符级显示缓存实现。

## 皮肤

小鸟 sprite 固定按 `21x21` 绘制，碰撞判定仍按 `21x16`。每个皮肤放在 `skins/<skin_name>/`，支持 1 到 8 帧 PNG；脚本会自动跳过空文件夹、`preview` 和 `sheet` 图片。

重新生成皮肤 ROM：

```powershell
python flappy-bird/tools/generate_skin_rom.py
```

当前皮肤 ID 顺序：

| ID | 目录 | VGA 显示名 |
| --- | --- | --- |
| `0` | `qiu_shi_ying` | `QIU SHI YING` |
| `1` | `dyb` | `MR. DYB` |
| `2` | `space` | `UFO` |
| `3` | `original` | `FLAPPY BIRD` |

## 背景

背景按程序化 RTL 绘制，PNG 作为美术参考和归档素材，不会被 Vivado 自动综合成背景。开始界面按 `BTN[1]` 循环切换，游戏开始后锁定当前背景。

当前背景 ID 顺序：

| ID | 背景 | 说明 |
| --- | --- | --- |
| `0` | `city` | 城市/校园风格 |
| `1` | `lab` | 实验室风格 |
| `2` | `space` | 星空风格 |
| `3` | `zjg` | 紫金港/夕阳风格 |
| `4` | `night` | 夜晚风格 |
| `5` | `default` | 默认白天风格 |

地面碰撞高度统一为 `y=420`，不同背景会使用不同地面配色；管子颜色也会随背景变化。

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

`LED = {background_id[2:0], skin_id[0], volume_sel, game_state}`，用于上板调试背景、皮肤、音量和状态机。

## 验证

推荐流程：

```powershell
cd flappy-bird
xvlog src\rtl\control\background_control.v
xvlog -sv src\sim\tb_background_control.sv
xelab tb_background_control -s tb_background_control_sim
xsim tb_background_control_sim -runall

$files = Get-ChildItem .\src\rtl -Recurse -Filter *.v | ForEach-Object FullName
xvlog $files
xelab top_k7 -s top_k7_elab
vivado -mode batch -source verify_build.tcl
```
