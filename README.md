# Flappy Bird Digital Design Project

本项目是数字逻辑设计课程的 Flappy Bird 小游戏工程，目标是在 K7 FPGA 板上运行。当前版本已经整合游戏逻辑、控制接口、分层 VGA 显示、K7 顶层和管脚约束。

## 文件结构

```text
flappy-bird-dd/
|-- README.md
`-- flappy-bird/
    |-- flappy-bird.xpr
    `-- src/
        |-- constrs/
        |   `-- k7.xdc
        `-- rtl/
            |-- control/
            |   `-- input_control.v
            |-- core/
            |   `-- game_core.v
            |-- display/
            |   |-- display.v
            |   |-- vga_ctrl.v
            |   |-- bg_layer.v
            |   |-- pipe_layer.v
            |   |-- bird_layer.v
            |   |-- ui_layer.v
            |   `-- debug_vga.v
            |-- game/
            |   |-- bird.v
            |   |-- pipe.v
            |   `-- collision.v
            `-- top/
                `-- top_k7.v
```

文件说明：

| 路径 | 说明 |
| --- | --- |
| `flappy-bird/flappy-bird.xpr` | Vivado 工程文件，顶层模块为 `top_k7`。 |
| `flappy-bird/src/constrs/k7.xdc` | K7 板管脚约束，包含时钟、复位、按钮、开关、LED、七段管、VGA、PS/2。 |
| `flappy-bird/src/rtl/top/top_k7.v` | 板级顶层，连接控制、游戏核心、VGA 显示和调试输出。 |
| `flappy-bird/src/rtl/control/input_control.v` | 控制接口，负责按钮/开关消抖同步、PS/2 键盘解析、操作信号映射。 |
| `flappy-bird/src/rtl/core/game_core.v` | 游戏核心封装，连接小鸟、管道、碰撞检测，并产生分数和游戏状态。 |
| `flappy-bird/src/rtl/game/` | 游戏逻辑模块：`bird`、`pipe`、`collision`。 |
| `flappy-bird/src/rtl/display/` | VGA 显示模块：时序控制、背景、管道、小鸟、UI 分层合成。 |

## 上板操作

1. 打开 Vivado，进入 `flappy-bird/flappy-bird.xpr`。
2. 确认顶层模块是 `top_k7`。
3. 点击 `Generate Bitstream`，完成后选择 `Open Hardware Manager` 并烧录生成的 `.bit` 文件。
4. 接好 VGA 显示器；可选接 PS/2 键盘。
5. 上板后先按 `rstn` 复位键复位一次。
6. 按 `BTN[3]` 开始/跳跃；接键盘时也可以按 `Space`。
7. 按 `BTN[1]` 暂停/继续；接键盘时也可以按 `Enter`。
8. 按 `BTN[0]` 重新开始。

可选开关：

| 控件 | 功能 |
| --- | --- |
| `SW[0]` | 跳跃/开始，适合不接键盘时测试。 |
| `SW[1]` | 无敌模式，屏蔽碰撞导致的游戏结束。 |
| `SW[2]` | 暂停/继续，适合拨码测试。 |
| `SW[5:4]` | 游戏速度档位：`00` 60Hz，`01` 75Hz，`10` 90Hz，`11` 120Hz。 |
| `SW[15]` | 重新开始。 |

注意：`BTNX4` 在本 K7 板接口中是按钮使能输出，不是玩家操作按键。顶层会把 `BTNX4` 拉低，使 `BTN[3:0]` 正常工作。

调试输出：

```verilog
LED = {speed_sel, immortal, pause_level, jump_level, collision_hit, game_state};
```

七段管显示当前 `score`，用于确认分数逻辑是否在运行。

## 顶层接口

顶层模块位于 `flappy-bird/src/rtl/top/top_k7.v`：

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
    output wire       BTNX4
);
```

| 信号 | 方向 | 说明 |
| --- | --- | --- |
| `clk` | 输入 | K7 板 100MHz 主时钟。 |
| `rstn` | 输入 | 低有效复位，顶层内部转换为高有效 `rst`。 |
| `BTN[3:0]` | 输入 | 板载独立按钮。 |
| `SW[15:0]` | 输入 | 16 位拨码开关。 |
| `ps2_clk` / `ps2_data` | 输入 | PS/2 键盘时钟和数据。 |
| `LED[7:0]` | 输出 | 调试 LED。 |
| `SEGMENT[7:0]` / `AN[3:0]` | 输出 | 七段管段选和位选。 |
| `r/g/b[3:0]` | 输出 | VGA 12-bit RGB 输出。 |
| `hs` / `vs` | 输出 | VGA 行同步和场同步。 |
| `BTNX4` | 输出 | 按钮使能脚，顶层固定拉低以启用 `BTN[3:0]`。 |

## 模块接口

### 控制接口 `input_control`

```verilog
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
    output wire [3:0]  btn_clean,
    output wire [15:0] sw_clean,
    output wire        ps2_space_down,
    output wire        ps2_enter_down
);
```

主要功能：

- 对 `BTN`、`SW` 做同步和消抖。
- 解码 PS/2 键盘的 `Space` 和 `Enter`。
- 输出统一的游戏控制信号：跳跃、暂停、重开、无敌、速度档位。

### 游戏核心 `game_core`

`game_core` 接收控制信号，输出小鸟坐标、管道缺口坐标、游戏状态、碰撞状态和分数。`top_k7` 将这些信号同时接到 VGA 显示层和 LED/七段管调试输出。

游戏状态编码：

| 编码 | 状态 |
| --- | --- |
| `2'b00` | `IDLE`，等待开始。 |
| `2'b01` | `PLAY`，游戏中。 |
| `2'b10` | `GAMEOVER`，游戏结束。 |
| `2'b11` | `PAUSE`，暂停。 |

### VGA 显示 `display`

`display` 是显示总成模块，内部按以下优先级合成画面：

```text
UI > Bird > Pipe > Background
```

| 模块 | 功能 |
| --- | --- |
| `vga_ctrl` | 100MHz 输入时钟四分频为约 25MHz 像素使能，产生 640x480@60Hz VGA 时序。 |
| `bg_layer` | 绘制背景。 |
| `pipe_layer` | 根据 `gap_left/right/top/bottom` 绘制管道。 |
| `bird_layer` | 根据 `bird_x`、`bird_y` 绘制小鸟。 |
| `ui_layer` | 根据 `game_state` 绘制开始、暂停、结束界面。 |

## 验证记录

已在 Vivado 2025.2 命令行环境验证：

```powershell
xvlog -sv ...
xelab top_k7 -s top_k7_elab
vivado -mode tcl
```

验证结果：

- Verilog 编译通过。
- 顶层 elaboration 通过。
- Vivado RTL elaboration 通过。
- Vivado synthesis 通过，0 errors，0 critical warnings。
