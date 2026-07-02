# Troubleshooting

这个文件记录本项目已经遇到过的 Vivado / 上板问题。以后每次修改前先读这里，避免重复犯同样错误。

## 1. Generate Bitstream 一开始失败，提示 top_k7.dcp 不存在

症状：

```text
read_checkpoint -auto_incremental .../utils_1/imports/synth_1/top_k7.dcp
ERROR: File '.../top_k7.dcp' does not exist
```

原因：`.xpr` 保存了旧的增量综合 checkpoint 配置，但生成目录里的 `.dcp` 不应提交，也经常不存在。

固定要求：

```xml
AutoIncrementalCheckpoint="false"
```

`.xpr` 中不能出现：

```xml
<File Path="$PSRCDIR/utils_1/imports/synth_1/top_k7.dcp">
```

检查命令：

```powershell
Select-String -Path flappy-bird\flappy-bird.xpr -Pattern "top_k7.dcp|AutoIncrementalCheckpoint|IncrementalCheckpoint"
```

## 2. 新增 RTL 后 Vivado 报 module not found

原因：只创建了 `.v` 文件，但没有加入 `flappy-bird.xpr` 或 `verify_build.tcl`。

当前新增显示文字后，至少要包含：

```text
src/rtl/display/font_rom_8x8.v
src/rtl/display/text_vram.v
src/rtl/display/text_layer.v
```

如果报 `display`、`text_layer`、`font_rom_8x8`、`text_vram` 找不到，先检查 `.xpr` 和 `verify_build.tcl`。

## 3. 中文注释和代码在同一行导致模块被注释吞掉

这次发现旧文件里有几处类似问题：

```verilog
// 中文说明... module top_k7(
```

或端口被注释吞掉：

```verilog
input wire [9:0] pixel_x, // 注释 input wire [9:0] pixel_y,
```

这种写法会导致 Vivado 找不到模块、端口消失，或者输出没有驱动。修复原则：

```verilog
// 中文说明单独占一行。
module top_k7(
```

端口每个单独成行，注释不要和下一段代码挤在同一行。

## 4. 背景超过 4 个后不能继续使用 2-bit background_id

当前背景顺序为：

```text
0 city
1 lab
2 space
3 zjg
4 night
5 default
```

因此 `background_id` 必须是 3 位，并且这些文件要同步：

```text
flappy-bird/src/rtl/control/background_control.v
flappy-bird/src/rtl/top/top_k7.v
flappy-bird/src/rtl/display/display.v
flappy-bird/src/rtl/display/bg_layer.v
flappy-bird/src/rtl/display/ui_layer.v
flappy-bird/src/rtl/display/pipe_layer.v
flappy-bird/src/sim/tb_background_control.sv
```

`BACKGROUND_COUNT` 要设为 6。不要把背景数量保存到 2 位 localparam，否则 `4` 会被截断成 `0`。

正确写法：

```verilog
localparam integer BACKGROUND_COUNT_VALUE = BACKGROUND_COUNT;
```

## 5. 皮肤切换顺序不对

皮肤 ROM 不是运行时读 PNG，而是由脚本生成：

```powershell
python flappy-bird\tools\generate_skin_rom.py
```

当前脚本固定优先顺序：

```text
qiu_shi_ying -> dyb -> space -> original
```

显示名对应：

```text
Qiu Shi Ying -> Mr. dyb -> UFO -> Flappy Bird
```

每次更新 `skins/` 后都要重新运行脚本，并确认输出顺序。

## 6. 背景图片不会自动显示

`backgrounds/<name>/` 中的 PNG 是美术参考和归档素材，不会自动进入 FPGA。新增背景要改：

```text
bg_layer.v
background_control.v / top_k7.v 中的 BACKGROUND_COUNT
ui_layer.v 的选择点和配色
pipe_layer.v 的背景配色
README.md
```

空背景文件夹要跳过，不要给空文件夹分配可切换 ID。

## 7. 文字显示层相关问题

文字层由三部分组成：

```text
font_rom_8x8.v  字符点阵 ROM
text_vram.v     字符级显示缓存
text_layer.v    VGA 像素绘制
```

开始界面显示 `SKIN` 和 `BG`，非开始界面只显示 `SCORE`。如果文字不显示，检查：

```text
display.v 是否实例化 text_layer
text_layer.v 是否在 .xpr 和 verify_build.tcl
图层混合顺序中 text_on 是否在 ui_on 后面
```

注意不要写 `localparam [4:0] COLS = 5'd32`，5 位无法表示 32，会截断为 0。使用 integer。

## 8. 快速验证流程

```powershell
cd C:\Users\Vito\Documents\Programming\DD_Project\flappy-bird-dd\flappy-bird
xvlog src\rtl\control\background_control.v
xvlog -sv src\sim\tb_background_control.sv
xelab tb_background_control -s tb_background_control_sim
xsim tb_background_control_sim -runall

$files = Get-ChildItem .\src\rtl -Recurse -Filter *.v | ForEach-Object FullName
xvlog $files
xelab top_k7 -s top_k7_elab
vivado -mode batch -source verify_build.tcl
```
