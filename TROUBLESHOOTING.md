# Troubleshooting

这个文件记录本项目已经遇到过的 Vivado / 上板错误，后续不要重复踩同样的问题。

## 1. Generate Bitstream 一开始就失败，提示 top_k7.dcp 不存在

### 症状

`flappy-bird/flappy-bird.runs/synth_1/runme.log` 中出现：

```text
Command: read_checkpoint -auto_incremental -incremental .../utils_1/imports/synth_1/top_k7.dcp
ERROR: [Common 17-69] Command failed: File '.../top_k7.dcp' does not exist
```

### 根因

Vivado 工程文件 `flappy-bird/flappy-bird.xpr` 保存了旧的增量综合配置：

```xml
AutoIncrementalCheckpoint="true"
IncrementalCheckpoint="$PSRCDIR/utils_1/imports/synth_1/top_k7.dcp"
```

但这个 `.dcp` 文件属于生成目录，不应该提交，也经常不存在。Vivado 会在真正综合前先读这个文件，所以直接失败。

### 固定修法

在 `flappy-bird.xpr` 中确保：

```xml
AutoIncrementalCheckpoint="false"
```

并且不要保留下面这种文件项：

```xml
<File Path="$PSRCDIR/utils_1/imports/synth_1/top_k7.dcp">
```

命令行构建请使用：

```powershell
cd C:\Users\Vito\Documents\Programming\DD_Project\flappy-bird-dd\flappy-bird
vivado -mode batch -source verify_build.tcl
```

`verify_build.tcl` 会在构建前再次关闭 incremental checkpoint。

### 检查命令

```powershell
Select-String -Path flappy-bird\flappy-bird.xpr -Pattern "top_k7.dcp|IncrementalCheckpoint"
```

正常结果不应该出现 `top_k7.dcp`，`AutoIncrementalCheckpoint` 应该是 `false`。

## 2. 修掉 DCP 后又报找不到 display / audio_effects / bird_sprite_rom

### 症状

Vivado 报类似：

```text
module 'display' not found
module 'audio_effects' not found
module 'bird_sprite_rom' not found
```

### 根因

`flappy-bird.xpr` 的 `sources_1` 文件集漏了 RTL 文件。仅有 `top_k7.v` 和部分 game/control 文件时，顶层实例化的显示、音频、皮肤 ROM 模块无法解析。

### 固定修法

`sources_1` 至少要包含：

```text
src/rtl/game/bird.v
src/rtl/game/collision.v
src/rtl/game/pipe.v
src/rtl/control/input_control.v
src/rtl/control/background_control.v
src/rtl/control/skin_control.v
src/rtl/core/game_core.v
src/rtl/display/vga_ctrl.v
src/rtl/display/bg_layer.v
src/rtl/display/pipe_layer.v
src/rtl/display/bird_sprite_rom.v
src/rtl/display/bird_layer.v
src/rtl/display/ui_layer.v
src/rtl/display/display.v
src/rtl/audio/audio_effects.v
src/rtl/top/top_k7.v
```

`verify_build.tcl` 会自动补齐这些文件。

### 检查命令

```powershell
Select-String -Path flappy-bird\flappy-bird.xpr -Pattern 'File Path=.*\.v'
```

## 3. 新增皮肤后画面没变化

### 根因

Verilog 使用的是生成后的 `bird_sprite_rom.v`，不会在综合时直接读 PNG。

### 固定修法

新增或替换 `skins/<skin_name>/` 下的 PNG 后，必须重新生成 ROM：

```powershell
python flappy-bird\tools\generate_skin_rom.py
```

然后重新生成 bitstream。

皮肤扫描规则：

```text
优先读取 skins/<name>/frames*/ 下的 PNG
其次读取 skins/<name>/frame*.png
最后读取 skins/<name>/*.png，并跳过 preview/sheet
空文件夹不生成皮肤编号
```

## 4. 新增背景后画面没变化

### 根因

当前背景不是从 PNG 读入 ROM，而是在 `flappy-bird/src/rtl/display/bg_layer.v` 中用逻辑绘制。`backgrounds/<name>/` 是素材和说明的组织目录，不会自动综合成背景。

### 固定修法

新增背景文件夹后，需要同步修改：

```text
flappy-bird/src/rtl/display/bg_layer.v
flappy-bird/src/rtl/control/background_control.v 或 top_k7.v 中 BACKGROUND_COUNT
README.md
```

并确认 `background_control.v` 已加入：

```text
flappy-bird/flappy-bird.xpr
flappy-bird/verify_build.tcl
```

### 本次背景/UI 联动记录

当前背景编号为：

```text
0 default
1 night
2 space
3 city
```

`background_id` 仍是 2 位信号，最多支持 4 个背景。再次新增第 5 个背景时，不能只改 `BACKGROUND_COUNT`，还必须同步扩大这些接口位宽：

```text
background_control.v output background_id
top_k7.v background_id wire 和 LED 拼接
display.v background_id input
bg_layer.v background_id input
ui_layer.v background_id input
```

`ui_layer.v` 现在根据 `background_id` 切换明暗 UI 配色；如果修改 `ui_layer` 端口，必须同步更新 `display.v` 中的实例化。

### 背景切换按键没反应

如果背景数设置为 4，但 `background_control.v` 中把 `BACKGROUND_COUNT` 保存到 2 位 `localparam [1:0]`，值 `4` 会被截断成 `0`，导致按 `BTN[1]` 时一直回到背景 0，看起来没有任何切换。

固定写法：

```verilog
localparam integer BACKGROUND_COUNT_VALUE = BACKGROUND_COUNT;
```

不要写成：

```verilog
localparam [1:0] BACKGROUND_COUNT_VALUE = BACKGROUND_COUNT;
```

## 5. 快速验证流程

先做前端检查：

```powershell
cd C:\Users\Vito\Documents\Programming\DD_Project\flappy-bird-dd\flappy-bird
$files = Get-ChildItem .\src\rtl -Recurse -Filter *.v | ForEach-Object FullName
xvlog $files
xelab top_k7 -s top_k7_elab
```

再做完整构建：

```powershell
vivado -mode batch -source verify_build.tcl
```
