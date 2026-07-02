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

## 4. 快速验证流程

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
