# Flappy Bird Digital Design Project

本项目是数字逻辑设计课程的 Flappy Bird 小游戏工程，目标是在 K7 FPGA 板上运行。当前工程已经包含游戏逻辑、控制接口、K7 顶层、K7 管脚约束和一个临时 VGA 显示模块，后续可以继续替换或完善正式 VGA 显示部分。

## 项目结构

```text
flappy-bird-dd/
├── README.md
└── flappy-bird/
    ├── flappy-bird.xpr
    └── src/
        ├── constrs/
        │   └── k7.xdc
        └── rtl/
            ├── control/
            │   └── input_control.v
            ├── core/
            │   └── game_core.v
            ├── display/
            │   └── debug_vga.v
            ├── game/
            │   ├── bird.v
            │   ├── collision.v
            │   └── pipe.v
            └── top/
                └── top_k7.v
```

说明：

- `flappy-bird/flappy-bird.xpr`：Vivado 工程文件。
- `src/constrs/k7.xdc`：K7 板管脚约束，包括时钟、复位、按键、开关、LED、七段管、VGA、PS/2。
- `src/rtl/top/top_k7.v`：K7 板级顶层模块，Vivado 顶层为 `top_k7`。
- `src/rtl/control/input_control.v`：控制接口，负责按键/开关去抖、PS/2 键盘解码和操作映射。
- `src/rtl/core/game_core.v`：游戏核心包装层，连接 `bird`、`pipe`、`collision`，并生成游戏时钟、分数和调试信号。
- `src/rtl/game/`：游戏逻辑模块。
- `src/rtl/display/debug_vga.v`：临时 VGA 显示模块，便于在正式显示模块完成前上板验证。

## 上板操作说明

K7 板操作映射如下：

| 控件          | 功能                             |
| ------------- | -------------------------------- |
| `BTNX4`     | 跳跃/开始                        |
| `BTN[3]`    | 跳跃/开始                        |
| PS/2`Space` | 跳跃/开始                        |
| `SW[0]`     | 跳跃/开始，适合不接键盘时测试    |
| `BTN[1]`    | 暂停/继续                        |
| PS/2`Enter` | 暂停/继续                        |
| `SW[2]`     | 暂停/继续，适合测试              |
| `BTN[0]`    | 重新开始                         |
| `SW[15]`    | 重新开始                         |
| `SW[1]`     | 无敌模式，屏蔽导致游戏结束的碰撞 |
| `SW[5:4]`   | 游戏速度档位                     |

LED 调试含义：

```verilog
LED = {speed_sel, immortal, pause_level, jump_level, collision_hit, game_state};
```

其中 `game_state` 状态编码如下：

| 编码      | 状态               |
| --------- | ------------------ |
| `2'b00` | IDLE，等待开始     |
| `2'b01` | PLAY，游戏中       |
| `2'b10` | GAMEOVER，游戏结束 |
| `2'b11` | PAUSE，暂停        |

七段管当前显示 `score`，用于上板时确认分数逻辑是否工作。

## 顶层接口

顶层模块位于 `src/rtl/top/top_k7.v`：

```verilog
module top_k7(
    input  wire       clk,
    input  wire       rstn,
    input  wire [3:0] BTN,
    input  wire       BTNX4,
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
    output wire       vs
);
```

接口说明：

| 信号             | 方向 | 说明                |
| ---------------- | ---- | ------------------- |
| `clk`          | 输入 | K7 板 100MHz 主时钟 |
| `rstn`         | 输入 | 板上复位，低有效    |
| `BTN[3:0]`     | 输入 | 四个独立按键        |
| `BTNX4`        | 输入 | 中心按键            |
| `SW[15:0]`     | 输入 | 16 位拨码开关       |
| `ps2_clk`      | 输入 | PS/2 键盘时钟       |
| `ps2_data`     | 输入 | PS/2 键盘数据       |
| `LED[7:0]`     | 输出 | 调试 LED            |
| `SEGMENT[7:0]` | 输出 | 七段管段选          |
| `AN[3:0]`      | 输出 | 七段管位选          |
| `r/g/b[3:0]`   | 输出 | VGA RGB 输出        |
| `hs/vs`        | 输出 | VGA 行/场同步       |

## 控制接口

控制模块位于 `src/rtl/control/input_control.v`：

```verilog
module input_control #(
    parameter integer DEBOUNCE_COUNT = 2000000
)(
    input  wire        clk,
    input  wire        rst,
    input  wire [3:0]  btn,
    input  wire        btnx4,
    input  wire [15:0] sw,
    input  wire        ps2_clk,
    input  wire        ps2_data,
    output wire        jump_level,
    output wire        pause_level,
    output wire        restart_level,
    output wire        immortal,
    output wire [1:0]  speed_sel,
    output wire [3:0]  btn_clean,
    output wire        btnx4_clean,
    output wire [15:0] sw_clean,
    output wire        ps2_space_down,
    output wire        ps2_enter_down
);
```

主要功能：

- 对 `BTN`、`BTNX4`、`SW` 做同步和去抖。
- 解码 PS/2 键盘中的 `Space` 和 `Enter`。
- 输出统一的游戏控制信号：跳跃、暂停、重开、无敌、速度档位。

`DEBOUNCE_COUNT` 默认是 `2000000`，在 100MHz 时钟下约为 20ms。

## 游戏核心接口

游戏核心位于 `src/rtl/core/game_core.v`：

```verilog
module game_core #(
    parameter integer CLK_HZ = 100000000,
    parameter integer GAME_HZ = 60
)(
    input  wire clk,
    input  wire rst,
    input  wire jump_level,
    input  wire pause_level,
    input  wire restart_level,
    input  wire immortal,
    input  wire [1:0] speed_sel,
    output wire signed [15:0] bird_x,
    output wire signed [15:0] bird_y,
    output wire [1:0] game_state,
    output wire collision_hit,
    output reg  [15:0] score,
    output wire signed [15:0] gap_left0,
    output wire signed [15:0] gap_right0,
    output wire signed [15:0] gap_top0,
    output wire signed [15:0] gap_bottom0,
    ...
    output wire signed [15:0] gap_left4,
    output wire signed [15:0] gap_right4,
    output wire signed [15:0] gap_top4,
    output wire signed [15:0] gap_bottom4
);
```

主要功能：

- 将 100MHz 主时钟分频为游戏更新时钟。
- 对 `jump_level`、`pause_level`、`restart_level` 做边沿检测，避免长按时重复触发。
- 实例化并连接 `bird`、`pipe`、`collision`。
- 输出小鸟坐标、管道缺口坐标、碰撞状态和分数。
- `immortal` 为 1 时，碰撞不会传给小鸟状态机，因此不会进入 `GAMEOVER`。

速度档位：

| `speed_sel` | 游戏更新频率 |
| ------------- | ------------ |
| `2'b00`     | 60Hz         |
| `2'b01`     | 75Hz         |
| `2'b10`     | 90Hz         |
| `2'b11`     | 120Hz        |

## 游戏逻辑模块

### `bird`

文件：`src/rtl/game/bird.v`

功能：

- 保存小鸟位置、速度和游戏状态。
- `jump_ctrl` 触发向上跳跃。
- `pause_ctrl` 进入暂停。
- `collision` 为 1 时进入 `GAMEOVER`。

关键输出：

- `bird_x`：小鸟横坐标，目前固定为 250。
- `bird_y`：小鸟纵坐标。
- `game_state`：游戏状态。

### `pipe`

文件：`src/rtl/game/pipe.v`

功能：

- 管理 5 组管道缺口。
- 在 `PLAY` 状态下向左移动管道。
- 管道离开屏幕后在右侧重新生成。

关键输出：

- `gap_leftN` / `gap_rightN`：第 N 组管道缺口左右边界。
- `gap_topN` / `gap_bottomN`：第 N 组管道缺口上下边界。

### `collision`

文件：`src/rtl/game/collision.v`

功能：

- 根据小鸟坐标和 5 组管道缺口判断碰撞。
- 小鸟飞出屏幕上下边界也会判定碰撞。

关键输出：

- `collision`：碰撞标志。

## 待完成内容

开发 VGA：

1. 保留 `top_k7` 和 `game_core`。
2. 使用 `game_core` 输出的 `bird_x`、`bird_y`、`game_state`、`score`、`gap_*` 信号绘图。
3. 替换 `top_k7.v` 中的 `debug_vga u_vga (...)` 实例。
4. VGA 模块输出仍接 `r/g/b/hs/vs`，这样 `k7.xdc` 不需要改。

游戏逻辑：

1. 优先改 `src/rtl/game/` 下的 `bird.v`、`pipe.v`、`collision.v`。
2. 保持 `game_core` 中使用的端口名不变，避免顶层和 VGA 对接断开。
3. 改完后至少运行 Vivado 的 RTL elaboration 或 synthesis。
